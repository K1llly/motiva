import 'package:equatable/equatable.dart';
import '../../domain/entities/streak.dart';

abstract class StreakState extends Equatable {
  const StreakState();

  @override
  List<Object?> get props => [];
}

class StreakInitial extends StreakState {
  const StreakInitial();
}

class StreakLoading extends StreakState {
  const StreakLoading();
}

class StreakLoaded extends StreakState {
  final Streak streak;

  const StreakLoaded(this.streak);

  @override
  List<Object?> get props => [streak];
}

class StreakError extends StreakState {
  final String message;

  const StreakError(this.message);

  @override
  List<Object?> get props => [message];
}
