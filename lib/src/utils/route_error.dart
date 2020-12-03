/// `enum` which identifies throwed errors in routes.
enum RouteError {
  /// Gps service is disabled.
  gps_disabled,

  /// No gps permissions granted.
  no_gps_permission,

  /// Location not found.
  location_not_found,

  /// No origin coordinates.
  no_origin_coords,

  /// No destination coordinates.
  no_dest_coords,

  /// Route directions not found.
  directions_not_found,

  /// Unexpected error.
  unexpected_error,
}
