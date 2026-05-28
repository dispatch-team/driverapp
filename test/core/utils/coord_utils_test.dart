import 'package:driverapp/core/utils/coord_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryParseCoordinates', () {
    group('plain "lat;lng" format', () {
      test('parses valid positive coordinates', () {
        expect(tryParseCoordinates('9.025;38.747'), (9.025, 38.747));
      });

      test('parses negative coordinates', () {
        expect(tryParseCoordinates('-33.865;151.209'), (-33.865, 151.209));
      });

      test('parses integer-valued coordinates', () {
        expect(tryParseCoordinates('0;0'), (0.0, 0.0));
      });

      test('trims whitespace around each part', () {
        expect(tryParseCoordinates('  9.025  ;  38.747  '), (9.025, 38.747));
      });
    });

    group('labeled "Label | lat;lng" format', () {
      test('extracts coordinates after the pipe', () {
        expect(
          tryParseCoordinates('Addis Ababa | 9.025;38.747'),
          (9.025, 38.747),
        );
      });

      test('trims whitespace from the coordinate part after pipe', () {
        expect(
          tryParseCoordinates('Bole |  8.99 ; 38.80 '),
          (8.99, 38.80),
        );
      });
    });

    group('invalid input returns null', () {
      test('returns null when there is no semicolon', () {
        expect(tryParseCoordinates('notacoord'), isNull);
      });

      test('returns null when latitude is not a number', () {
        expect(tryParseCoordinates('abc;38.747'), isNull);
      });

      test('returns null when longitude is not a number', () {
        expect(tryParseCoordinates('9.025;xyz'), isNull);
      });

      test('returns null for an empty string', () {
        expect(tryParseCoordinates(''), isNull);
      });

      test('returns null when there are more than two semicolon-separated parts',
          () {
        expect(tryParseCoordinates('9.025;38.747;extra'), isNull);
      });

      test('returns null when labeled format has non-numeric coords', () {
        expect(tryParseCoordinates('Label | bad;data'), isNull);
      });
    });
  });

  group('parseAddressLabel', () {
    test('returns the trimmed label before the pipe', () {
      expect(
        parseAddressLabel('Addis Ababa | 9.025;38.747'),
        'Addis Ababa',
      );
    });

    test('trims whitespace from label', () {
      expect(parseAddressLabel('  Bole  | 9.025;38.747'), 'Bole');
    });

    test('returns the original string when no pipe is present', () {
      expect(parseAddressLabel('Just an address'), 'Just an address');
    });

    test('returns empty string for empty input', () {
      expect(parseAddressLabel(''), '');
    });

    test('uses only the first pipe when multiple pipes are present', () {
      // Only text before the first | is the label
      expect(parseAddressLabel('Label | extra | 9;38'), 'Label');
    });
  });
}
