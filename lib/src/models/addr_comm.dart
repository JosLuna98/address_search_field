part of 'package:address_search_field/address_search_field.dart';

/// Address Comunicator.
class _AddrComm extends ChangeNotifier {
  /// [Address] to identify an origin.
  final _origin = Address();

  /// [Address] to identify a destination.
  final _destination = Address();

  /// [List] of [Address] to identify waypoints.
  final _waypoints = ValueNotifier<List<Address>>(List<Address>());

  /// Writes an [Address] by a [AddressId].
  void writeAddr(AddressId id, Address addr) {
    if (id == AddressId.origin) _origin.update(addr);
    if (id == AddressId.destination) _destination.update(addr);
    if (id == AddressId._waypoints && !_waypoints.value.contains(addr)) {
      _waypoints.value.add(addr);
      _waypoints.notifyListeners();
    }
  }

  /// Reads an [Address] by a [AddressId].
  Address readAddr(AddressId id) {
    assert(id != AddressId._waypoints);
    if (id == AddressId.origin)
      return _origin;
    else
      return _destination;
  }

  /// Gets an [WaypointsManager] by verifying the [AddressId].
  WaypointsManager readAddrList(AddressId id) {
    assert(id == AddressId._waypoints);
    return WaypointsManager._(_waypoints, _onReorderAddrList,
        _removeAddrListElement, _clearAddrListElement);
  }

  /// Reorders the [Address] in the `waypoints` [List].
  void _onReorderAddrList(int oldIndex, int newIndex) {
    _waypoints.value.insert(
      newIndex,
      _waypoints.value.removeAt(oldIndex),
    );
    _waypoints.notifyListeners();
  }

  /// Removes an element in the `waypoints` [List].
  void _removeAddrListElement(int index) {
    _waypoints.value.remove(index);
    _waypoints.notifyListeners();
  }

  /// Clears the `waypoints` [List].
  void _clearAddrListElement() {
    _waypoints.value.clear();
    _waypoints.notifyListeners();
  }
}
