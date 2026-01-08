import 'package:equatable/equatable.dart';

abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}

class LoadStreakEvent extends StreakEvent {
  const LoadStreakEvent();
}

class IncrementStreakEvent extends StreakEvent {
  const IncrementStreakEvent();
}

class ResetStreakEvent extends StreakEvent {
  const ResetStreakEvent();
}
