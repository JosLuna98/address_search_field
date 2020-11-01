import 'package:address_search_field/src/models/bounds.dart';
import 'package:address_search_field/src/models/coords.dart';

/// A address primary data to work with Google APIs and [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) plugin.
class Address {
  Coords _coords;
  Bounds _bounds;
  String _reference;
  String _placeId;

  /// Constructor for [Address].
  Address({Coords coords, Bounds bounds, String reference, String placeId})
      : _coords = coords,
        _bounds = bounds,
        _reference = reference,
        _placeId = placeId;

  /// Address coordinates.
  Coords get coords => _coords;

  /// Address bounds.
  Bounds get bounds => _bounds;

  /// Address reference or streets.
  String get reference => _reference;

  /// Place Id to work with Google Place API
  String get placeId => _placeId;

  /// Check if reference exists.
  bool get hasReference => _reference != null && _reference.isNotEmpty;

  /// Check if Place Id exists.
  bool get hasPlaceId => _placeId != null && _placeId.isNotEmpty;

  /// Check if coords exists.
  bool get hasCoords => _coords != null;

  /// Check if bounds exists.
  bool get hasBounds => _bounds != null;

  /// Permits to update coords of the object.
  void updateCoords(Coords coordinates, Bounds bounds) {
    _coords = coordinates;
    _bounds = bounds;
  }

  /// Permits to update object by other object.
  void update(Address newAddress) {
    _coords = newAddress.coords;
    _bounds = newAddress.bounds;
    _reference = newAddress.reference;
    _placeId = newAddress.placeId;
  }

  @override
  String toString() =>
      "${(hasPlaceId) ? _placeId : null} => $_reference\ncoords: [${_coords.toString()}]${(hasBounds) ? '\n${_bounds.toString()}' : ''}";
}
