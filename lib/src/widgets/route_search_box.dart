part of 'package:address_search_field/address_search_field.dart';

/// Custom [WidgetBuilder] with two [AddressField] to call Google Directions API and get [Directions] beetwen two or more points.
class RouteSearchBox extends StatefulWidget {
  /// Constructor for [RouteSearchBox].
  RouteSearchBox({
    this.originIsMyLocation = false,
    this.onAddressLoading = 'Loading..',
    this.onAddressError = 'Unidentified place',
    @required this.geoMethods,
    TextEditingController originCtrl,
    TextEditingController destinationCtrl,
    TextEditingController waypointCtrl,
    @required this.builder,
  })  : assert(originIsMyLocation != null),
        assert(onAddressLoading != null),
        assert(onAddressError != null),
        assert(geoMethods != null),
        assert(builder != null),
        this.originCtrl = originCtrl ?? TextEditingController(),
        this.destinationCtrl = destinationCtrl ?? TextEditingController(),
        this.waypointCtrl = waypointCtrl ?? TextEditingController(),
        super();

  /// If it's true the user location will be set as the origin [Address].
  final bool originIsMyLocation;

  /// Text to show when origin location is loading.
  final String onAddressLoading;

  /// Text to show when origin location fails.
  final String onAddressError;

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// Controller for text used to search an [Address].
  final TextEditingController originCtrl;

  /// Controller for text used to search an [Address].
  final TextEditingController destinationCtrl;

  /// Controller for text used to search an [Address].
  final TextEditingController waypointCtrl;

  /// Custom [WidgetBuilder] that builds a widget by two [AddressSearchField] to get two [Address] objects and be able to call Google Directions API by `getDirections` to finally get a [Directions] object.
  final Widget Function(
    BuildContext context,
    AddressSearchBuilder originBuilder,
    AddressSearchBuilder destinationBuilder, {
    AddressSearchBuilder waypointBuilder,
    WaypointsManager waypointsMgr,
    void Function(AddressId addressId, Coords coords) relocate,
    Future<Directions> Function() getDirections,
  }) builder;

  @override
  _RouteSearchBoxState createState() => _RouteSearchBoxState();
}

class _RouteSearchBoxState extends State<RouteSearchBox> {
  /// Permits to work with the found [Address] by a [RouteSearchBox].
  final _addrComm = _AddrComm();

  @override
  Widget build(BuildContext context) {
    if (widget.originIsMyLocation)
      return FutureBuilder(
        future: _setOrigin(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          widget.originCtrl.text = (snapshot.hasError)
              ? widget.onAddressError
              : (snapshot.connectionState != ConnectionState.done)
                  ? widget.onAddressLoading
                  : snapshot.data;
          return _widget(context);
        },
      );
    return _widget(context);
  }

  /// [Widget] to return in [build] function.
  Widget _widget(BuildContext context) => widget.builder(
        context,
        AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.originCtrl,
          AddressId.origin,
          _addrComm,
        ),
        AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.destinationCtrl,
          AddressId.destination,
          _addrComm,
        ),
        waypointBuilder: AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.waypointCtrl,
          AddressId._waypoints,
          _addrComm,
        ),
        waypointsMgr: _addrComm.readAddrList(AddressId._waypoints),
        relocate: _relocate,
        getDirections: _getDirections,
      );

  /// When [widget.originIsMyLocation] is true, it will set current location in origin field.
  Future<String> _setOrigin() async {
    if (_addrComm.readAddr(AddressId.origin).hasReference)
      return _addrComm.readAddr(AddressId.origin).reference;
    final location = Location();
    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) throw RouteError.gps_disabled;
    }
    if (await location.hasPermission() == PermissionStatus.denied) {
      if (await location.requestPermission() != PermissionStatus.granted)
        throw RouteError.no_gps_permission;
    }
    final locationData = await location.getLocation();
    final coords = Coords(locationData.latitude, locationData.longitude);
    final address = await widget.geoMethods.geoLocatePlace(coords: coords);
    if (address == null) {
      _addrComm.writeAddr(AddressId.origin, Address(coords: coords));
      throw RouteError.location_not_found;
    }
    _addrComm.writeAddr(AddressId.origin, address);
    return address.reference;
  }

  /// Sets a new [Address].
  void _relocate(AddressId addrId, Coords coords) async {
    assert(addrId != null);
    assert(coords != null);
    if (addrId == AddressId.origin)
      widget.originCtrl.text = widget.onAddressLoading;
    else
      widget.destinationCtrl.text = widget.onAddressLoading;
    final address = await widget.geoMethods.geoLocatePlace(coords: coords);
    final found = address?.isCompleted ?? false;
    _addrComm.writeAddr(addrId, found ? address : Address(coords: coords));
    if (addrId == AddressId.origin)
      widget.originCtrl.text =
          found ? address.reference : widget.onAddressError;
    else
      widget.destinationCtrl.text =
          found ? address.reference : widget.onAddressError;
  }

  /// Gets directions using all the [Address] objects in [_addrComm].
  Future<Directions> _getDirections() async {
    if (!_addrComm.readAddr(AddressId.origin).hasCoords)
      throw RouteError.no_origin_coords;
    if (!_addrComm.readAddr(AddressId.destination).hasCoords)
      throw RouteError.no_dest_coords;
    final direc = await widget.geoMethods.getDirections(
        origin: _addrComm.readAddr(AddressId.origin),
        destination: _addrComm.readAddr(AddressId.destination),
        waypoints:
            _addrComm.readAddrList(AddressId._waypoints).valueNotifier.value);
    if (direc == null) throw RouteError.directions_not_found;
    return direc;
  }
}
