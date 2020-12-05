part of 'package:address_search_field/address_search_field.dart';

/// Callback method.
typedef void LocatorCallback(Future<Address> Function(Coords coords) relocate);

/// Sets an initital address reference in the [TextEditingController].
class AddressLocator extends StatelessWidget {
  /// Consturtor for [AddressLocator].
  const AddressLocator({
    @required this.geoMethods,
    @required this.controller,
    @required this.locator,
    @required this.child,
    this.onAddressLoading = 'Loading...',
    this.onAddressError = 'Unidentifed place',
  })  : assert(geoMethods != null),
        assert(controller != null),
        assert(locator != null),
        assert(child != null),
        assert(onAddressLoading != null),
        assert(onAddressError != null),
        super();

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// controller for text used to search an [Address].
  final TextEditingController controller;

  /// Callback to get an [Address] by [Coords].
  final LocatorCallback locator;

  /// It's usually a [TextField].
  final Widget child;

  /// Text to show when origin location is loading.
  final String onAddressLoading;

  /// Text to show when origin location fails.
  final String onAddressError;

  @override
  Widget build(BuildContext context) {
    locator(_relocate);
    return child;
  }

  /// Gets an address reference by [Coords].
  Future<Address> _relocate(Coords coords) async {
    controller.text = onAddressLoading;
    final address = await geoMethods.geoLocatePlace(coords: coords);
    final found = address?.isCompleted ?? false;
    controller.text = found ? address.reference : onAddressError;
    return found ? address : Address(coords: coords);
  }
}
