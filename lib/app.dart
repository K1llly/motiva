import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'core/constants/storage_keys.dart';
import 'core/theme/app_font.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/quote/domain/entities/quote.dart';
import 'features/quote/presentation/bloc/quote_bloc.dart';
import 'features/quote/presentation/screens/home_screen.dart';
import 'features/quote/presentation/screens/quote_detail_screen.dart';
import 'features/home_widget/presentation/bloc/widget_settings_bloc.dart';
import 'features/home_widget/presentation/screens/widget_customization_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/favorites/presentation/screens/favorites_screen.dart';

class MotivaApp extends StatefulWidget {
  const MotivaApp({super.key});

  @override
  State<MotivaApp> createState() => _MotivaAppState();
}

class _MotivaAppState extends State<MotivaApp> with WidgetsBindingObserver {
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _disposeOnce() async {
    if (_disposed) return;
    _disposed = true;
    await di.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeOnce();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _disposeOnce();
    }
  }

  Widget _getHomeWidget() {
    final prefs = di.sl<SharedPreferences>();
    final onboardingCompleted =
        prefs.getBool(StorageKeys.onboardingCompleted) ?? false;
    if (onboardingCompleted) {
      return const HomeScreen();
    }
    return const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuoteBloc>(
          create: (_) => di.sl<QuoteBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => di.sl<FavoritesBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          if (previous is! SettingsLoaded || current is! SettingsLoaded) {
            return true;
          }
          return previous.locale != current.locale ||
              previous.themeMode != current.themeMode ||
              previous.appFontKey != current.appFontKey;
        },
        builder: (context, state) {
          final locale = state is SettingsLoaded ? state.locale : null;
          final themeMode = state is SettingsLoaded
              ? state.themeMode
              : ThemeMode.system;
          final appFont = state is SettingsLoaded
              ? AppFont.fromKey(state.appFontKey)
              : AppFont.classic;

          return MaterialApp(
            title: 'Motiva',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightThemeFor(appFont),
            darkTheme: AppTheme.darkThemeFor(appFont),
            themeMode: themeMode,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
              Locale('de'),
              Locale('ru'),
              Locale('es'),
              Locale('fr'),
              Locale('pt'),
              Locale('it'),
              Locale('ar'),
              Locale('zh'),
              Locale('ja'),
              Locale('ko'),
              Locale('hi'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: _getHomeWidget(),
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case '/quote-detail':
        final quote = settings.arguments as Quote;
        return MaterialPageRoute(
          builder: (_) => QuoteDetailScreen(quote: quote),
        );
      case '/widget-customization':
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (_) => di.sl<WidgetSettingsBloc>(),
            child: const WidgetCustomizationScreen(),
          ),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case '/favorites':
        return MaterialPageRoute(
          builder: (_) => const FavoritesScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
