import 'package:address_search_field/address_search_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// extensions for [LatLng].
extension LatLngConvert on LatLng {
  /// Converts [LatLng] to [Coords].
  Coords toCoords() => Coords(latitude, longitude);
}

/// extensions for [LatLngBounds].
extension LatLngBoundsConvert on LatLngBounds {
  /// Converts [LatLngBounds] to [Bounds].
  Bounds toBounds() =>
      Bounds(southwest: southwest.toCoords(), northeast: northeast.toCoords());
}

/// extensions for [List<Address>].
extension AddressListConvert on List<Address> {
  /// Converts [List<Address>] to [List<Coords>].
  List<Coords> toCoordsList() {
    final coords = <Coords>[];
    for (var element in this) {
      if (element.hasCoords) coords.add(element.coords!);
    }
    return coords;
  }
}

/// extensions for [List<Coords>].
extension CoordsListConvert on List<Coords> {
  /// Converts [List<Coords>] to [List<Address>].
  List<Address> toAddressList() {
    final addresses = <Address>[];
    for (var element in this) {
      addresses.add(Address.fromCoords(coords: element));
    }
    return addresses;
  }
}

/// extensions for [List<Address>].
extension WaypointRangeException on List<Address> {
  /// Returns [String?] catching [RangeError].
  String? getReference(int index) {
    try {
      return this[index].reference;
    } catch (e) {
      return null;
    }
  }
}
