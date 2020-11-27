import 'package:flutter/widgets.dart';
import 'package:address_search_field/src/models/bounds.dart';
import 'package:address_search_field/src/models/coords.dart';

/// Primary data of an address to perform geolocation processes.
class Address {
  /// Coordinates.
  Coords _coords;

  /// Bounds.
  Bounds _bounds;

  /// Reference or streets.
  String _reference;

  /// Place Id from Google Place API.
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

  /// Checks if reference exists.
  bool get hasReference => _reference != null && _reference.isNotEmpty;

  /// Checks if Place Id exists.
  bool get hasPlaceId => _placeId != null && _placeId.isNotEmpty;

  /// Checks if coords exists.
  bool get hasCoords => _coords != null;

  /// Checks if bounds exists.
  bool get hasBounds => _bounds != null;

  /// Checks if all properties exist.
  bool get isCompleted => hasCoords && hasPlaceId && hasCoords && hasBounds;

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other._coords == _coords &&
        other._bounds == _bounds &&
        other._reference == _reference &&
        other._placeId == _placeId;
  }

  @override
  int get hashCode => hashValues(_coords, _bounds, _reference, _placeId);
}
