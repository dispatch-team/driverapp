import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Checks location service + permission, requests if needed.
  /// Returns `true` when permission is granted and service is enabled.
  Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Returns the current device position, or `null` on failure.
  Future<Position?> getCurrent() async {
    try {
      final granted = await ensurePermission();
      if (!granted) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
