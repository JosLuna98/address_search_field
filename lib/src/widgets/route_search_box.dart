import 'dart:async';
import 'package:flutter/material.dart';
import 'package:address_search_field/src/widgets/address_search_field.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:address_search_field/src/models/directions.dart';
import 'package:address_search_field/src/models/address.dart';

/// Custom [WidgetBuilder] with two [AddressSearchField] to call Google Directions API and get [Directions beetwen two or more points.
class RouteSearchBox extends StatelessWidget {
  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// Constructor for `origin` [AddressSearchField].
  final AddressFieldCtor originCtor;

  /// Controller for [TextField] in the `origin` [AddressSearchField].
  final TextEditingController originCtrl;

  /// Constructor for `destination` [AddressSearchField].
  final AddressFieldCtor destinationCtor;

  /// Controller for [TextField] in the `destination` [AddressSearchField].
  final TextEditingController destinationCtrl;

  /// Custom [WidgetBuilder] that builds a widget by two [AddressSearchField] to get two [Address] objects and be able to call Google Directions API by `getDirections` to finally get a [Directions] object.
  final Widget Function(
    BuildContext context,
    AddressSearchField originField,
    AddressSearchField destinationField,
    Future<Directions> Function(List<Address> waypoints) getDirections,
  ) widgetBuilder;

  /// Constructor for [RouteSearchBox].
  RouteSearchBox({
    @required this.geoMethods,
    @required this.originCtor,
    TextEditingController originCtrl,
    @required this.destinationCtor,
    TextEditingController destinationCtrl,
    @required this.widgetBuilder,
  })  : this.originCtrl = originCtrl ?? TextEditingController(),
        this.destinationCtrl = destinationCtrl ?? TextEditingController() {
    originCtor.addressDialog.result = _origin;
    destinationCtor.addressDialog.result = _destination;
  }

  static final Address _origin = Address();
  static final Address _destination = Address();

  @override
  Widget build(BuildContext context) {
    return widgetBuilder(
      context,
      AddressSearchField.ctor(
        constructor: originCtor,
        controller: originCtrl,
        geoMethods: geoMethods,
      ),
      AddressSearchField.ctor(
        constructor: destinationCtor,
        controller: destinationCtrl,
        geoMethods: geoMethods,
      ),
      _getDirections,
    );
  }

  Future<Directions> _getDirections(List<Address> waypoints) async {
    if (_origin.hasCoords && _destination.hasCoords)
      return await geoMethods.getDirections(
          origin: _origin,
          destination: _destination,
          waypoints: waypoints ?? []);
    return null;
  }
}
