import 'package:address_search_field/src/enums/address_id.dart';
import 'package:address_search_field/src/models/coords.dart';
import 'package:address_search_field/src/models/directions.dart';
import 'package:address_search_field/src/enums/route_error.dart';
import 'package:address_search_field/src/models/address.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:flutter/widgets.dart';

class LocationSetter {
  LocationSetter({
    required this.coords,
    required this.addressId,
  });

  final Coords coords;

  final AddressId addressId;
}

class RouteNotifier extends ChangeNotifier {
  late final GeoMethods _geoMethods;

  GeoMethods get geoMethods => _geoMethods;

  late final TextEditingController _originController;

  TextEditingController get originController => _originController;

  late final TextEditingController _destinationController;

  TextEditingController get destinationController => _destinationController;

  void initRouteNotifier(
    GeoMethods geoMethods,
    TextEditingController originController,
    TextEditingController destinationController, {
    List<LocationSetter> locationSetters = const <LocationSetter>[],
  }) {
    _geoMethods = geoMethods;
    _originController = originController;
    _destinationController = destinationController;
    for (var setter in locationSetters) {
      relocate(setter.addressId, setter.coords);
    }
  }

  Address? _origin;

  /// Origin point of a route.
  Address? get origin => _origin;

  Address? _destination;

  /// Destination point of a route.
  Address? get destination => _destination;

  final List<Address> _waypoints = <Address>[];

  /// Points beetwen origin and destination of a route.
  List<Address> get waypoints => _waypoints;

  void setWaypoints(Iterable<Address> addressList) {
    _waypoints.clear();
    _waypoints.addAll(addressList);
    notifyListeners();
  }

  void addWaypoint(Address address) {
    _waypoints.add(address);
    notifyListeners();
  }

  void addWaypoints(Iterable<Address> addressList) {
    _waypoints.addAll(addressList);
    notifyListeners();
  }

  void updateWaypoint(int index, Address address) {
    _waypoints[index] = _waypoints[index].copyWith(
      coordsParam: address.coords,
      boundsParam: address.bounds,
      referenceParam: address.reference,
      placeIdParam: address.placeId,
    );
    notifyListeners();
  }

  void reorderWaypoint(int oldIndex, int newIndex) {
    try {
      _waypoints.insert(
        newIndex,
        _waypoints.removeAt(oldIndex),
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  void removeWaypointAt(int index) {
    _waypoints.removeAt(index);
    notifyListeners();
  }

  void clearWaypoints() {
    _waypoints.clear();
    notifyListeners();
  }

  Directions? _route;

  Directions? get routeFound => _route;

  Future<void> setLocation(AddressId addressId, Address address) async {
    if (addressId == AddressId.origin) {
      _origin = address;
      _originController.text = address.reference!;
    } else if (addressId == AddressId.destination) {
      _destination = address;
      _destinationController.text = address.reference!;
    } else if (addressId == AddressId.waypoint) {
      addWaypoint(address);
    }
    notifyListeners();
  }

  Future<Address> relocate(AddressId addressId, Coords coords) async {
    final address = await geoMethods.geoLocatePlace(coords: coords);
    final newAddress =
        (address != null) ? address : Address.fromCoords(coords: coords);
    setLocation(addressId, newAddress);
    return newAddress;
  }

  Future<Directions> findRoute() async {
    if (_origin != null && _destination != null) {
      final route = await _geoMethods.getDirections(
        origin: _origin!,
        destination: _destination!,
        waypoints: _waypoints,
      );
      if (route != null) {
        _route = route;
        notifyListeners();
        return route;
      } else {
        throw RouteError.directionsNotFound;
      }
    } else {
      if (_origin == null) throw RouteError.noOriginCoords;
      if (_destination == null) throw RouteError.noDestCoords;
    }
    throw RouteError.unexpectedError;
  }
}

// final RouteNotifier firstRoute = RouteNotifier();
// final routeProvider = ChangeNotifierProvider<RouteNotifier>((ref) => firstRoute);
