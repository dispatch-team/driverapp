import 'package:dio/dio.dart';

import '../models/shipment.dart';
import '../providers/shipment_provider.dart';

class ShipmentRepository {
  final ShipmentProvider _provider;

  ShipmentRepository({required ShipmentProvider provider})
      : _provider = provider;

  /// Returns a [ShipmentPage] or throws a [ShipmentException].
  Future<ShipmentPage> getShipments({
    int page = 1,
    int pageSize = 10,
    ShipmentStatus? status,
  }) async {
    try {
      final data = await _provider.getShipments(
        page: page,
        pageSize: pageSize,
        status: status?.toApiString,
      );
      return ShipmentPage.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ShipmentException.unauthorized();
      }
      throw ShipmentException.network();
    } catch (_) {
      throw ShipmentException.unknown();
    }
  }

  /// Marks a shipment as picked up (transitions to in_transit).
  Future<void> pickUp(String code) async {
    try {
      await _provider.pickUp(code);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw ShipmentException.unauthorized();
      final bodyMessage = _extractMessage(e.response?.data);
      if (bodyMessage != null) throw ShipmentException.badRequest(bodyMessage);
      throw ShipmentException.network();
    } catch (e) {
      if (e is ShipmentException) rethrow;
      throw ShipmentException.unknown();
    }
  }

  /// Marks a shipment as failed with an optional driver remark.
  Future<void> failShipment(String code, String remark) async {
    try {
      await _provider.failShipment(code, remark);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw ShipmentException.unauthorized();
      final bodyMessage = _extractMessage(e.response?.data);
      if (bodyMessage != null) throw ShipmentException.badRequest(bodyMessage);
      throw ShipmentException.network();
    } catch (e) {
      if (e is ShipmentException) rethrow;
      throw ShipmentException.unknown();
    }
  }

  /// Verifies delivery with the customer-provided code. Returns the updated [Shipment].
  Future<void> verifyDelivery(String code, String deliveryCode) async {
    try {
      await _provider.verifyDelivery(code, deliveryCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw ShipmentException.unauthorized();
      // Server may return 4xx or 5xx with a human-readable error in the body.
      final bodyMessage = _extractMessage(e.response?.data);
      if (bodyMessage != null) throw ShipmentException.badRequest(bodyMessage);
      throw ShipmentException.network();
    } catch (e) {
      if (e is ShipmentException) rethrow;
      throw ShipmentException.unknown();
    }
  }

  /// Returns the human-readable error string from the response body, or `null`
  /// if no meaningful message is present.
  String? _extractMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['error'] as String? ??
          responseData['message'] as String?;
    }
    return null;
  }
}

class ShipmentException implements Exception {
  const ShipmentException._(this.message, this.isUnauthorized);

  factory ShipmentException.unauthorized() => const ShipmentException._(
        'Session expired. Please log in again.',
        true,
      );

  factory ShipmentException.network() => const ShipmentException._(
        'Connection error. Please try again.',
        false,
      );

  factory ShipmentException.unknown() => const ShipmentException._(
        'An unexpected error occurred.',
        false,
      );

  factory ShipmentException.badRequest(String message) =>
      ShipmentException._(message, false);

  final String message;
  final bool isUnauthorized;
}
