part of 'package:address_search_field/address_search_field.dart';

/// Custom [WidgetBuilder] with two [AddressField] to call Google Directions API and get [Directions] beetwen two or more points.
class RouteSearchBox extends StatefulWidget {
  /// Constructor for [RouteSearchBox].
  RouteSearchBox({
    this.originIsMyLocation = false,
    this.onOriginLoading = 'Loading..',
    this.onOriginError = 'Unidentified place',
    @required this.geoMethods,
    TextEditingController originCtrl,
    TextEditingController destinationCtrl,
    TextEditingController waypointCtrl,
    @required this.builder,
  })  : assert(originIsMyLocation != null),
        assert(onOriginLoading != null),
        assert(onOriginError != null),
        assert(geoMethods != null),
        assert(builder != null),
        this.originCtrl = originCtrl ?? TextEditingController(),
        this.destinationCtrl = destinationCtrl ?? TextEditingController(),
        this.waypointCtrl = waypointCtrl ?? TextEditingController(),
        super();

  /// If it's true the user location will be set as the origin [Address].
  final bool originIsMyLocation;

  /// Text to show when origin location is loading.
  final String onOriginLoading;

  /// Text to show when origin location fails.
  final String onOriginError;

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// controller for text used to search an [Address].
  final TextEditingController originCtrl;

  /// controller for text used to search an [Address].
  final TextEditingController destinationCtrl;

  /// controller for text used to search an [Address].
  final TextEditingController waypointCtrl;

  /// Custom [WidgetBuilder] that builds a widget by two [AddressSearchField] to get two [Address] objects and be able to call Google Directions API by `getDirections` to finally get a [Directions] object.
  final Widget Function(
    BuildContext context,
    AddressSearchBuilder originBuilder,
    AddressSearchBuilder destinationBuilder, {
    AddressSearchBuilder waypointBuilder,
    WaypointsManager waypointsMgr,
    void Function() relocate,
    Future<Directions> Function() getDirections,
  }) builder;

  @override
  _RouteSearchBoxState createState() => _RouteSearchBoxState();
}

class _RouteSearchBoxState extends State<RouteSearchBox> {
  /// Permits to work with the found [Address] by a [RouteSearchBox].
  final _addrComm = _AddrComm();

  /// Sets if [_setOrigin] will over-write [widget.originCtrlr.text].
  bool _forced = false;

  @override
  Widget build(BuildContext context) {
    if (widget.originIsMyLocation) {
      return FutureBuilder(
        future: _setOrigin(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          widget.originCtrl.text = (snapshot.hasError)
              ? widget.onOriginError
              : (snapshot.connectionState != ConnectionState.done)
                  ? widget.onOriginLoading
                  : snapshot.data;
          return _widget(context);
        },
      );
    }
    return _widget(context);
  }

  /// [Widget] to return in [build] function.
  Widget _widget(BuildContext context) => widget.builder(
        context,
        AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.originCtrl,
          _BoxId.origin,
          _addrComm,
        ),
        AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.destinationCtrl,
          _BoxId.destination,
          _addrComm,
        ),
        waypointBuilder: AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.waypointCtrl,
          _BoxId.waypoints,
          _addrComm,
        ),
        waypointsMgr: _addrComm.readAddrList(_BoxId.waypoints),
        relocate: _relocate,
        getDirections: _getDirections,
      );

  /// When [widget.originIsMyLocation] is true, it will set current location in origin field.
  Future<String> _setOrigin() async {
    if (_addrComm.readAddr(_BoxId.origin).hasReference && !_forced)
      return Future.value(_addrComm.readAddr(_BoxId.origin).reference);
    try {
      final Location location = Location();
      if (!await location.serviceEnabled()) {
        if (!await location.requestService()) throw RouteError.gps_disabled;
      }
      if (await location.hasPermission() == PermissionStatus.denied) {
        if (await location.requestPermission() != PermissionStatus.granted)
          throw RouteError.no_gps_permission;
      }
      final locationData = await location.getLocation();
      final coords = Coords(locationData.latitude, locationData.longitude);
      Address address = await widget.geoMethods.geoLocatePlace(coords: coords);
      if (address == null) {
        _addrComm.writeAddr(_BoxId.origin, Address(coords: coords));
        throw RouteError.location_not_found;
      }
      _addrComm.writeAddr(_BoxId.origin, address);
      return Future.value(address.reference);
    } catch (e) {
      print(e);
      throw e;
    } finally {
      _forced = false;
    }
  }

  /// Rebuilds widget and set origin again.
  void _relocate() {
    setState(() => _forced = true);
  }

  /// Gets directions using all the [Address] objects in [_addrComm].
  Future<Directions> _getDirections() async {
    if (!_addrComm.readAddr(_BoxId.origin).hasCoords)
      throw RouteError.no_origin_coords;
    if (!_addrComm.readAddr(_BoxId.destination).hasCoords)
      throw RouteError.no_dest_coords;
    Directions direc = await widget.geoMethods.getDirections(
        origin: _addrComm.readAddr(_BoxId.origin),
        destination: _addrComm.readAddr(_BoxId.destination),
        waypoints:
            _addrComm.readAddrList(_BoxId.waypoints).valueNotifier.value);
    if (direc == null) throw RouteError.directions_not_found;
    return direc;
  }
}
