import 'dart:math';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/quote_model.dart';
import 'quote_local_datasource.dart';

class QuoteLocalDataSourceImpl implements QuoteLocalDataSource {
  final Box<Map> quoteBox;
  final SharedPreferences prefs;

  // Memory cache for user seed
  int? _userSeedCache;

  QuoteLocalDataSourceImpl({
    required this.quoteBox,
    required this.prefs,
  });

  @override
  Future<QuoteModel> getQuoteForDay(int dayNumber) async {
    return _quoteForDate(DateTime.now());
  }

  @override
  Future<QuoteModel> getQuoteForDate(DateTime date) async {
    return _quoteForDate(date);
  }

  Future<QuoteModel> _quoteForDate(DateTime date) async {
    final seed = await _getOrCreateUserSeed();

    // Deterministic random index from date + user seed
    // Must match the iOS widget formula: abs(dateKey ^ seed) % totalQuotes
    final dateKey = date.year * 10000 + date.month * 100 + date.day;
    final combined = dateKey ^ seed;
    final quoteIndex = (combined.abs() % AppConstants.totalQuotes) + 1;

    final quoteId = 'q${quoteIndex.toString().padLeft(3, '0')}';
    final quoteData = quoteBox.get(quoteId);

    if (quoteData == null) {
      throw CacheException('Quote not found for index $quoteIndex');
    }

    return QuoteModel.fromJson(Map<String, dynamic>.from(quoteData));
  }

  /// Get existing user seed or create a new one
  Future<int> _getOrCreateUserSeed() async {
    if (_userSeedCache != null) {
      return _userSeedCache!;
    }

    final saved = prefs.getInt(StorageKeys.userSeed);
    if (saved != null) {
      _userSeedCache = saved;
      return saved;
    }

    // Create new seed unique to this user
    final newSeed = Random().nextInt(1 << 31);
    _userSeedCache = newSeed;
    await prefs.setInt(StorageKeys.userSeed, newSeed);

    // Clean up legacy shuffled order if it exists
    await prefs.remove(StorageKeys.shuffledQuoteOrder);

    return newSeed;
  }

  @override
  Future<QuoteModel> getQuoteById(String id) async {
    final quoteData = quoteBox.get(id);
    if (quoteData == null) {
      throw CacheException('Quote not found with id: $id');
    }
    return QuoteModel.fromJson(Map<String, dynamic>.from(quoteData));
  }

  @override
  Future<List<QuoteModel>> getAllQuotes() async {
    return quoteBox.values
        .map((q) => QuoteModel.fromJson(Map<String, dynamic>.from(q)))
        .toList();
  }

  @override
  Future<void> markQuoteAsDisplayed(String quoteId, DateTime displayedAt) async {
    final quoteData = quoteBox.get(quoteId);
    if (quoteData != null) {
      final updatedData = Map<String, dynamic>.from(quoteData);
      updatedData['displayed_at'] = displayedAt.toIso8601String();
      await quoteBox.put(quoteId, updatedData);
    }
  }

  @override
  Future<void> initializeQuotes(List<QuoteModel> quotes) async {
    final Map<String, Map<String, dynamic>> quotesMap = {};
    for (final quote in quotes) {
      quotesMap[quote.id] = quote.toJson();
    }
    await quoteBox.putAll(quotesMap);
  }

  @override
  Future<bool> hasQuotes() async {
    return quoteBox.isNotEmpty;
  }

  @override
  Future<List<int>> getShuffledOrder() async {
    // Legacy method - return empty list, no longer used
    return [];
  }

  /// Get the user seed (for syncing to widget)
  Future<int> getUserSeed() async {
    return _getOrCreateUserSeed();
  }
}
