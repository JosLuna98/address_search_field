import 'package:address_search_field/src/models/address.dart';
import 'package:flutter/widgets.dart';
import 'package:address_search_field/src/models/coords.dart';
import 'package:address_search_field/src/models/bounds.dart';

/// Result of request to Google Directions API
class Directions {
  /// Origin point of a route.
  final Address origin;

  /// Destination point of a route.
  final Address destination;

  /// Points beetwen origin and destination of a route.
  final List<Address> waypoints;

  /// Distance of a route.
  final String distance;

  /// Duration of a route.
  final String duration;

  /// Bounds of a route.
  final Bounds bounds;

  /// Points of [Polyline] in a route.
  final List<Coords> points;

  /// Constructor for [Directions].
  Directions({
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.distance,
    required this.duration,
    required this.bounds,
    required this.points,
  });

  @override
  String toString() {
    String value =
        'origin: ${origin.toString()}\ndestination: ${destination.toString()}\ndistance: $distance\nduration: $duration\ndirections ${bounds.toString()}\npolyline: [ ';
    for (var element in points) {
      value += ' [${element.toString()}] ';
    }
    value += ' ]';
    return value;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Directions &&
        other.origin == origin &&
        other.destination == destination &&
        other.waypoints == waypoints &&
        other.distance == distance &&
        other.duration == duration &&
        other.bounds == bounds &&
        other.points == points;
  }

  @override
  int get hashCode => hashValues(
      origin, destination, waypoints, distance, duration, bounds, points);
}
