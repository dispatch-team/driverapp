import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_client.dart';

class ProfileProvider {
  final ApiClient _client;

  ProfileProvider(this._client);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '${AppConstants.apiPrefix}${ApiConstants.driversProfile}',
    );
    return response.data as Map<String, dynamic>;
  }
}
