/// Identifies throwed errors in routes.
enum RouteError {
  /// Gps service is disabled.
  gpsDisabled,

  /// No gps permissions granted.
  noGpsPermission,

  /// Location not found.
  locationNotFound,

  /// No origin coordinates.
  noOriginCoords,

  /// No destination coordinates.
  noDestCoords,

  /// Route directions not found.
  directionsNotFound,

  /// Unexpected error.
  unexpectedError,
}
