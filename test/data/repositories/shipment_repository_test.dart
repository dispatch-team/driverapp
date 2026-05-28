import 'package:dio/dio.dart';
import 'package:driverapp/data/models/shipment.dart';
import 'package:driverapp/data/repositories/shipment_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockShipmentProvider mockProvider;
  late ShipmentRepository repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockProvider = MockShipmentProvider();
    repo = ShipmentRepository(provider: mockProvider);
  });

  // ─── Fixtures ────────────────────────────────────────────────────────────────

  Map<String, dynamic> shipmentJson() => {
        'id': 10,
        'code': 'SHP-001',
        'merchant_id': 5,
        'merchant_user_id': 'usr-99',
        'description': 'Electronics',
        'weight_kg': 2.5,
        'dimensions': '30x20x10',
        'total_fee': 150.0,
        'status': 'assigned_to_driver',
        'remark': '',
        'courier_company_id': 3,
        'assigned_driver_id': 7,
        'start_address': '123 Pickup St',
        'start_address_contact_name': 'Alice',
        'start_address_phone_number': '+111',
        'start_address_additional_contact': '',
        'end_address': '456 Delivery Ave',
        'end_address_contact_name': 'Bob',
        'end_address_phone_number': '+222',
        'end_address_additional_contact': '',
        'rating': 0.0,
        'webhook_url': '',
        'created_at': '2024-01-15T10:00:00.000Z',
        'items': null,
        'delivered_at': null,
        'assigned_to_courier_at': null,
        'assigned_to_driver_at': null,
        'picked_up_at': null,
        'in_transit_at': null,
        'failed_at': null,
        'returned_at': null,
        'cancelled_at': null,
      };

  Map<String, dynamic> pageJson({
    int page = 1,
    int pageSize = 10,
    int total = 1,
  }) =>
      {
        'shipments': [shipmentJson()],
        'total': total,
        'page': page,
        'page_size': pageSize,
      };

  // ─── DioException helpers ─────────────────────────────────────────────────────

  DioException makeDioException({int? statusCode, Map<String, dynamic>? body}) {
    final response = (statusCode != null || body != null)
        ? Response<dynamic>(
            statusCode: statusCode ?? 400,
            data: body,
            requestOptions: RequestOptions(path: ''),
          )
        : null;
    return DioException(
      requestOptions: RequestOptions(path: ''),
      response: response,
      type: statusCode != null
          ? DioExceptionType.badResponse
          : DioExceptionType.connectionTimeout,
    );
  }

  // ─── ShipmentRepository.getShipments ─────────────────────────────────────────

  group('ShipmentRepository.getShipments', () {
    void stubGet(Map<String, dynamic> data) {
      when(
        () => mockProvider.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => data);
    }

    test('returns a ShipmentPage on success', () async {
      stubGet(pageJson());
      final result = await repo.getShipments();
      expect(result, isA<ShipmentPage>());
    });

    test('parses page metadata correctly', () async {
      stubGet(pageJson(page: 2, pageSize: 5, total: 42));
      final result = await repo.getShipments(page: 2, pageSize: 5);
      expect(result.page, 2);
      expect(result.pageSize, 5);
      expect(result.total, 42);
    });

    test('parses shipments list', () async {
      stubGet(pageJson());
      final result = await repo.getShipments();
      expect(result.shipments.length, 1);
      expect(result.shipments.first.code, 'SHP-001');
    });

    test('forwards page and pageSize to the provider', () async {
      stubGet(pageJson());
      await repo.getShipments(page: 3, pageSize: 5);
      verify(
        () => mockProvider.getShipments(
          page: 3,
          pageSize: 5,
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test('converts ShipmentStatus enum to API string before forwarding', () async {
      stubGet(pageJson());
      await repo.getShipments(status: ShipmentStatus.inTransit);
      verify(
        () => mockProvider.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: 'in_transit',
        ),
      ).called(1);
    });

    test('forwards null status when not provided', () async {
      stubGet(pageJson());
      await repo.getShipments();
      verify(
        () => mockProvider.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: null,
        ),
      ).called(1);
    });

    test('throws unauthorized ShipmentException on 401 DioException', () async {
      when(
        () => mockProvider.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).thenThrow(makeDioException(statusCode: 401));

      await expectLater(
        () => repo.getShipments(),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
        ),
      );
    });

    test('throws network ShipmentException on non-401 DioException', () async {
      when(
        () => mockProvider.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).thenThrow(makeDioException());

      await expectLater(
        () => repo.getShipments(),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse)
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws unknown ShipmentException on non-Dio exception', () async {
      when(
        () => mockProvider.getShipments(
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
          status: any(named: 'status'),
        ),
      ).thenThrow(Exception('Unexpected'));

      await expectLater(
        () => repo.getShipments(),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'An unexpected error occurred.'),
        ),
      );
    });
  });

  // ─── ShipmentRepository.pickUp ────────────────────────────────────────────────

  group('ShipmentRepository.pickUp', () {
    const code = 'SHP-001';

    test('completes without throwing on success', () async {
      when(() => mockProvider.pickUp(any()))
          .thenAnswer((_) async => {'message': 'ok'});

      await expectLater(repo.pickUp(code), completes);
    });

    test('throws unauthorized ShipmentException on 401', () async {
      when(() => mockProvider.pickUp(any()))
          .thenThrow(makeDioException(statusCode: 401));

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
        ),
      );
    });

    test('throws badRequest ShipmentException when body has "error" key', () async {
      when(() => mockProvider.pickUp(any()))
          .thenThrow(makeDioException(body: {'error': 'Shipment already picked up'}));

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse)
              .having((e) => e.message, 'message', 'Shipment already picked up'),
        ),
      );
    });

    test('throws badRequest ShipmentException when body has "message" key', () async {
      when(() => mockProvider.pickUp(any()))
          .thenThrow(makeDioException(body: {'message': 'Invalid state transition'}));

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Invalid state transition'),
        ),
      );
    });

    test('prefers "error" over "message" when both keys are present', () async {
      when(() => mockProvider.pickUp(any())).thenThrow(
        makeDioException(body: {'error': 'error value', 'message': 'message value'}),
      );

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'error value'),
        ),
      );
    });

    test('throws network ShipmentException when body has no error message', () async {
      when(() => mockProvider.pickUp(any()))
          .thenThrow(makeDioException(statusCode: 400, body: {'other': 'field'}));

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isFalse)
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws network ShipmentException when DioException has no response body',
        () async {
      when(() => mockProvider.pickUp(any()))
          .thenThrow(makeDioException());

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws unknown ShipmentException on non-Dio exception', () async {
      when(() => mockProvider.pickUp(any()))
          .thenThrow(Exception('Unexpected'));

      await expectLater(
        () => repo.pickUp(code),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'An unexpected error occurred.'),
        ),
      );
    });
  });

  // ─── ShipmentRepository.failShipment ─────────────────────────────────────────

  group('ShipmentRepository.failShipment', () {
    const code = 'SHP-002';
    const remark = 'Customer not home';

    test('completes without throwing on success', () async {
      when(() => mockProvider.failShipment(any(), any()))
          .thenAnswer((_) async => {'message': 'ok'});

      await expectLater(repo.failShipment(code, remark), completes);
    });

    test('throws unauthorized ShipmentException on 401', () async {
      when(() => mockProvider.failShipment(any(), any()))
          .thenThrow(makeDioException(statusCode: 401));

      await expectLater(
        () => repo.failShipment(code, remark),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
        ),
      );
    });

    test('throws badRequest ShipmentException when body has "error" key', () async {
      when(() => mockProvider.failShipment(any(), any()))
          .thenThrow(makeDioException(body: {'error': 'Cannot fail a delivered shipment'}));

      await expectLater(
        () => repo.failShipment(code, remark),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Cannot fail a delivered shipment'),
        ),
      );
    });

    test('throws badRequest ShipmentException when body has "message" key', () async {
      when(() => mockProvider.failShipment(any(), any()))
          .thenThrow(makeDioException(body: {'message': 'Remark required'}));

      await expectLater(
        () => repo.failShipment(code, remark),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Remark required'),
        ),
      );
    });

    test('throws network ShipmentException when DioException has no body message',
        () async {
      when(() => mockProvider.failShipment(any(), any()))
          .thenThrow(makeDioException());

      await expectLater(
        () => repo.failShipment(code, remark),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws unknown ShipmentException on non-Dio exception', () async {
      when(() => mockProvider.failShipment(any(), any()))
          .thenThrow(Exception('Unexpected'));

      await expectLater(
        () => repo.failShipment(code, remark),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'An unexpected error occurred.'),
        ),
      );
    });
  });

  // ─── ShipmentRepository.verifyDelivery ───────────────────────────────────────

  group('ShipmentRepository.verifyDelivery', () {
    const code = 'SHP-003';
    const deliveryCode = 'DEL-XYZ';

    test('completes without throwing on success', () async {
      when(() => mockProvider.verifyDelivery(any(), any()))
          .thenAnswer((_) async => {'message': 'ok'});

      await expectLater(repo.verifyDelivery(code, deliveryCode), completes);
    });

    test('throws unauthorized ShipmentException on 401', () async {
      when(() => mockProvider.verifyDelivery(any(), any()))
          .thenThrow(makeDioException(statusCode: 401));

      await expectLater(
        () => repo.verifyDelivery(code, deliveryCode),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
        ),
      );
    });

    test('throws badRequest ShipmentException when body has "error" key', () async {
      when(() => mockProvider.verifyDelivery(any(), any()))
          .thenThrow(makeDioException(body: {'error': 'Wrong delivery code'}));

      await expectLater(
        () => repo.verifyDelivery(code, deliveryCode),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Wrong delivery code'),
        ),
      );
    });

    test('throws badRequest ShipmentException when body has "message" key', () async {
      when(() => mockProvider.verifyDelivery(any(), any()))
          .thenThrow(makeDioException(body: {'message': 'Code already used'}));

      await expectLater(
        () => repo.verifyDelivery(code, deliveryCode),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Code already used'),
        ),
      );
    });

    test('throws network ShipmentException when DioException has no body message',
        () async {
      when(() => mockProvider.verifyDelivery(any(), any()))
          .thenThrow(makeDioException());

      await expectLater(
        () => repo.verifyDelivery(code, deliveryCode),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'Connection error. Please try again.'),
        ),
      );
    });

    test('throws unknown ShipmentException on non-Dio exception', () async {
      when(() => mockProvider.verifyDelivery(any(), any()))
          .thenThrow(Exception('Unexpected'));

      await expectLater(
        () => repo.verifyDelivery(code, deliveryCode),
        throwsA(
          isA<ShipmentException>()
              .having((e) => e.message, 'message', 'An unexpected error occurred.'),
        ),
      );
    });
  });

  // ─── ShipmentException factories ─────────────────────────────────────────────

  group('ShipmentException factories', () {
    test('unauthorized has correct message and isUnauthorized=true', () {
      final e = ShipmentException.unauthorized();
      expect(e.message, 'Session expired. Please log in again.');
      expect(e.isUnauthorized, isTrue);
    });

    test('network has correct message and isUnauthorized=false', () {
      final e = ShipmentException.network();
      expect(e.message, 'Connection error. Please try again.');
      expect(e.isUnauthorized, isFalse);
    });

    test('unknown has correct message and isUnauthorized=false', () {
      final e = ShipmentException.unknown();
      expect(e.message, 'An unexpected error occurred.');
      expect(e.isUnauthorized, isFalse);
    });

    test('badRequest carries the provided message and isUnauthorized=false', () {
      final e = ShipmentException.badRequest('Custom server error');
      expect(e.message, 'Custom server error');
      expect(e.isUnauthorized, isFalse);
    });

    test('badRequest preserves the exact message string', () {
      const msg = 'Shipment is already in_transit';
      expect(ShipmentException.badRequest(msg).message, msg);
    });
  });
}
