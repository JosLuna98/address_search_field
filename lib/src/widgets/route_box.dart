import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wrapper to work with provider and call Google Directions API and get [Directions] beetwen two or more points.
class RouteBox extends ConsumerStatefulWidget {
  /// Constructor for [RouteBox].
  const RouteBox({
    required this.provider,
    required this.geoMethods,
    required this.originController,
    required this.destinationController,
    required this.child,
    this.locationSetters = const <LocationSetter>[],
    Key? key,
  }) : super(key: key);

  /// Used to connect widgets and manage state.
  final ChangeNotifierProvider<RouteNotifier> provider;

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// Controller for text used to search an [Address].
  final TextEditingController originController;

  /// Controller for text used to search an [Address].
  final TextEditingController destinationController;

  /// Sets [Address] objects in the `provider`.
  final List<LocationSetter> locationSetters;

  /// [Widget] wrapped.
  final Widget child;

  @override
  ConsumerState<RouteBox> createState() => _RouteBoxState();
}

class _RouteBoxState extends ConsumerState<RouteBox> {
  @override
  void initState() {
    super.initState();
    ref.read(widget.provider).initRouteNotifier(
          widget.geoMethods,
          widget.originController,
          widget.destinationController,
          locationSetters: widget.locationSetters,
        );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
