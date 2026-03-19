class AppConstants {
  AppConstants._();

  static const String appName = 'Driver App';

  // API
  static const String baseUrl = 'https://service.staging.dispattch.dev/';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int defaultPageSize = 20;
}
