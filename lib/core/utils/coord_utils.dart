/// Parses a `"lat;lng"` string into a `(double, double)` tuple.
/// Returns `null` if the string is not a valid coordinate pair.
(double, double)? tryParseCoordinates(String value) {
  final parts = value.split(';');
  if (parts.length != 2) return null;

  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  if (lat == null || lng == null) return null;

  return (lat, lng);
}
