class AppConstants {
  AppConstants._(); // coverage:ignore-line

  static const String appName = 'Driver App';

  // API
  static const String baseUrl = 'https://service.staging.dispattch.dev/';
  static const String apiPrefix = 'api/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String localeKey = 'app_locale';

  // Pagination
  static const int defaultPageSize = 20;
}
