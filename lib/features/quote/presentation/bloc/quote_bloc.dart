import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_daily_quote.dart';
import '../../../streak/domain/usecases/increment_streak.dart';
import '../../../home_widget/domain/usecases/update_widget_data.dart';
import 'quote_event.dart';
import 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final GetDailyQuote getDailyQuote;
  final IncrementStreak incrementStreak;
  final UpdateWidgetData updateWidgetData;
  final int Function() getCurrentDayNumber;

  QuoteBloc({
    required this.getDailyQuote,
    required this.incrementStreak,
    required this.updateWidgetData,
    required this.getCurrentDayNumber,
  }) : super(const QuoteInitial()) {
    on<LoadDailyQuoteEvent>(_onLoadDailyQuote);
    on<ViewQuoteMeaningEvent>(_onViewQuoteMeaning);
    on<RefreshQuoteEvent>(_onRefreshQuote);
  }

  Future<void> _onLoadDailyQuote(
    LoadDailyQuoteEvent event,
    Emitter<QuoteState> emit,
  ) async {
    emit(const QuoteLoading());

    final dayNumber = getCurrentDayNumber();
    final result = await getDailyQuote(
      GetDailyQuoteParams(dayNumber: dayNumber),
    );

    await result.fold(
      (failure) async {
        emit(QuoteError(_mapFailureToMessage(failure)));
      },
      (quote) async {
        // Increment streak when quote is loaded
        await incrementStreak(const NoParams());

        // Update widget with new quote
        await updateWidgetData(UpdateWidgetParams(
          quoteText: quote.text,
          author: quote.author,
          dayNumber: dayNumber,
        ));

        emit(QuoteLoaded(quote: quote));
      },
    );
  }

  Future<void> _onViewQuoteMeaning(
    ViewQuoteMeaningEvent event,
    Emitter<QuoteState> emit,
  ) async {
    // Handle viewing meaning - could trigger navigation
    // or update state to show meaning
  }

  Future<void> _onRefreshQuote(
    RefreshQuoteEvent event,
    Emitter<QuoteState> emit,
  ) async {
    add(const LoadDailyQuoteEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      CacheFailure() => 'Could not load quote. Please try again.',
      WidgetFailure() => 'Widget update failed. Quote loaded successfully.',
      _ => 'An unexpected error occurred.',
    };
  }
}
