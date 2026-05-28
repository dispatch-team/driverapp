import 'package:driverapp/data/models/shipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ─── Fixtures ────────────────────────────────────────────────────────────────

  Map<String, dynamic> fullJson() => {
        'id': 10,
        'code': 'SHP-001',
        'merchant_id': 5,
        'merchant_user_id': 'usr-99',
        'description': 'Fragile electronics',
        'weight_kg': 2.5,
        'dimensions': '30x20x10',
        'total_fee': 150.0,
        'status': 'in_transit',
        'remark': 'Handle with care',
        'courier_company_id': 3,
        'assigned_driver_id': 7,
        'start_address': '123 Pickup St',
        'start_address_contact_name': 'Alice',
        'start_address_phone_number': '+1111111111',
        'start_address_additional_contact': 'alt-alice',
        'end_address': '456 Delivery Ave',
        'end_address_contact_name': 'Bob',
        'end_address_phone_number': '+2222222222',
        'end_address_additional_contact': 'alt-bob',
        'rating': 4.8,
        'webhook_url': 'https://example.com/webhook',
        'created_at': '2024-01-15T10:00:00.000Z',
        'items': ['item1', 'item2'],
        'delivered_at': '2024-01-16T14:30:00.000Z',
        'assigned_to_courier_at': '2024-01-15T11:00:00.000Z',
        'assigned_to_driver_at': '2024-01-15T12:00:00.000Z',
        'picked_up_at': '2024-01-15T13:00:00.000Z',
        'in_transit_at': '2024-01-15T14:00:00.000Z',
        'failed_at': null,
        'returned_at': null,
        'cancelled_at': null,
      };

  // ─── ShipmentStatus.fromString ────────────────────────────────────────────────

  group('ShipmentStatus.fromString', () {
    test('parses "pending"', () {
      expect(ShipmentStatus.fromString('pending'), ShipmentStatus.pending);
    });

    test('parses "assigned_to_courier"', () {
      expect(ShipmentStatus.fromString('assigned_to_courier'),
          ShipmentStatus.assignedToCourier);
    });

    test('parses "assigned_to_driver"', () {
      expect(ShipmentStatus.fromString('assigned_to_driver'),
          ShipmentStatus.assignedToDriver);
    });

    test('parses "in_transit"', () {
      expect(ShipmentStatus.fromString('in_transit'), ShipmentStatus.inTransit);
    });

    test('parses "delivered"', () {
      expect(ShipmentStatus.fromString('delivered'), ShipmentStatus.delivered);
    });

    test('parses "failed"', () {
      expect(ShipmentStatus.fromString('failed'), ShipmentStatus.failed);
    });

    test('parses "returned"', () {
      expect(ShipmentStatus.fromString('returned'), ShipmentStatus.returned);
    });

    test('parses "cancelled"', () {
      expect(ShipmentStatus.fromString('cancelled'), ShipmentStatus.cancelled);
    });

    test('falls back to pending for unknown value', () {
      expect(ShipmentStatus.fromString('unknown_value'), ShipmentStatus.pending);
    });

    test('falls back to pending for empty string', () {
      expect(ShipmentStatus.fromString(''), ShipmentStatus.pending);
    });
  });

  // ─── ShipmentStatus.toApiString ──────────────────────────────────────────────

  group('ShipmentStatus.toApiString', () {
    test('round-trips all statuses through fromString', () {
      for (final status in ShipmentStatus.values) {
        expect(ShipmentStatus.fromString(status.toApiString), status,
            reason: '${status.toApiString} should round-trip back to $status');
      }
    });
  });

  // ─── ShipmentStatus.displayLabel ─────────────────────────────────────────────

  group('ShipmentStatus.displayLabel', () {
    test('pending label', () {
      expect(ShipmentStatus.pending.displayLabel, 'Pending');
    });

    test('assignedToCourier label', () {
      expect(ShipmentStatus.assignedToCourier.displayLabel, 'Courier Assigned');
    });

    test('assignedToDriver label', () {
      expect(
          ShipmentStatus.assignedToDriver.displayLabel, 'Assigned to Driver');
    });

    test('inTransit label', () {
      expect(ShipmentStatus.inTransit.displayLabel, 'In Transit');
    });

    test('delivered label', () {
      expect(ShipmentStatus.delivered.displayLabel, 'Delivered');
    });

    test('failed label', () {
      expect(ShipmentStatus.failed.displayLabel, 'Failed');
    });

    test('returned label', () {
      expect(ShipmentStatus.returned.displayLabel, 'Returned');
    });

    test('cancelled label', () {
      expect(ShipmentStatus.cancelled.displayLabel, 'Cancelled');
    });

    test('every status has a non-empty label', () {
      for (final status in ShipmentStatus.values) {
        expect(status.displayLabel, isNotEmpty,
            reason: '$status should have a non-empty label');
      }
    });
  });

  // ─── ShipmentStatus.color ────────────────────────────────────────────────────

  group('ShipmentStatus.color', () {
    test('pending is yellow', () {
      expect(ShipmentStatus.pending.color, const Color(0xFFFBBC04));
    });

    test('delivered is green', () {
      expect(ShipmentStatus.delivered.color, const Color(0xFF34A853));
    });

    test('failed is red', () {
      expect(ShipmentStatus.failed.color, const Color(0xFFEA4335));
    });

    test('returned is red', () {
      expect(ShipmentStatus.returned.color, const Color(0xFFEA4335));
    });

    test('cancelled is red', () {
      expect(ShipmentStatus.cancelled.color, const Color(0xFFEA4335));
    });

    test('every status has a non-null color', () {
      for (final status in ShipmentStatus.values) {
        expect(status.color, isNotNull,
            reason: '$status should have a color');
      }
    });
  });

  // ─── ShipmentStatus.isActive ─────────────────────────────────────────────────

  group('ShipmentStatus.isActive', () {
    test('assignedToDriver is active', () {
      expect(ShipmentStatus.assignedToDriver.isActive, isTrue);
    });

    test('inTransit is active', () {
      expect(ShipmentStatus.inTransit.isActive, isTrue);
    });

    test('pending is not active', () {
      expect(ShipmentStatus.pending.isActive, isFalse);
    });

    test('delivered is not active', () {
      expect(ShipmentStatus.delivered.isActive, isFalse);
    });

    test('failed is not active', () {
      expect(ShipmentStatus.failed.isActive, isFalse);
    });

    test('returned is not active', () {
      expect(ShipmentStatus.returned.isActive, isFalse);
    });

    test('cancelled is not active', () {
      expect(ShipmentStatus.cancelled.isActive, isFalse);
    });

    test('assignedToCourier is not active', () {
      expect(ShipmentStatus.assignedToCourier.isActive, isFalse);
    });
  });

  // ─── Shipment.fromJson ────────────────────────────────────────────────────────

  group('Shipment.fromJson', () {
    test('parses all required fields correctly', () {
      final shipment = Shipment.fromJson(fullJson());

      expect(shipment.id, 10);
      expect(shipment.code, 'SHP-001');
      expect(shipment.merchantId, 5);
      expect(shipment.merchantUserId, 'usr-99');
      expect(shipment.description, 'Fragile electronics');
      expect(shipment.weightKg, 2.5);
      expect(shipment.dimensions, '30x20x10');
      expect(shipment.totalFee, 150.0);
      expect(shipment.status, ShipmentStatus.inTransit);
      expect(shipment.remark, 'Handle with care');
      expect(shipment.courierCompanyId, 3);
      expect(shipment.assignedDriverId, 7);
      expect(shipment.startAddress, '123 Pickup St');
      expect(shipment.endAddress, '456 Delivery Ave');
      expect(shipment.rating, 4.8);
      expect(shipment.webhookUrl, 'https://example.com/webhook');
      expect(shipment.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
    });

    test('parses weightKg from integer JSON value', () {
      final json = fullJson()..['weight_kg'] = 3;
      final shipment = Shipment.fromJson(json);
      expect(shipment.weightKg, 3.0);
      expect(shipment.weightKg, isA<double>());
    });

    test('parses totalFee from integer JSON value', () {
      final json = fullJson()..['total_fee'] = 200;
      final shipment = Shipment.fromJson(json);
      expect(shipment.totalFee, 200.0);
      expect(shipment.totalFee, isA<double>());
    });

    test('parses rating from integer JSON value', () {
      final json = fullJson()..['rating'] = 5;
      final shipment = Shipment.fromJson(json);
      expect(shipment.rating, 5.0);
      expect(shipment.rating, isA<double>());
    });

    test('parses items list when present', () {
      final shipment = Shipment.fromJson(fullJson());
      expect(shipment.items, ['item1', 'item2']);
    });

    test('parses items as null when absent', () {
      final json = fullJson()..remove('items');
      final shipment = Shipment.fromJson(json);
      expect(shipment.items, isNull);
    });

    test('parses items as null when explicitly null', () {
      final json = fullJson()..['items'] = null;
      final shipment = Shipment.fromJson(json);
      expect(shipment.items, isNull);
    });

    test('parses deliveredAt when present', () {
      final shipment = Shipment.fromJson(fullJson());
      expect(shipment.deliveredAt,
          DateTime.parse('2024-01-16T14:30:00.000Z'));
    });

    test('parses deliveredAt as null when absent', () {
      final json = fullJson()..remove('delivered_at');
      final shipment = Shipment.fromJson(json);
      expect(shipment.deliveredAt, isNull);
    });

    test('parses deliveredAt as null when null', () {
      final json = fullJson()..['delivered_at'] = null;
      final shipment = Shipment.fromJson(json);
      expect(shipment.deliveredAt, isNull);
    });

    test('parses failedAt as null when null', () {
      final shipment = Shipment.fromJson(fullJson());
      expect(shipment.failedAt, isNull);
    });

    test('parses failedAt when present', () {
      final json = fullJson()..['failed_at'] = '2024-01-17T09:00:00.000Z';
      final shipment = Shipment.fromJson(json);
      expect(shipment.failedAt, DateTime.parse('2024-01-17T09:00:00.000Z'));
    });

    test('defaults description to empty string when absent', () {
      final json = fullJson()..remove('description');
      final shipment = Shipment.fromJson(json);
      expect(shipment.description, '');
    });

    test('defaults remark to empty string when absent', () {
      final json = fullJson()..remove('remark');
      final shipment = Shipment.fromJson(json);
      expect(shipment.remark, '');
    });

    test('defaults webhookUrl to empty string when absent', () {
      final json = fullJson()..remove('webhook_url');
      final shipment = Shipment.fromJson(json);
      expect(shipment.webhookUrl, '');
    });

    test('parses status correctly from JSON string', () {
      for (final status in ShipmentStatus.values) {
        final json = fullJson()..['status'] = status.toApiString;
        final shipment = Shipment.fromJson(json);
        expect(shipment.status, status,
            reason: 'status "${status.toApiString}" should parse to $status');
      }
    });
  });

  // ─── Shipment.copyWith ────────────────────────────────────────────────────────

  group('Shipment.copyWith', () {
    late Shipment original;

    setUp(() {
      original = Shipment.fromJson(fullJson());
    });

    test('returns a copy with updated status', () {
      final updated = original.copyWith(status: ShipmentStatus.delivered);
      expect(updated.status, ShipmentStatus.delivered);
      expect(updated.id, original.id);
      expect(updated.code, original.code);
    });

    test('returns a copy with updated pickedUpAt', () {
      final now = DateTime(2024, 2, 1, 8, 0);
      final updated = original.copyWith(pickedUpAt: now);
      expect(updated.pickedUpAt, now);
      expect(updated.status, original.status);
    });

    test('returns a copy with updated inTransitAt', () {
      final now = DateTime(2024, 2, 1, 9, 0);
      final updated = original.copyWith(inTransitAt: now);
      expect(updated.inTransitAt, now);
    });

    test('returns a copy with updated deliveredAt', () {
      final now = DateTime(2024, 2, 2, 15, 0);
      final updated = original.copyWith(deliveredAt: now);
      expect(updated.deliveredAt, now);
    });

    test('returns a copy with updated failedAt', () {
      final now = DateTime(2024, 2, 3, 10, 0);
      final updated = original.copyWith(failedAt: now);
      expect(updated.failedAt, now);
    });

    test('preserves original values when nothing is overridden', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.status, original.status);
      expect(copy.deliveredAt, original.deliveredAt);
      expect(copy.pickedUpAt, original.pickedUpAt);
    });

    test('does not mutate the original shipment', () {
      final originalStatus = original.status;
      original.copyWith(status: ShipmentStatus.cancelled);
      expect(original.status, originalStatus);
    });
  });

  // ─── ShipmentPage.fromJson ────────────────────────────────────────────────────

  group('ShipmentPage.fromJson', () {
    test('parses shipments list, total, page and pageSize', () {
      final pageJson = {
        'shipments': [fullJson()],
        'total': 50,
        'page': 2,
        'page_size': 10,
      };

      final page = ShipmentPage.fromJson(pageJson);

      expect(page.total, 50);
      expect(page.page, 2);
      expect(page.pageSize, 10);
      expect(page.shipments.length, 1);
      expect(page.shipments.first.id, 10);
    });

    test('parses empty shipments list', () {
      final pageJson = {
        'shipments': <dynamic>[],
        'total': 0,
        'page': 1,
        'page_size': 10,
      };

      final page = ShipmentPage.fromJson(pageJson);
      expect(page.shipments, isEmpty);
      expect(page.total, 0);
    });

    test('treats absent shipments key as empty list', () {
      final pageJson = {
        'total': 0,
        'page': 1,
        'page_size': 10,
      };

      final page = ShipmentPage.fromJson(pageJson);
      expect(page.shipments, isEmpty);
    });

    test('parses multiple shipments', () {
      final second = fullJson()
        ..['id'] = 11
        ..['code'] = 'SHP-002';

      final pageJson = {
        'shipments': [fullJson(), second],
        'total': 2,
        'page': 1,
        'page_size': 10,
      };

      final page = ShipmentPage.fromJson(pageJson);
      expect(page.shipments.length, 2);
      expect(page.shipments[1].id, 11);
      expect(page.shipments[1].code, 'SHP-002');
    });
  });
}
