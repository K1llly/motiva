import 'package:equatable/equatable.dart';

abstract class QuoteEvent extends Equatable {
  const QuoteEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Load today's quote
class LoadDailyQuoteEvent extends QuoteEvent {
  const LoadDailyQuoteEvent();
}

/// Event: User viewed the quote meaning
class ViewQuoteMeaningEvent extends QuoteEvent {
  final String quoteId;

  const ViewQuoteMeaningEvent(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}

/// Event: Refresh quote (for widget sync)
class RefreshQuoteEvent extends QuoteEvent {
  const RefreshQuoteEvent();
}
