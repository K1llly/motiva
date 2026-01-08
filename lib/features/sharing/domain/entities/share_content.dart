import 'package:equatable/equatable.dart';

enum SharePlatform {
  instagram,
  twitter,
  whatsapp,
  other,
}

class ShareContent extends Equatable {
  final String text;
  final String? imageUrl;
  final SharePlatform platform;

  const ShareContent({
    required this.text,
    this.imageUrl,
    required this.platform,
  });

  @override
  List<Object?> get props => [text, imageUrl, platform];
}
