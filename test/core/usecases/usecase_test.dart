import 'package:flutter_test/flutter_test.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';

void main() {
  group('NoParams', () {
    test('should be instantiable', () {
      const noParams = NoParams();
      expect(noParams, isA<NoParams>());
    });

    test('should be usable as a const', () {
      const params1 = NoParams();
      const params2 = NoParams();
      // Both const instances should be identical
      expect(identical(params1, params2), true);
    });
  });
}
