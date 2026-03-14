import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/quote_translation_service.dart';
import '../../domain/usecases/get_daily_quote.dart';
import '../../../home_widget/domain/usecases/update_widget_data.dart';
import 'quote_event.dart';
import 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final GetDailyQuote getDailyQuote;
  final UpdateWidgetData updateWidgetData;
  final int Function() getCurrentDayNumber;
  final QuoteTranslationService translationService;

  QuoteBloc({
    required this.getDailyQuote,
    required this.updateWidgetData,
    required this.getCurrentDayNumber,
    required this.translationService,
  }) : super(const QuoteInitial()) {
    on<LoadDailyQuoteEvent>(_onLoadDailyQuote, transformer: droppable());
    on<RefreshQuoteEvent>(_onRefreshQuote, transformer: droppable());
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
        final translatedText = translationService.getText(quote.id, quote.text);
        final currentLocale = translationService.currentLocale;

        await updateWidgetData(UpdateWidgetParams(
          quoteText: translatedText,
          author: quote.author,
          dayNumber: dayNumber,
        ));

        emit(QuoteLoaded(quote: quote, locale: currentLocale));
      },
    );
  }

  Future<void> _onRefreshQuote(
    RefreshQuoteEvent event,
    Emitter<QuoteState> emit,
  ) async {
    await _onLoadDailyQuote(const LoadDailyQuoteEvent(), emit);
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      CacheFailure() => 'Could not load quote. Please try again.',
      WidgetFailure() => 'Widget update failed. Quote loaded successfully.',
      _ => 'An unexpected error occurred.',
    };
  }
}
