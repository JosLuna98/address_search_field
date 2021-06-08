import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// Country code to search routes in a specific region.
  /// List of countries [here](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  final String countryCode;

  /// Country code to search and autocomplete addresses filtering up to 5 countries .
  /// List of countries [here](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).
  final List<String> countryCodes;

  /// Country to filter address results.
  final String country;

  /// City to filter address results.
  final String city;

  /// By default, directions are calculated as `driving` directions. It can also be `walking`, `bicycling`, `transit`. See [documentation](https://developers.google.com/maps/documentation/directions/overview#TravelModes).
  final String mode;

  /// Contructor for [GeoMethods].
  GeoMethods({
    required this.googleApiKey,
    required this.language,
    this.countryCode = '',
    this.countryCodes = const <String>[],
    this.country = '',
    this.city = '',
    this.mode = 'driving',
  })  : assert(countryCode == '' || countryCode.length == 2,
            'country must be passed as two character, ISO 3166-1 Alpha-2 compatible country code'),
        assert(countryCodes.length <= 5, 'just can filter up to 5 countries'),
        assert(countryCodes.every((c) => c.length == 2),
            'countries must be passed as two character, ISO 3166-1 Alpha-2 compatible country code');

  /// Permits to use an [GeoMethods] copy with updated data.
  GeoMethods copyWith({
    String? apiKeyParam,
    String? languageParam,
    String? countryCodeParam,
    List<String>? countryCodesParam,
    String? countryParam,
    String? cityParam,
    String? modeParam,
  }) =>
      GeoMethods(
        googleApiKey: apiKeyParam ?? googleApiKey,
        language: languageParam ?? language,
        countryCode: countryCodeParam ?? countryCode,
        countryCodes: countryCodesParam ?? countryCodes,
        country: countryParam ?? country,
        city: cityParam ?? city,
        mode: modeParam ?? mode,
      );

  /// Calls AutoComplete of Google Place API sending a `query`.
  /// Each [Address] just have `reference` and `place_id`.
  Future<List<Address>?> autocompletePlace({required String query}) async {
    if (query.isEmpty) return <Address>[];
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'key': googleApiKey,
        'language': language,
        'input': query +
            (city.isNotEmpty ? ', $city' : '') +
            (country.isNotEmpty ? ', $country' : ''),
        if (countryCodes.isNotEmpty)
          'components': countryCodes.map((c) => 'country:$c').join('|')
        else if (countryCode.isNotEmpty)
          'components': 'country:$countryCode',
      },
    );
    try {
      final response = await http.get(uri);
      final list = <Address>[];
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body)['predictions'];
        jsonResponse.forEach((element) => list.add(Address(
            reference: element['description'], placeId: element['place_id'])));
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
      return list;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Calls Details of Google Place API sending a `place_id`.
  Future<Address?> getPlaceGeometry({
    required String? reference,
    required String placeId,
  }) async {
    assert(
        placeId.isNotEmpty, "placeId can't be declared as an empty `String`");
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'geometry',
        'key': googleApiKey,
      },
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final coords = jsonResponse['result']['geometry']['location'];
        final bounds = jsonResponse['result']['geometry']['viewport'];
        return Address(
            coords: Coords.fromJson(coords),
            bounds: Bounds.fromJson(bounds),
            reference: reference,
            placeId: placeId);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Calls Google Geocode API sending `latitude` and `longitude` of [Coords].
  Future<Address?> geoLocatePlace({required Coords coords}) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': coords.toString(),
        'result_type': 'street_address',
        'language': language,
        'key': googleApiKey,
      },
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final bounds = jsonResponse['results'][0]['geometry']['viewport'];
        final reference = jsonResponse['results'][0]['formatted_address'];
        return Address(
          coords: coords,
          bounds: Bounds.fromJson(bounds),
          reference: reference,
          placeId: jsonResponse['results'][0]['place_id'] ?? '',
        );
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Calls Google Directions API sending `origin`, `destination` and `waypoints` [Coords].
  Future<Directions?> getDirections({
    required Address origin,
    required Address destination,
    List<Address?> waypoints = const <Address>[],
  }) async {
    assert(countryCode.isNotEmpty,
        'countryCode parameter is required to get Directions');
    assert(origin.hasCoords, 'origin has to contain coordinates values');
    assert(
        destination.hasCoords, 'destination has to contain coordinates values');
    String wps = '';
    if (waypoints.isNotEmpty) {
      waypoints.asMap().forEach((index, element) {
        if (element!.hasCoords)
          wps += (index != waypoints.length - 1)
              ? '${element.coords.toString()}|'
              : '${element.coords.toString()}';
        else
          print("waypoint $index doesn't have coords");
      });
    }
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin.coords.toString(),
      'destination': destination.coords.toString(),
      'language': language,
      'units': 'metric',
      'region': countryCode,
      'mode': mode,
      'key': googleApiKey,
      if (wps.isNotEmpty) 'waypoints': wps,
    });
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final routes = jsonResponse['routes'][0];
        return Directions(
          origin: origin,
          destination: destination,
          waypoints: waypoints as List<Address>,
          distance: _calcDistance(routes['legs']),
          duration: _calcDuration(routes['legs']),
          bounds: Bounds.fromJson(routes['bounds']),
          points: decodeEncodedPolyline(
              encoded: routes['overview_polyline']['points']),
        );
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Param is `List<Map<String, dynamic>>`
  String _calcDistance(dynamic distances) {
    int value = 0;
    String suffix = 'm';
    try {
      distances.forEach(
          (element) => value += (element['distance']['value'] as int?)!);
      if (value > 999) {
        // meters to kilometers
        value = (value / 1000).round();
        suffix = 'km';
      }
    } catch (e) {}
    return '$value $suffix';
  }

  /// Param is `List<Map<String, dynamic>>`
  String _calcDuration(dynamic durations) {
    int value = 0;
    String suffix = 'sec';
    try {
      durations.forEach(
          (element) => value += (element['duration']['value'] as int?)!);
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
  static List<Coords> decodeEncodedPolyline({required String encoded}) {
    assert(encoded.isNotEmpty, "encoded can't be empty");
    final points = <Coords>[];
    final len = encoded.length;
    int index = 0;
    int lat = 0, lng = 0;

    /// decodes an `encoded` character.
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
      int positon = 0;
      lat += decode(positon);
      lng += decode(positon);
      final point = Coords((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      points.add(point);
    }
    return points;
  }
}
