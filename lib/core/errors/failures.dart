import 'package:equatable/equatable.dart';

/// Base failure class for domain layer errors
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure when cache operations fail
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure when widget operations fail
class WidgetFailure extends Failure {
  const WidgetFailure(super.message);
}

/// Failure when share operations fail
class ShareFailure extends Failure {
  const ShareFailure(super.message);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
