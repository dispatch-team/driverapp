import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_client.dart';

class ShipmentProvider {
  final ApiClient _client;

  ShipmentProvider(this._client);

  Future<Map<String, dynamic>> getShipments({
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${AppConstants.apiPrefix}${ApiConstants.shipments}',
      queryParameters: {
        'page':      page,
        'page_size': pageSize,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pickUp(String code) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${AppConstants.apiPrefix}${ApiConstants.shipmentPickUp(code)}',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> failShipment(String code, String remark) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${AppConstants.apiPrefix}${ApiConstants.shipmentFail(code)}',
      data: {'remark': remark},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyDelivery(
    String code,
    String deliveryCode,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${AppConstants.apiPrefix}${ApiConstants.shipmentVerifyDelivery(code)}',
      data: {'code': deliveryCode},
    );
    return response.data as Map<String, dynamic>;
  }
}
