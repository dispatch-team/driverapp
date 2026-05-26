/// Parses a coordinate string into a `(double, double)` tuple.
///
/// Accepts both plain `"lat,lng"` and labeled `"Label | lat,lng"` formats.
/// Returns `null` if the string does not contain a valid coordinate pair.
(double, double)? tryParseCoordinates(String value) {
  final coordPart = value.contains('|')
      ? value.substring(value.indexOf('|') + 1)
      : value;

  final parts = coordPart.split(';');
  if (parts.length != 2) return null;

  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  if (lat == null || lng == null) return null;

  return (lat, lng);
}

/// Extracts the human-readable label from an address string.
///
/// For the `"Label | lat;lng"` format, returns the trimmed label part.
/// If the address does not contain `|`, the original string is returned as-is.
String parseAddressLabel(String value) {
  if (!value.contains('|')) return value;
  return value.substring(0, value.indexOf('|')).trim();
}
