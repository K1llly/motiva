import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../di/injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../quote/presentation/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = di.sl<SharedPreferences>();
    await prefs.setBool(StorageKeys.onboardingCompleted, true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(l10n: l10n),
                  _LanguagePage(l10n: l10n),
                  _ReadyPage(l10n: l10n, onGetStarted: _completeOnboarding),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.secondary
                              : Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Next button (hidden on last page)
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(
                        l10n.onboardingNext,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Welcome ───

class _WelcomePage extends StatelessWidget {
  final AppLocalizations l10n;

  const _WelcomePage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveCenter(
      padding: const EdgeInsets.all(32.0),
      maxWidth: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_quote,
            size: 80,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingWelcomeTitle,
            style: AppTypography.textTheme.displayMedium!.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Language Selection ───

class _LanguagePage extends StatelessWidget {
  final AppLocalizations l10n;

  const _LanguagePage({required this.l10n});

  static const List<_LanguageItem> _languages = [
    _LanguageItem(locale: Locale('en'), flag: '\u{1F1EC}\u{1F1E7}', nameKey: 'english'),
    _LanguageItem(locale: Locale('tr'), flag: '\u{1F1F9}\u{1F1F7}', nameKey: 'turkish'),
    _LanguageItem(locale: Locale('de'), flag: '\u{1F1E9}\u{1F1EA}', nameKey: 'german'),
    _LanguageItem(locale: Locale('ru'), flag: '\u{1F1F7}\u{1F1FA}', nameKey: 'russian'),
    _LanguageItem(locale: Locale('es'), flag: '\u{1F1EA}\u{1F1F8}', nameKey: 'spanish'),
    _LanguageItem(locale: Locale('fr'), flag: '\u{1F1EB}\u{1F1F7}', nameKey: 'french'),
    _LanguageItem(locale: Locale('pt'), flag: '\u{1F1E7}\u{1F1F7}', nameKey: 'portuguese'),
    _LanguageItem(locale: Locale('it'), flag: '\u{1F1EE}\u{1F1F9}', nameKey: 'italian'),
    _LanguageItem(locale: Locale('ar'), flag: '\u{1F1F8}\u{1F1E6}', nameKey: 'arabic'),
    _LanguageItem(locale: Locale('zh'), flag: '\u{1F1E8}\u{1F1F3}', nameKey: 'chinese'),
    _LanguageItem(locale: Locale('ja'), flag: '\u{1F1EF}\u{1F1F5}', nameKey: 'japanese'),
    _LanguageItem(locale: Locale('ko'), flag: '\u{1F1F0}\u{1F1F7}', nameKey: 'korean'),
    _LanguageItem(locale: Locale('hi'), flag: '\u{1F1EE}\u{1F1F3}', nameKey: 'hindi'),
  ];

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveCenter(
      maxWidth: 500,
      child: Column(
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Text(
                  l10n.onboardingLanguageTitle,
                  style: AppTypography.textTheme.displaySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingLanguageDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                final currentLocale =
                    state is SettingsLoaded ? state.locale : null;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = currentLocale?.languageCode ==
                        lang.locale.languageCode;

                    return ListTile(
                      leading: Text(
                        lang.flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(_getLanguageName(l10n, lang.nameKey)),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        context
                            .read<SettingsBloc>()
                            .add(ChangeLanguageEvent(lang.locale));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageItem {
  final Locale locale;
  final String flag;
  final String nameKey;

  const _LanguageItem({
    required this.locale,
    required this.flag,
    required this.nameKey,
  });
}

// ─── Page 3: Ready ───

class _ReadyPage extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onGetStarted;

  const _ReadyPage({required this.l10n, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveCenter(
      padding: const EdgeInsets.all(32.0),
      maxWidth: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: colorScheme.secondary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingReadyTitle,
            style: AppTypography.textTheme.displayMedium!.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingReadyDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.onboardingGetStarted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
