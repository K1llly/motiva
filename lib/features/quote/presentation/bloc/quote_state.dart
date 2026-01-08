import 'package:equatable/equatable.dart';
import '../../domain/entities/quote.dart';

abstract class QuoteState extends Equatable {
  const QuoteState();

  @override
  List<Object?> get props => [];
}

class QuoteInitial extends QuoteState {
  const QuoteInitial();
}

class QuoteLoading extends QuoteState {
  const QuoteLoading();
}

class QuoteLoaded extends QuoteState {
  final Quote quote;
  final bool canViewMeaning;

  const QuoteLoaded({
    required this.quote,
    this.canViewMeaning = true,
  });

  @override
  List<Object?> get props => [quote, canViewMeaning];
}

class QuoteError extends QuoteState {
  final String message;

  const QuoteError(this.message);

  @override
  List<Object?> get props => [message];
}
