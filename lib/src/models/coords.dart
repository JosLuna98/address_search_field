import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

///  Latitude and longitude coordinates as degrees.
class Coords extends LatLng {
  /// Constructor for [Coords].
  const Coords(double latitude, double longitude) : super(latitude, longitude);

  /// Constructor for [Coords] by JSON [Map] object.
  factory Coords.fromJson(dynamic json) => Coords(json['lat'], json['lng']);

  @override
  String toString() => '$latitude,$longitude';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is Coords &&
        o.latitude == latitude &&
        o.longitude == longitude;
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}
