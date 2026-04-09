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
  }) async {
    try {
      final data = await _provider.getShipments(page: page, pageSize: pageSize);
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

  final String message;
  final bool isUnauthorized;
}
