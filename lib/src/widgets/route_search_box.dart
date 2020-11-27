part of 'package:address_search_field/address_search_field.dart';

/// Custom [WidgetBuilder] with two [AddressField] to call Google Directions API and get [Directions] beetwen two or more points.
class RouteSearchBox extends StatefulWidget {
  /// Constructor for [RouteSearchBox].
  RouteSearchBox({
    this.originIsMyLocation = false,
    this.onOriginLoading = 'Loading..',
    this.onOriginError,
    @required this.geoMethods,
    TextEditingController originCtrlr,
    TextEditingController destinationCtrlr,
    TextEditingController waypointCtrlr,
    @required this.builder,
  })  : assert(originIsMyLocation != null),
        assert(geoMethods != null),
        assert(builder != null),
        this.originCtrlr = originCtrlr ?? TextEditingController(),
        this.destinationCtrlr = destinationCtrlr ?? TextEditingController(),
        this.waypointCtrlr = waypointCtrlr ?? TextEditingController(),
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
  final TextEditingController originCtrlr;

  /// controller for text used to search an [Address].
  final TextEditingController destinationCtrlr;

  /// controller for text used to search an [Address].
  final TextEditingController waypointCtrlr;

  /// Custom [WidgetBuilder] that builds a widget by two [AddressSearchField] to get two [Address] objects and be able to call Google Directions API by `getDirections` to finally get a [Directions] object.
  final Widget Function(
    BuildContext context,
    AddressSearchBuilder originBuilder,
    AddressSearchBuilder destinationBuilder,
    AddressSearchBuilder waypointBuilder, {
    WaypointsManager waypointsMgr,
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
    if (widget.originIsMyLocation) {
      return FutureBuilder(
        future: _setOrigin(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          widget.originCtrlr.text = (snapshot.hasError)
              ? widget.onOriginError ?? snapshot.error
              : (snapshot.connectionState != ConnectionState.done)
                  ? widget.onOriginLoading ?? ''
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
          widget.originCtrlr,
          _BoxId.origin,
          _addrComm,
        ),
        AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.destinationCtrlr,
          _BoxId.destination,
          _addrComm,
        ),
        AddressSearchBuilder._fromBox(
          widget.geoMethods,
          widget.waypointCtrlr,
          _BoxId.waypoints,
          _addrComm,
        ),
        waypointsMgr: _addrComm.readAddrList(_BoxId.waypoints),
        getDirections: _getDirections,
      );

  /// When [widget.originIsMyLocation] is true, it will set current location in origin field.
  Future<String> _setOrigin() async {
    if (_addrComm.readAddr(_BoxId.origin).hasReference)
      return Future.value(_addrComm.readAddr(_BoxId.origin).reference);
    final Location location = Location();
    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) throw 'GPS service is disabled';
    }
    if (await location.hasPermission() == PermissionStatus.denied) {
      if (await location.requestPermission() != PermissionStatus.granted)
        throw 'No GPS permissions';
    }
    final locationData = await location.getLocation();
    final coords = Coords(locationData.latitude, locationData.longitude);
    Address address = await widget.geoMethods.geoLocatePlace(coords: coords);
    if (address == null) {
      _addrComm.writeAddr(_BoxId.origin, Address(coords: coords));
      throw 'Location not found';
    }
    _addrComm.writeAddr(_BoxId.origin, address);
    return Future.value(address.reference);
  }

  /// Gets directions using all the [Address] objects in [_addrComm].
  Future<Directions> _getDirections() async {
    if (!_addrComm.readAddr(_BoxId.origin).hasCoords) throw 'No origin coords';
    if (!_addrComm.readAddr(_BoxId.destination).hasCoords)
      throw 'No destination coords';
    if (_addrComm.readAddr(_BoxId.origin).hasCoords &&
        _addrComm.readAddr(_BoxId.destination).hasCoords) {
      Directions direc = await widget.geoMethods.getDirections(
          origin: _addrComm.readAddr(_BoxId.origin),
          destination: _addrComm.readAddr(_BoxId.destination),
          waypoints:
              _addrComm.readAddrList(_BoxId.waypoints).valueNotifier.value);
      if (direc == null) throw 'Directions not found';
      return direc;
    }
    return null;
  }
}
