import 'package:address_search_field/src/enums/address_id.dart';
import 'package:address_search_field/src/models/coords.dart';
import 'package:address_search_field/src/models/directions.dart';
import 'package:address_search_field/src/enums/route_error.dart';
import 'package:address_search_field/src/models/address.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:flutter/widgets.dart';

/// Sets [Address] objects in the `provider`.
class LocationSetter {
  /// Constructor for [LocationSetter].
  LocationSetter({
    required this.coords,
    required this.addressId,
  });

  /// Coordinates to get and set an [Address].
  final Coords coords;

  /// Identifies the [Address] to work in the `provider`.
  final AddressId addressId;
}

/// Notifier to work with two or more points in [RouteSearchBox].
class RouteNotifier extends ChangeNotifier {
  /// Constructor for [RouteNotifier].
  RouteNotifier();

  late final GeoMethods _geoMethods;

  /// [GeoMethods] instance to use Google APIs.
  GeoMethods get geoMethods => _geoMethods;

  late final TextEditingController _originController;

  /// Controller for text used to search an [Address].
  TextEditingController get originController => _originController;

  late final TextEditingController _destinationController;

  /// Controller for text used to search an [Address].
  TextEditingController get destinationController => _destinationController;

  /// Initialize the [RouteNotifier].
  /// It's needed to can use the other `provider` methods.
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

  /// Sets waypoints as a new [List] of [Address].
  void setWaypoints(Iterable<Address> addressList) {
    _waypoints.clear();
    _waypoints.addAll(addressList);
    notifyListeners();
  }

  /// Adds an [Address] to the [List] of waypoints.
  void addWaypoint(Address address) {
    _waypoints.add(address);
    notifyListeners();
  }

  /// Adds an [Iterable<Address>] to the [List] of waypoints.
  void addWaypoints(Iterable<Address> addressList) {
    _waypoints.addAll(addressList);
    notifyListeners();
  }

  /// Updates an [Address] waypoint.
  void updateWaypoint(int index, Address address) {
    _waypoints[index] = _waypoints[index].copyWith(
      coordsParam: address.coords,
      boundsParam: address.bounds,
      referenceParam: address.reference,
      placeIdParam: address.placeId,
    );
    notifyListeners();
  }

  /// Reorder an [Address] waypoint.
  void reorderWaypoint(int oldIndex, int newIndex) {
    _waypoints.insert(
      newIndex,
      _waypoints.removeAt(oldIndex),
    );
    notifyListeners();
  }

  /// Remove an [Address] waypoint.
  void removeWaypointAt(int index) {
    _waypoints.removeAt(index);
    notifyListeners();
  }

  /// Clear the [List] of waypoints.
  void clearWaypoints() {
    _waypoints.clear();
    notifyListeners();
  }

  Directions? _route;

  /// Latest route directions found.
  Directions? get routeFound => _route;

  /// Sets a new [Address] where [AddressId] declares.
  Future<void> setLocation(AddressId addressId, Address address) async {
    if (addressId == AddressId.origin) {
      _origin = address;
      _originController.text = address.reference ?? '';
    } else if (addressId == AddressId.destination) {
      _destination = address;
      _destinationController.text = address.reference ?? '';
    } else if (addressId == AddressId.waypoint) {
      addWaypoint(address);
    }
    notifyListeners();
  }

  /// Finds a new [Address] by [Coords] and sets it where [AddressId] declares.
  Future<Address> relocate(AddressId addressId, Coords coords) async {
    final address = await geoMethods.geoLocatePlace(coords: coords);
    final newAddress =
        (address != null) ? address : Address.fromCoords(coords: coords);
    setLocation(addressId, newAddress);
    return newAddress;
  }

  /// Gets route directions if the origin and destination are set.
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
