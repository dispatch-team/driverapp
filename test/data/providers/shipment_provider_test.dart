import 'package:dio/dio.dart';
import 'package:driverapp/core/constants/api_constants.dart';
import 'package:driverapp/core/constants/app_constants.dart';
import 'package:driverapp/data/providers/shipment_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockApiClient mockApiClient;
  late ShipmentProvider shipmentProvider;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockApiClient = MockApiClient();
    shipmentProvider = ShipmentProvider(mockApiClient);
  });

  Response<Map<String, dynamic>> makeResponse({
    required int statusCode,
    required Map<String, dynamic> data,
  }) {
    return Response<Map<String, dynamic>>(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  // ─── ShipmentProvider.getShipments ───────────────────────────────────────────

  group('ShipmentProvider.getShipments', () {
    const expectedPath =
        '${AppConstants.apiPrefix}${ApiConstants.shipments}';

    final pageData = {
      'shipments': <dynamic>[],
      'total': 0,
      'page': 1,
      'page_size': 20,
    };

    void stubGet(Map<String, dynamic> data) {
      when(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => makeResponse(statusCode: 200, data: data));
    }

    test('returns response data on success', () async {
      stubGet(pageData);
      final result = await shipmentProvider.getShipments();
      expect(result, pageData);
    });

    test('calls GET with the correct endpoint path', () async {
      stubGet(pageData);
      await shipmentProvider.getShipments();
      verify(
        () => mockApiClient.get<Map<String, dynamic>>(
          expectedPath,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('sends default page=1 and page_size=20 query params', () async {
      stubGet(pageData);
      await shipmentProvider.getShipments();
      verify(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: {
            'page': 1,
            'page_size': AppConstants.defaultPageSize,
          },
        ),
      ).called(1);
    });

    test('sends custom page and pageSize query params', () async {
      stubGet(pageData);
      await shipmentProvider.getShipments(page: 3, pageSize: 5);
      verify(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: {'page': 3, 'page_size': 5},
        ),
      ).called(1);
    });

    test('includes status query param when provided', () async {
      stubGet(pageData);
      await shipmentProvider.getShipments(status: 'in_transit');
      verify(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: {
            'page': 1,
            'page_size': AppConstants.defaultPageSize,
            'status': 'in_transit',
          },
        ),
      ).called(1);
    });

    test('omits status query param when not provided', () async {
      stubGet(pageData);
      await shipmentProvider.getShipments();
      // Verify the exact map — status key must be absent.
      verify(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: {
            'page': 1,
            'page_size': AppConstants.defaultPageSize,
          },
        ),
      ).called(1);
    });

    test('omits status query param when null is passed explicitly', () async {
      stubGet(pageData);
      await shipmentProvider.getShipments(status: null);
      verify(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: {
            'page': 1,
            'page_size': AppConstants.defaultPageSize,
          },
        ),
      ).called(1);
    });

    test('propagates DioException thrown by the API client', () async {
      when(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: expectedPath),
        type: DioExceptionType.connectionTimeout,
      ));

      await expectLater(
        () => shipmentProvider.getShipments(),
        throwsA(isA<DioException>()),
      );
    });

    test('propagates unexpected exceptions thrown by the API client', () async {
      when(
        () => mockApiClient.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      await expectLater(
        () => shipmentProvider.getShipments(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ─── ShipmentProvider.pickUp ─────────────────────────────────────────────────

  group('ShipmentProvider.pickUp', () {
    const code = 'SHP-001';
    final expectedPath =
        '${AppConstants.apiPrefix}${ApiConstants.shipmentPickUp(code)}';
    final responseData = {'message': 'picked up'};

    void stubPost(Map<String, dynamic> data) {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => makeResponse(statusCode: 200, data: data));
    }

    test('returns response data on success', () async {
      stubPost(responseData);
      final result = await shipmentProvider.pickUp(code);
      expect(result, responseData);
    });

    test('calls POST with the correct pick-up path', () async {
      stubPost(responseData);
      await shipmentProvider.pickUp(code);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          expectedPath,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('path embeds the shipment code', () async {
      const otherCode = 'XYZ-999';
      stubPost(responseData);
      await shipmentProvider.pickUp(otherCode);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          '${AppConstants.apiPrefix}${ApiConstants.shipmentPickUp(otherCode)}',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('propagates DioException thrown by the API client', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: expectedPath),
        type: DioExceptionType.badResponse,
      ));

      await expectLater(
        () => shipmentProvider.pickUp(code),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ─── ShipmentProvider.failShipment ───────────────────────────────────────────

  group('ShipmentProvider.failShipment', () {
    const code = 'SHP-002';
    const remark = 'Customer not home';
    final expectedPath =
        '${AppConstants.apiPrefix}${ApiConstants.shipmentFail(code)}';
    final responseData = {'message': 'failed'};

    void stubPost(Map<String, dynamic> data) {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => makeResponse(statusCode: 200, data: data));
    }

    test('returns response data on success', () async {
      stubPost(responseData);
      final result = await shipmentProvider.failShipment(code, remark);
      expect(result, responseData);
    });

    test('calls POST with the correct fail path', () async {
      stubPost(responseData);
      await shipmentProvider.failShipment(code, remark);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          expectedPath,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('path embeds the shipment code', () async {
      const otherCode = 'ABC-123';
      stubPost(responseData);
      await shipmentProvider.failShipment(otherCode, remark);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          '${AppConstants.apiPrefix}${ApiConstants.shipmentFail(otherCode)}',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('sends remark in the request body', () async {
      stubPost(responseData);
      await shipmentProvider.failShipment(code, remark);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: {'remark': remark},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('sends the correct remark value for a different remark', () async {
      const otherRemark = 'Wrong address';
      stubPost(responseData);
      await shipmentProvider.failShipment(code, otherRemark);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: {'remark': otherRemark},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('propagates DioException thrown by the API client', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: expectedPath),
        type: DioExceptionType.badResponse,
      ));

      await expectLater(
        () => shipmentProvider.failShipment(code, remark),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ─── ShipmentProvider.verifyDelivery ─────────────────────────────────────────

  group('ShipmentProvider.verifyDelivery', () {
    const code = 'SHP-003';
    const deliveryCode = 'DEL-XYZ';
    final expectedPath =
        '${AppConstants.apiPrefix}${ApiConstants.shipmentVerifyDelivery(code)}';
    final responseData = {'message': 'delivery verified'};

    void stubPost(Map<String, dynamic> data) {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => makeResponse(statusCode: 200, data: data));
    }

    test('returns response data on success', () async {
      stubPost(responseData);
      final result = await shipmentProvider.verifyDelivery(code, deliveryCode);
      expect(result, responseData);
    });

    test('calls POST with the correct verify-delivery path', () async {
      stubPost(responseData);
      await shipmentProvider.verifyDelivery(code, deliveryCode);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          expectedPath,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('path embeds the shipment code', () async {
      const otherCode = 'DEF-456';
      stubPost(responseData);
      await shipmentProvider.verifyDelivery(otherCode, deliveryCode);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          '${AppConstants.apiPrefix}${ApiConstants.shipmentVerifyDelivery(otherCode)}',
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('sends the delivery code in the request body under "code" key',
        () async {
      stubPost(responseData);
      await shipmentProvider.verifyDelivery(code, deliveryCode);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: {'code': deliveryCode},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('sends a different delivery code correctly', () async {
      const otherDeliveryCode = 'ABC-111';
      stubPost(responseData);
      await shipmentProvider.verifyDelivery(code, otherDeliveryCode);
      verify(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: {'code': otherDeliveryCode},
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('propagates DioException thrown by the API client', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: expectedPath),
        type: DioExceptionType.badResponse,
      ));

      await expectLater(
        () => shipmentProvider.verifyDelivery(code, deliveryCode),
        throwsA(isA<DioException>()),
      );
    });

    test('propagates unexpected exceptions thrown by the API client', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(Exception('Unexpected'));

      await expectLater(
        () => shipmentProvider.verifyDelivery(code, deliveryCode),
        throwsA(isA<Exception>()),
      );
    });
  });
}
