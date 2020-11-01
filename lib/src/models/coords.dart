import 'package:google_maps_flutter/google_maps_flutter.dart';

///  Latitude and longitude coordinates as degrees.
class Coords {
  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees.
  final double longitude;

  /// Constructor for [Coords].
  Coords(double latitude, double longitude)
      : assert(latitude != null && longitude != null,
            "latitude and longitude can't be null"),
        assert(latitude != 0.0 && longitude != 0.0,
            "latitude and longitude should be real"),
        this.latitude = latitude,
        this.longitude = longitude;

  /// Constructor for [Coords] by JSON [Map] object.
  factory Coords.fromJson(dynamic json) => Coords(json['lat'], json['lng']);

  @override
  String toString() => '$latitude,$longitude';
}

/// Helps to use objects with [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) plugin.
extension CoordsConvert on Coords {
  /// Returns a [LatLng] object.
  LatLng toLatLng() => LatLng(this.latitude, this.longitude);
}

/// Helps to use objects with [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) plugin.
extension ListConvert on List<Coords> {
  /// Returns a [List] of [LatLng].
  List<LatLng> toLatLng() {
    List<LatLng> list = List<LatLng>();
    this.forEach((element) => list.add(element.toLatLng()));
    return list;
  }
}
