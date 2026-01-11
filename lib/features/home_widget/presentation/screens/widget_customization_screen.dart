import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quote/presentation/bloc/quote_bloc.dart';
import '../../../quote/presentation/bloc/quote_state.dart';
import '../../domain/entities/widget_settings.dart';
import '../bloc/widget_settings_bloc.dart';
import '../bloc/widget_settings_event.dart';
import '../bloc/widget_settings_state.dart';
import '../widgets/color_picker_tile.dart';
import '../widgets/widget_preview.dart';

class WidgetCustomizationScreen extends StatefulWidget {
  const WidgetCustomizationScreen({super.key});

  @override
  State<WidgetCustomizationScreen> createState() =>
      _WidgetCustomizationScreenState();
}

class _WidgetCustomizationScreenState extends State<WidgetCustomizationScreen> {
  bool _wasSaving = false;
  bool _isIOS26OrLater = false;

  @override
  void initState() {
    super.initState();
    context.read<WidgetSettingsBloc>().add(const LoadWidgetSettingsEvent());
    _checkIOSVersion();
  }

  Future<void> _checkIOSVersion() async {
    if (Platform.isIOS) {
      // Get iOS version from operatingSystemVersion
      // Format is like "Version 26.0 (Build 12345)" or "26.0"
      final versionString = Platform.operatingSystemVersion;
      final match = RegExp(r'(\d+)\.').firstMatch(versionString);
      if (match != null) {
        final majorVersion = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (majorVersion >= 26) {
          setState(() {
            _isIOS26OrLater = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.widgetAppearance),
        actions: [
          BlocBuilder<WidgetSettingsBloc, WidgetSettingsState>(
            builder: (context, state) {
              if (state is WidgetSettingsLoaded && state.hasUnsavedChanges) {
                return TextButton(
                  onPressed: () => context
                      .read<WidgetSettingsBloc>()
                      .add(const SaveWidgetSettingsEvent()),
                  child: Text(l10n.save),
                );
              }
              if (state is WidgetSettingsSaving) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<WidgetSettingsBloc, WidgetSettingsState>(
        listener: (context, state) {
          // Track saving state to show success message only after save completes
          if (state is WidgetSettingsSaving) {
            _wasSaving = true;
          }
          if (state is WidgetSettingsLoaded && _wasSaving && !state.hasUnsavedChanges) {
            _wasSaving = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.widgetUpdatedSuccessfully),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is WidgetSettingsError) {
            _wasSaving = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WidgetSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WidgetSettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<WidgetSettingsBloc>()
                        .add(const LoadWidgetSettingsEvent()),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is WidgetSettingsLoaded || state is WidgetSettingsSaving) {
            final settings = state is WidgetSettingsLoaded
                ? state.settings
                : (state as WidgetSettingsSaving).settings;
            final isSaving = state is WidgetSettingsSaving;

            return _buildContent(context, settings, isSaving, l10n);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetSettings settings,
    bool isSaving,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Preview (force disable glass on iOS 26+)
          BlocBuilder<QuoteBloc, QuoteState>(
            builder: (context, quoteState) {
              String? quoteText;
              String? author;
              if (quoteState is QuoteLoaded) {
                quoteText = quoteState.quote.text;
                author = quoteState.quote.author;
              }
              return WidgetPreview(
                settings: settings,
                forceDisableGlass: _isIOS26OrLater,
                quoteText: quoteText,
                author: author,
              );
            },
          ),
          const SizedBox(height: 32),

          // Glass Mode Toggle (hidden on iOS 26+ due to known issues)
          if (!_isIOS26OrLater) ...[
            _buildGlassModeToggle(context, settings, isSaving, l10n),
            const SizedBox(height: 16),
          ],

          // Background Color Picker (disabled when glass mode is on, but not on iOS 26+)
          _buildBackgroundColorPicker(context, settings, isSaving, l10n),
          const SizedBox(height: 16),

          // Text Color Picker
          _buildTextColorPicker(context, settings, isSaving, l10n),

          const SizedBox(height: 32),

          // Info text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.widgetInfoMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassModeToggle(
    BuildContext context,
    WidgetSettings settings,
    bool isSaving,
    AppLocalizations l10n,
  ) {
    return Card(
      child: SwitchListTile(
        title: Text(l10n.frostedGlassEffect),
        subtitle: Text(l10n.frostedGlassDescription),
        value: settings.isGlassModeEnabled,
        onChanged: isSaving
            ? null
            : (_) => context
                .read<WidgetSettingsBloc>()
                .add(const ToggleGlassModeEvent()),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.blur_on,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundColorPicker(
    BuildContext context,
    WidgetSettings settings,
    bool isSaving,
    AppLocalizations l10n,
  ) {
    // On iOS 26+, glass mode is disabled, so background is always enabled
    final isDisabled = !_isIOS26OrLater && (settings.isGlassModeEnabled || isSaving);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.5 : 1.0,
      child: ColorPickerTile(
        title: l10n.backgroundColor,
        subtitle: settings.isGlassModeEnabled && !_isIOS26OrLater
            ? l10n.disabledWhenGlassOn
            : l10n.tapToChange,
        currentColor: Color(settings.backgroundColor),
        enabled: !isDisabled,
        onColorChanged: (color) {
          context
              .read<WidgetSettingsBloc>()
              .add(UpdateBackgroundColorEvent(color.toARGB32()));
        },
      ),
    );
  }

  Widget _buildTextColorPicker(
    BuildContext context,
    WidgetSettings settings,
    bool isSaving,
    AppLocalizations l10n,
  ) {
    return ColorPickerTile(
      title: l10n.textColor,
      subtitle: l10n.tapToChange,
      currentColor: Color(settings.textColor),
      enabled: !isSaving,
      onColorChanged: (color) {
        context
            .read<WidgetSettingsBloc>()
            .add(UpdateTextColorEvent(color.toARGB32()));
      },
    );
  }

}
