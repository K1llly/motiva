import 'package:equatable/equatable.dart';

/// Quote entity - represents the core business object
/// Immutable and contains only business logic relevant properties
class Quote extends Equatable {
  final String id;
  final String text;
  final String author;
  final String meaning;
  final int dayNumber;
  final DateTime? displayedAt;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.meaning,
    required this.dayNumber,
    this.displayedAt,
  });

  /// Business logic: Check if quote was displayed today
  bool get wasDisplayedToday {
    if (displayedAt == null) return false;
    final now = DateTime.now();
    return displayedAt!.year == now.year &&
        displayedAt!.month == now.month &&
        displayedAt!.day == now.day;
  }

  @override
  List<Object?> get props => [id, text, author, meaning, dayNumber, displayedAt];
}
