import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_font.dart';
import '../../../../core/widgets/responsive_center.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<WidgetSettingsBloc>().add(const LoadWidgetSettingsEvent());
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
            final errorColor = Theme.of(context).colorScheme.error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: errorColor,
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
            final errorColor = Theme.of(context).colorScheme.error;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: errorColor,
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
      child: ResponsiveCenter(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget Preview
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
                forceDisableGlass: true,
                quoteText: quoteText,
                author: author,
              );
            },
          ),
          const SizedBox(height: 32),

          // Font Picker
          _buildFontPicker(context, settings, isSaving, l10n),
          const SizedBox(height: 16),

          // Background Color Picker
          _buildBackgroundColorPicker(context, settings, isSaving, l10n),
          const SizedBox(height: 16),

          // Text Color Picker
          _buildTextColorPicker(context, settings, isSaving, l10n),

          const SizedBox(height: 32),

          // Info text
          _buildInfoBox(context, l10n),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.widgetInfoMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontPicker(
    BuildContext context,
    WidgetSettings settings,
    bool isSaving,
    AppLocalizations l10n,
  ) {
    final currentFont = AppFont.fromKey(settings.fontKey);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.text_fields),
        title: const Text('Widget Font'),
        subtitle: Text(currentFont.displayName),
        trailing: const Icon(Icons.chevron_right),
        enabled: !isSaving,
        onTap: !isSaving
            ? () => _showFontPicker(context, settings.fontKey)
            : null,
      ),
    );
  }

  void _showFontPicker(BuildContext context, String currentFontKey) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Select Font',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final font in AppFont.values)
              ListTile(
                title: Text(
                  font.displayName,
                  style: font.primaryStyle.copyWith(fontSize: 16),
                ),
                subtitle: Text(
                  '"The happiness of your life..."',
                  style: font.primaryStyle.copyWith(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                trailing: font.key == currentFontKey
                    ? Icon(Icons.check_circle,
                        color: Theme.of(sheetContext).colorScheme.primary)
                    : null,
                onTap: () {
                  context
                      .read<WidgetSettingsBloc>()
                      .add(UpdateWidgetFontEvent(font.key));
                  Navigator.pop(sheetContext);
                },
              ),
            const SizedBox(height: 8),
          ],
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
    return ColorPickerTile(
      title: l10n.backgroundColor,
      subtitle: l10n.tapToChange,
      currentColor: Color(settings.backgroundColor),
      enabled: !isSaving,
      onColorChanged: (color) {
        context
            .read<WidgetSettingsBloc>()
            .add(UpdateBackgroundColorEvent(color.toARGB32()));
      },
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
