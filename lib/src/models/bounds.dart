import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:address_search_field/src/models/coords.dart';

/// Geographical bounding box by coordinates of [LatLng] object.
class Bounds extends LatLngBounds {
  /// Constructor for [Bounds].
  Bounds({required Coords southwest, required Coords northeast})
      : super(southwest: southwest, northeast: northeast);

  /// Constructor for [Bounds] by JSON [Map] object.
  // Map<String, Map<String, double>>
  factory Bounds.fromJson(dynamic json) => Bounds(
      southwest: Coords.fromJson(json['southwest']),
      northeast: Coords.fromJson(json['northeast']));

  @override
  String toString() =>
      'bounds:\n\tnortheast: [${northeast.toString()}]\n\tsouthwest: [${southwest.toString()}]';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bounds && other.southwest == southwest && other.northeast == northeast;
  }

  @override
  int get hashCode => hashValues(southwest, northeast);
}
