import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:address_search_field/src/widgets/address_field.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:address_search_field/src/models/directions.dart';
import 'package:address_search_field/src/models/address.dart';

/// Custom [WidgetBuilder] with two [AddressField] to call Google Directions API and get [Directions] beetwen two or more points.
class RouteSearchBox extends StatelessWidget {
  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// Constructor for `origin` [AddressField].
  final AddressFieldBuilder originBldr;

  /// Constructor for `destination` [AddressField].
  final AddressFieldBuilder destinationBldr;

  /// Custom [WidgetBuilder] that builds a widget by two [AddressSearchField] to get two [Address] objects and be able to call Google Directions API by `getDirections` to finally get a [Directions] object.
  final Widget Function(
    BuildContext context,
    AddressField originField,
    AddressField destinationField,
    Future<Directions> Function(List<Address> waypoints) getDirections,
  ) widgetBuilder;

  /// Text for [Fluttertoast] when something goes wrong.
  final String errorText;

  /// Text for [Fluttertoast] when `getDirections` is called without origin coords.
  final String noOriginText;

  /// Text for [Fluttertoast] when `getDirections` is called without destination coords.
  final String noDestText;

  /// Constructor for [RouteSearchBox].
  RouteSearchBox({
    @required this.geoMethods,
    @required this.originBldr,
    @required this.destinationBldr,
    @required this.widgetBuilder,
    String errorText,
    String noOriginText,
    String noDestText,
  })  : this.errorText = errorText ?? 'Unexpected error',
        this.noOriginText = noOriginText ?? 'No origin coords',
        this.noDestText = noDestText ?? 'No destination coords' {
    originBldr.addressDialog.result = _origin;
    destinationBldr.addressDialog.result = _destination;
  }

  static final Address _origin = Address();
  static final Address _destination = Address();

  @override
  Widget build(BuildContext context) {
    return widgetBuilder(
      context,
      originBldr.build(geoMethods: geoMethods),
      destinationBldr.build(geoMethods: geoMethods),
      _getDirections,
    );
  }

  Future<Directions> _getDirections(List<Address> waypoints) async {
    if (!_origin.hasCoords)
      Fluttertoast.showToast(
        msg: noOriginText,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        webPosition: 'center',
        webBgColor: '#BDBDBD',
      );
    if (!_destination.hasCoords)
      Fluttertoast.showToast(
        msg: noDestText,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 2,
        webPosition: 'center',
        webBgColor: '#BDBDBD',
      );
    if (_origin.hasCoords && _destination.hasCoords) {
      Directions direc = await geoMethods.getDirections(
          origin: _origin,
          destination: _destination,
          waypoints: waypoints ?? []);
      if (direc == null)
        Fluttertoast.showToast(
          msg: errorText,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 2,
          webPosition: 'center',
          webBgColor: '#BDBDBD',
        );
      else
        return direc;
    }
    return null;
  }
}
