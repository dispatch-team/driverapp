import 'package:driverapp/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('returns null for a valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain', () {
      expect(Validators.email('user@mail.example.co'), isNull);
    });

    test('returns error for null value', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.email('   '), isNotNull);
    });

    test('returns error when @ is missing', () {
      expect(Validators.email('userexample.com'), isNotNull);
    });

    test('returns error when domain is missing', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('returns error when TLD is missing', () {
      expect(Validators.email('user@example'), isNotNull);
    });
  });

  group('Validators.required', () {
    test('returns null for a non-empty value', () {
      expect(Validators.required('hello'), isNull);
    });

    test('returns error for null value', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('includes default field name in error message', () {
      final error = Validators.required('');
      expect(error, contains('This field'));
    });

    test('includes custom field name in error message', () {
      final error = Validators.required('', 'Username');
      expect(error, contains('Username'));
    });
  });

  group('Validators.minLength', () {
    test('returns null when value meets minimum length', () {
      expect(Validators.minLength('abcde', 5), isNull);
    });

    test('returns null when value exceeds minimum length', () {
      expect(Validators.minLength('abcdef', 5), isNull);
    });

    test('returns error when value is shorter than minimum', () {
      expect(Validators.minLength('abc', 5), isNotNull);
    });

    test('returns error for null value', () {
      expect(Validators.minLength(null, 3), isNotNull);
    });

    test('includes minimum length in error message', () {
      final error = Validators.minLength('ab', 5);
      expect(error, contains('5'));
    });

    test('includes custom field name in error message', () {
      final error = Validators.minLength('ab', 5, 'Password');
      expect(error, contains('Password'));
    });

    test('trims whitespace before checking length', () {
      // '  a  ' trimmed is 'a', length 1, below min 3
      expect(Validators.minLength('  a  ', 3), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('returns null for a valid local phone number', () {
      expect(Validators.phone('1234567'), isNull);
    });

    test('returns null for a valid international phone number', () {
      expect(Validators.phone('+1 800 555 0100'), isNull);
    });

    test('returns null for a phone with dashes', () {
      expect(Validators.phone('123-456-7890'), isNull);
    });

    test('returns error for null value', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.phone('   '), isNotNull);
    });

    test('returns error for a number that is too short', () {
      expect(Validators.phone('123'), isNotNull);
    });

    test('returns error for a number with letters', () {
      expect(Validators.phone('abc-defg'), isNotNull);
    });
  });
}
