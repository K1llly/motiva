import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/storage_keys.dart';

class FavoritesLocalDataSource {
  final Box<Map> userDataBox;

  FavoritesLocalDataSource({required this.userDataBox});

  Future<Set<String>> getFavoriteIds() async {
    final data = userDataBox.get(StorageKeys.favorites);
    if (data == null) return {};
    final ids = (data['ids'] as List?)?.cast<String>() ?? [];
    return ids.toSet();
  }

  Future<bool> toggleFavorite(String quoteId) async {
    final ids = await getFavoriteIds();
    final isFav = ids.contains(quoteId);

    if (isFav) {
      ids.remove(quoteId);
    } else {
      ids.add(quoteId);
    }

    await userDataBox.put(
      StorageKeys.favorites,
      {'ids': ids.toList()},
    );

    return !isFav; // returns true if now favorited
  }

  Future<bool> isFavorite(String quoteId) async {
    final ids = await getFavoriteIds();
    return ids.contains(quoteId);
  }
}
