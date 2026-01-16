import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/streak_bloc.dart';
import '../bloc/streak_event.dart';
import '../bloc/streak_state.dart';

class StreakCounter extends StatefulWidget {
  const StreakCounter({super.key});

  @override
  State<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends State<StreakCounter> {
  @override
  void initState() {
    super.initState();
    context.read<StreakBloc>().add(const LoadStreakEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Cache theme references once to avoid repeated lookups
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.secondary;
    final containerColor = secondaryColor.withValues(alpha: 0.1);

    return BlocBuilder<StreakBloc, StreakState>(
      buildWhen: (previous, current) {
        // Rebuild on state type changes (loading -> loaded, etc.)
        if (previous.runtimeType != current.runtimeType) {
          return true;
        }
        // Only skip rebuild when streak count is unchanged between loaded states
        if (previous is StreakLoaded && current is StreakLoaded) {
          return previous.streak.currentStreak != current.streak.currentStreak;
        }
        return true;
      },
      builder: (context, state) {
        final streakCount = state is StreakLoaded ? state.streak.currentStreak : 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 20,
                color: secondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '$streakCount',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
