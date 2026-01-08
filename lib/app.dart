import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'features/quote/domain/entities/quote.dart';
import 'features/quote/presentation/bloc/quote_bloc.dart';
import 'features/quote/presentation/screens/home_screen.dart';
import 'features/quote/presentation/screens/quote_detail_screen.dart';
import 'features/streak/presentation/bloc/streak_bloc.dart';

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
      ],
      child: MaterialApp(
        title: 'Motiva',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        onGenerateRoute: _onGenerateRoute,
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
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
