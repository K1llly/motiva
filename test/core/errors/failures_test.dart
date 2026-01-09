import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/core/errors/failures.dart';

void main() {
  group('Failures', () {
    group('CacheFailure', () {
      test('should be a Failure', () {
        const failure = CacheFailure('error');
        expect(failure, isA<Failure>());
      });

      test('should store message correctly', () {
        const failure = CacheFailure('Cache error message');
        expect(failure.message, 'Cache error message');
      });

      test('should be equal when messages are the same', () {
        const failure1 = CacheFailure('error');
        const failure2 = CacheFailure('error');
        expect(failure1, equals(failure2));
      });

      test('props should contain message', () {
        const failure = CacheFailure('error');
        expect(failure.props, ['error']);
      });
    });

    group('WidgetFailure', () {
      test('should be a Failure', () {
        const failure = WidgetFailure('error');
        expect(failure, isA<Failure>());
      });

      test('should store message correctly', () {
        const failure = WidgetFailure('Widget error message');
        expect(failure.message, 'Widget error message');
      });
    });

    group('ShareFailure', () {
      test('should be a Failure', () {
        const failure = ShareFailure('error');
        expect(failure, isA<Failure>());
      });

      test('should store message correctly', () {
        const failure = ShareFailure('Share error message');
        expect(failure.message, 'Share error message');
      });
    });

    group('UnexpectedFailure', () {
      test('should be a Failure', () {
        const failure = UnexpectedFailure('error');
        expect(failure, isA<Failure>());
      });

      test('should store message correctly', () {
        const failure = UnexpectedFailure('Unexpected error message');
        expect(failure.message, 'Unexpected error message');
      });
    });

    group('ValidationFailure', () {
      test('should be a Failure', () {
        const failure = ValidationFailure('error');
        expect(failure, isA<Failure>());
      });

      test('should store message correctly', () {
        const failure = ValidationFailure('Validation error message');
        expect(failure.message, 'Validation error message');
      });
    });
  });
}
