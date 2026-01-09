import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<_LanguageOption> _languages = [
    _LanguageOption(locale: Locale('en'), flag: '🇬🇧', nameKey: 'english'),
    _LanguageOption(locale: Locale('tr'), flag: '🇹🇷', nameKey: 'turkish'),
    _LanguageOption(locale: Locale('de'), flag: '🇩🇪', nameKey: 'german'),
    _LanguageOption(locale: Locale('ru'), flag: '🇷🇺', nameKey: 'russian'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentLocale = state is SettingsLoaded ? state.locale : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: _languages.map((language) {
                    final isSelected =
                        currentLocale?.languageCode == language.locale.languageCode;

                    return ListTile(
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(_getLanguageName(l10n, language.nameKey)),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        context
                            .read<SettingsBloc>()
                            .add(ChangeLanguageEvent(language.locale));
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getLanguageName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'english':
        return l10n.english;
      case 'turkish':
        return l10n.turkish;
      case 'german':
        return l10n.german;
      case 'russian':
        return l10n.russian;
      default:
        return key;
    }
  }
}

class _LanguageOption {
  final Locale locale;
  final String flag;
  final String nameKey;

  const _LanguageOption({
    required this.locale,
    required this.flag,
    required this.nameKey,
  });
}
