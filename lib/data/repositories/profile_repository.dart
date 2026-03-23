import 'package:dio/dio.dart';

import '../models/driver_profile.dart';
import '../providers/profile_provider.dart';

class ProfileRepository {
  final ProfileProvider _provider;

  ProfileRepository({required ProfileProvider provider})
      : _provider = provider;

  /// Returns the driver profile or throws a [ProfileException].
  Future<DriverProfile> getProfile() async {
    try {
      final data = await _provider.getProfile();
      return DriverProfile.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ProfileException.unauthorized();
      }
      throw ProfileException.network();
    } catch (_) {
      throw ProfileException.unknown();
    }
  }
}

class ProfileException implements Exception {
  const ProfileException._(this.message, this.isUnauthorized);

  factory ProfileException.unauthorized() => const ProfileException._(
        'Session expired. Please log in again.',
        true,
      );

  factory ProfileException.network() => const ProfileException._(
        'Connection error. Please try again.',
        false,
      );

  factory ProfileException.unknown() => const ProfileException._(
        'An unexpected error occurred.',
        false,
      );

  final String message;
  final bool isUnauthorized;
}
