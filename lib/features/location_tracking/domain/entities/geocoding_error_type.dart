/// Pure Dart enum representing geocoding error types.
/// Domain layer - ZERO external dependencies.
enum GeocodingErrorType {
  /// Network connectivity issue - no internet or timeout
  networkError,

  /// Geocoding service unavailable or rate-limited
  serviceUnavailable,

  /// No address found for coordinates (ocean, remote area)
  noAddressFound,

  /// Invalid coordinates (out of range, NaN)
  invalidCoordinates,

  /// Unexpected/unknown error
  unknown,

  /// No error - geocoding successful
  none,
}
