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
}
