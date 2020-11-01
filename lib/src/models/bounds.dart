import 'package:address_search_field/src/models/coords.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geographical bounding box by coordinates of [LatLng] object.
class Bounds {
  /// The northeast coordinates of the rectangle.
  final Coords northeast;

  /// The southwest coordinates of the rectangle.
  final Coords southwest;

  /// Constructor for [Bounds].
  Bounds(this.northeast, this.southwest)
      : assert(northeast != null && southwest != null, "coords can't be null");

  /// Constructor for [Bounds] by JSON [Map] object.
  // Map<String, Map<String, double>>
  factory Bounds.fromJson(dynamic json) => Bounds(
      Coords.fromJson(json['northeast']), Coords.fromJson(json['southwest']));

  @override
  String toString() =>
      "bounds:\n\tnortheast: [${northeast.toString()}]\n\tsouthwest: [${southwest.toString()}]";
}

/// Helps to use objects with [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) plugin.
extension BoundsConvert on Bounds {
  /// Returns a [LatLngBounds] object.
  LatLngBounds toLatLng() => LatLngBounds(
        southwest: LatLng(
          this.southwest.latitude,
          this.southwest.longitude,
        ),
        northeast: LatLng(
          this.northeast.latitude,
          this.northeast.longitude,
        ),
      );
}
