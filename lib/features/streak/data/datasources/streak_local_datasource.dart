import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/streak_model.dart';

abstract class StreakLocalDataSource {
  Future<StreakModel> getStreak();
  Future<void> saveStreak(StreakModel streak);
  Future<void> resetStreak();
}

class StreakLocalDataSourceImpl implements StreakLocalDataSource {
  final Box<Map> streakBox;
  static const String _streakKey = 'current';

  StreakLocalDataSourceImpl({required this.streakBox});

  @override
  Future<StreakModel> getStreak() async {
    final data = streakBox.get(_streakKey);
    if (data == null) {
      // Return empty streak if none exists
      return StreakModel.empty();
    }
    try {
      return StreakModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw CacheException('Failed to parse streak data: $e');
    }
  }

  @override
  Future<void> saveStreak(StreakModel streak) async {
    await streakBox.put(_streakKey, streak.toJson());
  }

  @override
  Future<void> resetStreak() async {
    final emptyStreak = StreakModel.empty();
    await streakBox.put(_streakKey, emptyStreak.toJson());
  }
}
