import '../../domain/entities/quote.dart';

/// Data Transfer Object - handles serialization/deserialization
/// Extends entity to maintain compatibility with domain layer
class QuoteModel extends Quote {
  const QuoteModel({
    required super.id,
    required super.text,
    required super.author,
    required super.meaning,
    required super.dayNumber,
    super.displayedAt,
  });

  /// Factory constructor from JSON (database or API)
  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      meaning: json['meaning'] as String,
      dayNumber: json['day_number'] as int,
      displayedAt: json['displayed_at'] != null
          ? DateTime.parse(json['displayed_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'meaning': meaning,
      'day_number': dayNumber,
      'displayed_at': displayedAt?.toIso8601String(),
    };
  }

  /// Convert from entity (domain -> data)
  factory QuoteModel.fromEntity(Quote quote) {
    return QuoteModel(
      id: quote.id,
      text: quote.text,
      author: quote.author,
      meaning: quote.meaning,
      dayNumber: quote.dayNumber,
      displayedAt: quote.displayedAt,
    );
  }

  /// Create a copy with updated fields
  QuoteModel copyWith({
    String? id,
    String? text,
    String? author,
    String? meaning,
    int? dayNumber,
    DateTime? displayedAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      meaning: meaning ?? this.meaning,
      dayNumber: dayNumber ?? this.dayNumber,
      displayedAt: displayedAt ?? this.displayedAt,
    );
  }
}
