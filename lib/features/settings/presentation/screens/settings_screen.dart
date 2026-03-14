import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_font.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.language),
              text: l10n.languages,
            ),
            Tab(
              icon: const Icon(Icons.notifications_outlined),
              text: l10n.notifications,
            ),
            Tab(
              icon: const Icon(Icons.palette_outlined),
              text: l10n.appearance,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LanguagesTab(),
          _NotificationsTab(),
          _AppearanceTab(),
        ],
      ),
    );
  }
}

// ─── Languages Tab ───

class _LanguagesTab extends StatelessWidget {
  const _LanguagesTab();

  static const List<_LanguageOption> _languages = [
    _LanguageOption(locale: Locale('en'), flag: '\u{1F1EC}\u{1F1E7}', nameKey: 'english'),
    _LanguageOption(locale: Locale('tr'), flag: '\u{1F1F9}\u{1F1F7}', nameKey: 'turkish'),
    _LanguageOption(locale: Locale('de'), flag: '\u{1F1E9}\u{1F1EA}', nameKey: 'german'),
    _LanguageOption(locale: Locale('ru'), flag: '\u{1F1F7}\u{1F1FA}', nameKey: 'russian'),
    _LanguageOption(locale: Locale('es'), flag: '\u{1F1EA}\u{1F1F8}', nameKey: 'spanish'),
    _LanguageOption(locale: Locale('fr'), flag: '\u{1F1EB}\u{1F1F7}', nameKey: 'french'),
    _LanguageOption(locale: Locale('pt'), flag: '\u{1F1E7}\u{1F1F7}', nameKey: 'portuguese'),
    _LanguageOption(locale: Locale('it'), flag: '\u{1F1EE}\u{1F1F9}', nameKey: 'italian'),
    _LanguageOption(locale: Locale('ar'), flag: '\u{1F1F8}\u{1F1E6}', nameKey: 'arabic'),
    _LanguageOption(locale: Locale('zh'), flag: '\u{1F1E8}\u{1F1F3}', nameKey: 'chinese'),
    _LanguageOption(locale: Locale('ja'), flag: '\u{1F1EF}\u{1F1F5}', nameKey: 'japanese'),
    _LanguageOption(locale: Locale('ko'), flag: '\u{1F1F0}\u{1F1F7}', nameKey: 'korean'),
    _LanguageOption(locale: Locale('hi'), flag: '\u{1F1EE}\u{1F1F3}', nameKey: 'hindi'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentLocale = state is SettingsLoaded ? state.locale : null;

        return ResponsiveCenter(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              final isSelected =
                  currentLocale?.languageCode == language.locale.languageCode;

              return ListTile(
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 28),
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
            },
          ),
        );
      },
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
      case 'spanish':
        return l10n.spanish;
      case 'french':
        return l10n.french;
      case 'portuguese':
        return l10n.portuguese;
      case 'italian':
        return l10n.italian;
      case 'arabic':
        return l10n.arabic;
      case 'chinese':
        return l10n.chinese;
      case 'japanese':
        return l10n.japanese;
      case 'korean':
        return l10n.korean;
      case 'hindi':
        return l10n.hindi;
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

// ─── Notifications Tab ───

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final loaded = state is SettingsLoaded ? state : null;
        final enabled = loaded?.notificationsEnabled ?? true;
        final hour = loaded?.notificationHour ?? 7;
        final minute = loaded?.notificationMinute ?? 0;

        return ResponsiveCenter(
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.dailyReminder,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.enableNotifications),
                    subtitle: Text(l10n.receiveQuoteDaily),
                    secondary: Icon(
                      enabled
                          ? Icons.notifications_active
                          : Icons.notifications_off_outlined,
                      color: enabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    value: enabled,
                    onChanged: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleNotificationsEvent(value));
                    },
                  ),
                  if (enabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(l10n.notificationTime),
                      trailing: Text(
                        _formatTime(hour, minute),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showTimePicker(context, hour, minute),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        );
      },
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _showTimePicker(
      BuildContext context, int currentHour, int currentMinute) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );
    if (time != null && context.mounted) {
      context
          .read<SettingsBloc>()
          .add(ChangeNotificationTimeEvent(time.hour, time.minute));
    }
  }
}

// ─── Appearance Tab ───

class _AppearanceTab extends StatelessWidget {
  const _AppearanceTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final loaded = state is SettingsLoaded ? state : null;
        final currentMode = loaded?.themeMode ?? ThemeMode.system;
        final currentFontKey = loaded?.appFontKey ?? 'classic';

        return ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.themeMode,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _ThemeTile(
                      icon: Icons.brightness_auto,
                      title: l10n.systemTheme,
                      mode: ThemeMode.system,
                      currentMode: currentMode,
                    ),
                    const Divider(height: 1),
                    _ThemeTile(
                      icon: Icons.light_mode,
                      title: l10n.lightTheme,
                      mode: ThemeMode.light,
                      currentMode: currentMode,
                    ),
                    const Divider(height: 1),
                    _ThemeTile(
                      icon: Icons.dark_mode,
                      title: l10n.darkTheme,
                      mode: ThemeMode.dark,
                      currentMode: currentMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Font',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (int i = 0; i < AppFont.values.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      _FontTile(
                        font: AppFont.values[i],
                        isSelected: AppFont.values[i].key == currentFontKey,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FontTile extends StatelessWidget {
  final AppFont font;
  final bool isSelected;

  const _FontTile({required this.font, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textColor = theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(
        Icons.text_fields,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        font.displayName,
        style: font.primaryStyle.copyWith(fontSize: 16, color: textColor),
      ),
      subtitle: Text(
        'The quick brown fox',
        style: font.bodyStyle.copyWith(fontSize: 12, color: textColor.withValues(alpha: 0.7)),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        context.read<SettingsBloc>().add(ChangeAppFontEvent(font.key));
      },
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final ThemeMode mode;
  final ThemeMode currentMode;

  const _ThemeTile({
    required this.icon,
    required this.title,
    required this.mode,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: () {
        context.read<SettingsBloc>().add(ChangeThemeModeEvent(mode));
      },
    );
  }
}
