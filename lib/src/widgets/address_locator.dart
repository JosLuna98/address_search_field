import 'dart:async';
import 'package:address_search_field/src/widgets/address_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:address_search_field/src/models/address.dart';
import 'package:address_search_field/src/models/coords.dart';
import 'package:address_search_field/src/services/geo_methods.dart';

/// Callback method.
typedef SetAddressCallback = void Function(Address origin);

/// Use [Coords] to get an [Address].
class AddressLocator extends ConsumerStatefulWidget {
  /// Constructor for [AddressLocator].
  AddressLocator({
    required this.coords,
    required this.geoMethods,
    required this.child,
    TextEditingController? controller,
    this.onDone,
    this.onAddressLoading = 'Loading..',
    this.onAddressError = 'Unidentified place',
    Key? key,
  })  : controller = controller ?? TextEditingController(),
        super(key: key);

  /// Coordinates to get an [Address].
  final Coords coords;

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// controller for text used to search an [Address].
  final TextEditingController controller;

  /// It's usually a [TextField].
  final Widget child;

  /// Text to show when origin location is loading.
  final String onAddressLoading;

  /// Text to show when origin location fails.
  final String onAddressError;

  /// Callback for [AddressSearchDialog] to use [Address] found.
  final OnDoneCallback? onDone;

  @override
  ConsumerState<AddressLocator> createState() => _AddressLocatorState();
}

class _AddressLocatorState extends ConsumerState<AddressLocator> {
  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _setInitialLocation() async {
    widget.controller.text = widget.onAddressLoading;
    final Address? address =
        await widget.geoMethods.geoLocatePlace(coords: widget.coords);
    final bool found = address?.isCompleted ?? false;
    final addressResult =
        found ? address! : Address.fromCoords(coords: widget.coords);
    widget.controller.text =
        found ? address!.reference! : widget.onAddressError;
    if (widget.onDone != null) {
      await widget.onDone!(addressResult);
    }
  }
}
