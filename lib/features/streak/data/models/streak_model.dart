import '../../domain/entities/streak.dart';

class StreakModel extends Streak {
  const StreakModel({
    required super.currentStreak,
    required super.longestStreak,
    required super.startDate,
    required super.lastActiveDate,
    required super.totalQuotesRead,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] as int,
      longestStreak: json['longest_streak'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      lastActiveDate: DateTime.parse(json['last_active_date'] as String),
      totalQuotesRead: json['total_quotes_read'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'start_date': startDate.toIso8601String(),
      'last_active_date': lastActiveDate.toIso8601String(),
      'total_quotes_read': totalQuotesRead,
    };
  }

  factory StreakModel.fromEntity(Streak streak) {
    return StreakModel(
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      startDate: streak.startDate,
      lastActiveDate: streak.lastActiveDate,
      totalQuotesRead: streak.totalQuotesRead,
    );
  }

  factory StreakModel.empty() {
    final now = DateTime.now();
    // Set lastActiveDate to yesterday so first launch will increment
    final yesterday = now.subtract(const Duration(days: 1));
    return StreakModel(
      currentStreak: 0,
      longestStreak: 0,
      startDate: now,
      lastActiveDate: yesterday,
      totalQuotesRead: 0,
    );
  }
}
