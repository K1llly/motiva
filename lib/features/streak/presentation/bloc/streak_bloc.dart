import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_streak.dart';
import '../../domain/usecases/increment_streak.dart';
import '../../domain/usecases/reset_streak.dart';
import 'streak_event.dart';
import 'streak_state.dart';

class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final GetCurrentStreak getCurrentStreak;
  final IncrementStreak incrementStreak;
  final ResetStreak resetStreak;

  StreakBloc({
    required this.getCurrentStreak,
    required this.incrementStreak,
    required this.resetStreak,
  }) : super(const StreakInitial()) {
    on<LoadStreakEvent>(_onLoadStreak);
    on<IncrementStreakEvent>(_onIncrementStreak);
    on<ResetStreakEvent>(_onResetStreak);
  }

  Future<void> _onLoadStreak(
    LoadStreakEvent event,
    Emitter<StreakState> emit,
  ) async {
    emit(const StreakLoading());

    final result = await getCurrentStreak(const NoParams());

    result.fold(
      (failure) => emit(StreakError(failure.message)),
      (streak) => emit(StreakLoaded(streak)),
    );
  }

  Future<void> _onIncrementStreak(
    IncrementStreakEvent event,
    Emitter<StreakState> emit,
  ) async {
    final result = await incrementStreak(const NoParams());

    result.fold(
      (failure) => emit(StreakError(failure.message)),
      (streak) => emit(StreakLoaded(streak)),
    );
  }

  Future<void> _onResetStreak(
    ResetStreakEvent event,
    Emitter<StreakState> emit,
  ) async {
    final result = await resetStreak(const NoParams());

    result.fold(
      (failure) => emit(StreakError(failure.message)),
      (streak) => emit(StreakLoaded(streak)),
    );
  }
}
