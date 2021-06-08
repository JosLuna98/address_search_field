import 'package:flutter/widgets.dart';
import 'package:address_search_field/src/models/bounds.dart';
import 'package:address_search_field/src/models/coords.dart';

/// Primary data of an address to perform geolocation processes.
class Address {
  /// Coordinates.
  final Coords? coords;

  /// Bounds.
  final Bounds? bounds;

  /// Reference or streets.
  final String? reference;

  /// Place Id from Google Place API.
  final String? placeId;

  /// Constructor for [Address].
  Address({Coords? coords, Bounds? bounds, String? reference, String? placeId})
      : this.coords = coords,
        this.bounds = bounds,
        this.reference = reference,
        this.placeId = placeId;

  /// Checks if reference exists.
  bool get hasReference =>
      (reference != null) ? (reference!.isNotEmpty ? true : false) : false;

  /// Checks if Place Id exists.
  bool get hasPlaceId =>
      (placeId != null) ? (placeId!.isNotEmpty ? true : false) : false;

  /// Checks if coords exists.
  bool get hasCoords => coords != null;

  /// Checks if bounds exists.
  bool get hasBounds => bounds != null;

  /// Checks if all properties exist.
  bool get isCompleted => hasCoords && hasPlaceId && hasCoords && hasBounds;

  /// Permits to get an [Address] copy and update its data with other [Address].
  Address copyWith(Address newAddress) {
    return Address(
      coords: newAddress.coords ?? this.coords,
      bounds: newAddress.bounds ?? this.bounds,
      reference: newAddress.reference ?? this.reference,
      placeId: newAddress.placeId ?? this.placeId,
    );
  }

  @override
  String toString() =>
      "${(hasPlaceId) ? placeId : null} => $reference\ncoords: [${coords.toString()}]${(hasBounds) ? '\n${bounds.toString()}' : ''}";

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.coords == coords &&
        other.bounds == bounds &&
        other.reference == reference &&
        other.placeId == placeId;
  }

  @override
  int get hashCode => hashValues(coords, bounds, reference, placeId);
}
