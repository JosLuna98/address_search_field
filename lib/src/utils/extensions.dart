import 'package:address_search_field/address_search_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// extensions for [LatLng].
extension LatLngConvert on LatLng {
  /// Converts [LatLng] to [Coords].
  Coords toCoords() => Coords(this.latitude, this.longitude);
}

/// extensions for [LatLngBounds].
extension LatLngBoundsConvert on LatLngBounds {
  /// Converts [LatLngBounds] to [Bounds].
  Bounds toBounds() =>
      Bounds(southwest: this.southwest, northeast: this.northeast);
}
