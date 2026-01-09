import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/features/sharing/domain/entities/share_content.dart';

void main() {
  group('ShareContent Entity', () {
    const tShareContent = ShareContent(
      text: 'Test quote - Author',
      platform: SharePlatform.instagram,
    );

    test('should be a valid ShareContent instance', () {
      expect(tShareContent, isA<ShareContent>());
    });

    test('should have correct properties', () {
      expect(tShareContent.text, 'Test quote - Author');
      expect(tShareContent.imageUrl, isNull);
      expect(tShareContent.platform, SharePlatform.instagram);
    });

    test('should allow imageUrl to be set', () {
      const contentWithImage = ShareContent(
        text: 'Test quote',
        imageUrl: 'https://example.com/image.png',
        platform: SharePlatform.twitter,
      );

      expect(contentWithImage.imageUrl, 'https://example.com/image.png');
    });

    group('SharePlatform enum', () {
      test('should have all expected platforms', () {
        expect(SharePlatform.values.length, 4);
        expect(SharePlatform.values, contains(SharePlatform.instagram));
        expect(SharePlatform.values, contains(SharePlatform.twitter));
        expect(SharePlatform.values, contains(SharePlatform.whatsapp));
        expect(SharePlatform.values, contains(SharePlatform.other));
      });
    });

    group('Equatable', () {
      test('should return true when comparing identical content', () {
        const content1 = ShareContent(
          text: 'Test',
          platform: SharePlatform.instagram,
        );
        const content2 = ShareContent(
          text: 'Test',
          platform: SharePlatform.instagram,
        );

        expect(content1, equals(content2));
      });

      test('should return false when comparing different content', () {
        const content1 = ShareContent(
          text: 'Test',
          platform: SharePlatform.instagram,
        );
        const content2 = ShareContent(
          text: 'Different',
          platform: SharePlatform.instagram,
        );

        expect(content1, isNot(equals(content2)));
      });

      test('should return false when platforms differ', () {
        const content1 = ShareContent(
          text: 'Test',
          platform: SharePlatform.instagram,
        );
        const content2 = ShareContent(
          text: 'Test',
          platform: SharePlatform.twitter,
        );

        expect(content1, isNot(equals(content2)));
      });

      test('props should contain all properties', () {
        expect(tShareContent.props, [
          'Test quote - Author',
          null,
          SharePlatform.instagram,
        ]);
      });
    });
  });
}
