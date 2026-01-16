import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/quote.dart';
import '../bloc/quote_bloc.dart';
import '../bloc/quote_event.dart';
import '../bloc/quote_state.dart';
import '../widgets/quote_card.dart';
import '../../../streak/presentation/bloc/streak_bloc.dart';
import '../../../streak/presentation/bloc/streak_event.dart';
import '../../../streak/presentation/widgets/streak_counter.dart';
import '../../../sharing/presentation/widgets/share_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load daily quote when screen opens
    context.read<QuoteBloc>().add(const LoadDailyQuoteEvent());
  }

  @override
  void dispose() {
    // Future-proof: add any controller/subscription cleanup here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.widgets_outlined),
          tooltip: l10n.widgetAppearance,
          onPressed: () => Navigator.pushNamed(context, '/widget-customization'),
        ),
        actions: [
          const StreakCounter(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<QuoteBloc, QuoteState>(
        listener: (context, state) {
          // Reload streak after quote is loaded (streak was incremented)
          if (state is QuoteLoaded) {
            context.read<StreakBloc>().add(const LoadStreakEvent());
          }
        },
        child: BlocBuilder<QuoteBloc, QuoteState>(
          builder: (context, state) {
            if (state is QuoteInitial || state is QuoteLoading) {
              return const _LoadingView();
            } else if (state is QuoteLoaded) {
              return _QuoteView(
                quote: state.quote,
                onShare: () => _showShareSheet(context, state.quote),
                onViewMeaning: () => _navigateToMeaning(context, state.quote),
              );
            } else if (state is QuoteError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context.read<QuoteBloc>().add(
                      const LoadDailyQuoteEvent(),
                    ),
              );
            }
            return const _LoadingView();
          },
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, Quote quote) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ShareBottomSheet(quote: quote),
    );
  }

  void _navigateToMeaning(BuildContext context, Quote quote) {
    Navigator.pushNamed(
      context,
      '/quote-detail',
      arguments: quote,
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _QuoteView extends StatelessWidget {
  final Quote quote;
  final VoidCallback onShare;
  final VoidCallback onViewMeaning;

  const _QuoteView({
    required this.quote,
    required this.onShare,
    required this.onViewMeaning,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: QuoteCard(quote: quote),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: onViewMeaning,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(l10n.viewMeaning),
              ),
              ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share),
                label: Text(l10n.share),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Cache theme references once
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
