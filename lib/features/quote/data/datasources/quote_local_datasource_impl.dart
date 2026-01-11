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

  QuoteLocalDataSourceImpl({
    required this.quoteBox,
    required this.prefs,
  });

  @override
  Future<QuoteModel> getQuoteForDay(int dayNumber) async {
    // Get or create shuffled order for this user
    final shuffledOrder = await _getOrCreateShuffledOrder();

    // Use modulo for cycling through quotes (when user has more days than quotes)
    final index = (dayNumber - 1) % shuffledOrder.length;
    final quoteNumber = shuffledOrder[index];

    // Use direct key lookup instead of iterating all values (saves memory)
    final quoteId = 'q${quoteNumber.toString().padLeft(3, '0')}';
    final quoteData = quoteBox.get(quoteId);

    if (quoteData == null) {
      throw CacheException('Quote not found for day $quoteNumber');
    }

    return QuoteModel.fromJson(Map<String, dynamic>.from(quoteData));
  }

  /// Get existing shuffled order or create a new one
  Future<List<int>> _getOrCreateShuffledOrder() async {
    final savedOrder = prefs.getStringList(StorageKeys.shuffledQuoteOrder);

    if (savedOrder != null && savedOrder.isNotEmpty) {
      return savedOrder.map((s) => int.parse(s)).toList();
    }

    // Create new shuffled order unique to this user
    final order = List<int>.generate(AppConstants.totalQuotes, (i) => i + 1);
    order.shuffle(Random());

    // Save for persistence
    await prefs.setStringList(
      StorageKeys.shuffledQuoteOrder,
      order.map((i) => i.toString()).toList(),
    );

    return order;
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
}
