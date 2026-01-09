import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/quote/domain/entities/quote.dart';
import 'features/quote/presentation/bloc/quote_bloc.dart';
import 'features/quote/presentation/screens/home_screen.dart';
import 'features/quote/presentation/screens/quote_detail_screen.dart';
import 'features/streak/presentation/bloc/streak_bloc.dart';
import 'features/home_widget/presentation/bloc/widget_settings_bloc.dart';
import 'features/home_widget/presentation/screens/widget_customization_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

class MotivaApp extends StatelessWidget {
  const MotivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuoteBloc>(
          create: (_) => di.sl<QuoteBloc>(),
        ),
        BlocProvider<StreakBloc>(
          create: (_) => di.sl<StreakBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final locale = state is SettingsLoaded ? state.locale : null;

          return MaterialApp(
            title: 'Motiva',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: locale,
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
              Locale('de'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
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
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<WidgetSettingsBloc>(),
            child: const WidgetCustomizationScreen(),
          ),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
