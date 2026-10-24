import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/core/utils/safe_convert.dart';

void main() {
  group('SafeConvert Utility Tests', () {
    test('parseInt handles null, ints, doubles, strings and edge cases', () {
      expect(SafeConvert.parseInt(null), 0);
      expect(SafeConvert.parseInt(42), 42);
      expect(SafeConvert.parseInt(42.0), 42);
      expect(SafeConvert.parseInt(42.8), 42);
      expect(SafeConvert.parseInt('150'), 150);
      expect(SafeConvert.parseInt(' 150 '), 150);
      expect(SafeConvert.parseInt('150.99'), 150);
      expect(SafeConvert.parseInt('', defaultValue: -1), -1);
      expect(SafeConvert.parseInt('invalid', defaultValue: 10), 10);
      expect(SafeConvert.parseInt(double.nan, defaultValue: 5), 5);
      expect(SafeConvert.parseInt(double.infinity, defaultValue: 5), 5);
    });

    test('parseDouble handles various numeric representations and strings', () {
      expect(SafeConvert.parseDouble(null), 0.0);
      expect(SafeConvert.parseDouble(10), 10.0);
      expect(SafeConvert.parseDouble(10.5), 10.5);
      expect(SafeConvert.parseDouble('5.50'), 5.50);
      expect(SafeConvert.parseDouble(' 12.34 '), 12.34);
      expect(SafeConvert.parseDouble(''), 0.0);
      expect(SafeConvert.parseDouble('abc', defaultValue: 1.5), 1.5);
    });

    test('parseRequiredFinancialAmount validates and throws on corrupt financial values', () {
      expect(SafeConvert.parseRequiredFinancialAmount(100.5, fieldName: 'amount'), 100.5);
      expect(SafeConvert.parseRequiredFinancialAmount('250.75', fieldName: 'amount'), 250.75);
      expect(() => SafeConvert.parseRequiredFinancialAmount(null, fieldName: 'coin_balance'), throwsA(isA<FormatException>()));
      expect(() => SafeConvert.parseRequiredFinancialAmount('not-a-number', fieldName: 'coin_balance'), throwsA(isA<FormatException>()));
    });
  });
}
