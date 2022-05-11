import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteBox extends ConsumerStatefulWidget {
  const RouteBox({
    required this.provider,
    required this.geoMethods,
    required this.originController,
    required this.destinationController,
    required this.child,
    this.locationSetters = const <LocationSetter>[],
    Key? key,
  }) : super(key: key);

  final ChangeNotifierProvider<RouteNotifier> provider;

  final GeoMethods geoMethods;

  final TextEditingController originController;

  final TextEditingController destinationController;

  final List<LocationSetter> locationSetters;

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
