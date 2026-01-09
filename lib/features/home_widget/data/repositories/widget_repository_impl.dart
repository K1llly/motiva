import 'package:dartz/dartz.dart';
import 'package:home_widget/home_widget.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/widget_repository.dart';
import '../datasources/widget_datasource.dart';

class WidgetRepositoryImpl implements WidgetRepository {
  final WidgetDataSource dataSource;

  WidgetRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> updateWidgetData({
    required String quoteText,
    required String author,
    required int dayNumber,
  }) async {
    try {
      await dataSource.saveWidgetData(
        quoteText: quoteText,
        author: author,
        dayNumber: dayNumber,
      );
      await dataSource.updateWidget();
      return const Right(null);
    } on WidgetException catch (e) {
      return Left(WidgetFailure(e.message));
    } catch (e) {
      return Left(WidgetFailure('Failed to update widget: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> registerWidgetCallback() async {
    try {
      HomeWidget.widgetClicked.listen((uri) {
        // Handle widget tap - could navigate to specific screen
        if (uri != null) {
          // Process deep link
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(WidgetFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastUpdateTime() async {
    try {
      final lastUpdate = await dataSource.getLastUpdateTime();
      return Right(lastUpdate);
    } catch (e) {
      return Left(WidgetFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshWidget() async {
    try {
      await dataSource.updateWidget();
      return const Right(null);
    } on WidgetException catch (e) {
      return Left(WidgetFailure(e.message));
    } catch (e) {
      return Left(WidgetFailure('Failed to refresh widget: ${e.toString()}'));
    }
  }
}
