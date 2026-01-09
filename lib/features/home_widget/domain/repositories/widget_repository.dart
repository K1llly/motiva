import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class WidgetRepository {
  /// Update widget with new quote data
  Future<Either<Failure, void>> updateWidgetData({
    required String quoteText,
    required String author,
    required int dayNumber,
  });

  /// Register widget click callback
  Future<Either<Failure, void>> registerWidgetCallback();

  /// Get last widget update time
  Future<Either<Failure, DateTime?>> getLastUpdateTime();

  /// Trigger widget refresh after appearance changes
  Future<Either<Failure, void>> refreshWidget();
}
