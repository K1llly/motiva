import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime startDate;
  final DateTime lastActiveDate;
  final int totalQuotesRead;

  const Streak({
    required this.currentStreak,
    required this.longestStreak,
    required this.startDate,
    required this.lastActiveDate,
    required this.totalQuotesRead,
  });

  /// Create an empty/initial streak
  factory Streak.empty() {
    final now = DateTime.now();
    return Streak(
      currentStreak: 0,
      longestStreak: 0,
      startDate: now,
      lastActiveDate: now,
      totalQuotesRead: 0,
    );
  }

  /// Business logic: Check if streak is still active
  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastActiveDate).inDays;
    return difference <= 1;
  }

  /// Business logic: Days since installation
  int get daysSinceStart {
    return DateTime.now().difference(startDate).inDays + 1;
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        startDate,
        lastActiveDate,
        totalQuotesRead,
      ];
}
