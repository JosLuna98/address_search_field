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
  Bounds toBounds() => Bounds(
      southwest: this.southwest as Coords, northeast: this.northeast as Coords);
}

/// extensions for [List<Address>].
extension AddressListConvert on List<Address> {
  /// Converts [List<Address>] to [List<Coords>].
  List<Coords> toCoordsList() {
    final coords = <Coords>[];
    this.forEach((element) {
      if (element.hasCoords) coords.add(element.coords!);
    });
    return coords;
  }
}

/// extensions for [List<Coords>].
extension CoordsListConvert on List<Coords> {
  /// Converts [List<Coords>] to [List<Address>].
  List<Address> toAddressList() {
    final addresses = <Address>[];
    this.forEach((element) => addresses.add(Address(coords: element)));
    return addresses;
  }
}
