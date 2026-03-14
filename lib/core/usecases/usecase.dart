import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Base UseCase interface following the Command pattern
/// Each use case does ONE thing (Single Responsibility)
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// For use cases that don't need parameters
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
