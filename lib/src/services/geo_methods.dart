import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:address_search_field/src/models/directions.dart';
import 'package:address_search_field/src/models/address.dart';
import 'package:address_search_field/src/models/bounds.dart';
import 'package:address_search_field/src/models/coords.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Provides methods to call Google places, geocode and directions APIs
class GeoMethods {
  /// Google api key to call Google APIs.
  /// Get one [here](https://console.developers.google.com/apis/credentials).
  final String googleApiKey;

  /// Language for responses from Google APIs.
  /// Language support list [here](https://developers.google.com/maps/faq#languagesupport).
  final String language;

  /// Country code to search in a specific region.
  /// List of countries [here](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  final String countryCode;

  /// Country to filter address results.
  final String country;

  /// City to filter address results.
  final String city;

  /// By default, directions are calculated as `driving` directions. It can also be `walking`, `bicycling`, `transit`. See [documentation](https://developers.google.com/maps/documentation/directions/overview#TravelModes).
  final String mode;

  /// Contructor for [GeoMethods].
  GeoMethods({
    @required this.googleApiKey,
    @required this.language,
    @required this.countryCode,
    @required this.country,
    @required this.city,
    this.mode = 'driving',
  });

  /// Calls AutoComplete of Google Place API sending a `query`.
  /// Each [Address] just have `reference` and `place_id`.
  Future<List<Address>> autocompletePlace({@required String query}) async {
    if (query.isEmpty) return <Address>[];
    query = query.replaceAll(RegExp(r' '), '%20');
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query,%20$city,%20$country&language=$language&components=country:$countryCode&key=$googleApiKey';
    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      return null;
    }
    final List<Address> list = List<Address>();
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body)['predictions'];
      jsonResponse.forEach((element) => list.add(Address(
          reference: element['description'], placeId: element['place_id'])));
    } else {
      throw ("Request failed with status: ${response.statusCode}");
    }
    return list;
  }

  /// Calls Details of Google Place API sending a `place_id`.
  Future<Address> getPlaceGeometry(
      {@required String reference, @required String placeId}) async {
    if (placeId.isEmpty)
      AssertionError("placeId can't be declared as an empty `String`");
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$googleApiKey';
    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      return null;
    }
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var coords = jsonResponse['result']['geometry']['location'];
      var bounds = jsonResponse['result']['geometry']['viewport'];
      return Address(
          coords: Coords.fromJson(coords),
          bounds: Bounds.fromJson(bounds),
          reference: reference,
          placeId: placeId);
    } else {
      throw ("Request failed with status: ${response.statusCode}");
    }
  }

  /// Calls Google Geocode API sending `latitude` and `longitude` of [Coords].
  Future<Address> geoLocatePlace({@required Coords coords}) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${coords.toString()}&result_type=street_address&language=$language&key=$googleApiKey';
    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      return null;
    }
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var bounds = jsonResponse['results'][0]['geometry']['viewport'];
      var reference = jsonResponse['results'][0]['formatted_address'];
      return Address(
        coords: coords,
        bounds: Bounds.fromJson(bounds),
        reference: reference,
        placeId: jsonResponse['results'][0]['place_id'] ?? '',
      );
    } else {
      throw ("Request failed with status: ${response.statusCode}");
    }
  }

  /// Calls Google Directions API sending `origin`, `destination` and `waypoints` [Coords].
  Future<Directions> getDirections(
      {@required Address origin,
      @required Address destination,
      @required List<Address> waypoints}) async {
    if (!origin.hasCoords)
      AssertionError('origin has to contain latitude and longitude values');
    if (!destination.hasCoords)
      AssertionError(
          'destination has to contain latitude and longitude values');
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.coords.toString()}&destination=${destination.coords.toString()}&language=$language&units=metric&region=$countryCode&mode=$mode&key=$googleApiKey';
    if (waypoints.isNotEmpty) {
      url += '&waypoints=';
      final int end = waypoints.length - 1;
      waypoints.asMap().forEach((index, element) => url += (index != end)
          ? '${element.coords.toString()}|'
          : '${element.coords.toString()}');
    }
    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      return null;
    }
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == "NOT_FOUND") throw ("NOT_FOUND");
      var routes = jsonResponse['routes'][0];
      return Directions(
        origin: origin,
        destination: destination,
        waypoints: waypoints,
        distance: _calcDistance(routes['legs']),
        duration: _calcDuration(routes['legs']),
        bounds: Bounds.fromJson(routes['bounds']),
        points: decodeEncodedPolyline(
            encoded: routes['overview_polyline']['points']),
      );
    } else {
      throw ("Request failed with status: ${response.statusCode}");
    }
  }

  /// `List<Map<String, dynamic>>`
  String _calcDistance(dynamic distances) {
    int value = 0;
    String suffix = 'm';
    try {
      distances.forEach((element) => value += element['distance']['value']);
      if (value > 999) {
        // meters to kilometers
        value = (value / 1000).round();
        suffix = 'km';
      }
    } catch (e) {}
    return '$value $suffix';
  }

  /// `List<Map<String, dynamic>>`
  String _calcDuration(dynamic durations) {
    int value = 0;
    String suffix = 'sec';
    try {
      durations.forEach((element) => value += element['duration']['value']);
      if (value > 60) {
        // seconds to minutes
        value = (value / 60).round();
        suffix = 'min';
      }
      if (value > 60) {
        // minutes to hours
        value = (value / 60).round();
        suffix = 'h';
      }
      if (value > 24) {
        // hours to days
        value = (value / 24).round();
        suffix = 'd';
      }
    } catch (e) {}
    return '$value $suffix';
  }

  /// Decodes an `encoded` [String] to create a [Polyline].
  static List<Coords> decodeEncodedPolyline({@required String encoded}) {
    if (encoded.isEmpty) AssertionError("encoded can't be empty");
    List<Coords> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    int decode(int positon) {
      int shift = 0, result = 0;
      do {
        positon = encoded.codeUnitAt(index++) - 63;
        result |= (positon & 0x1f) << shift;
        shift += 5;
      } while (positon >= 0x20);
      return ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    }

    while (index < len) {
      int positon;
      lat += decode(positon);
      lng += decode(positon);
      Coords point = Coords((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      points.add(point);
    }
    return points;
  }
}
