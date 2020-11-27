part of 'package:address_search_field/address_search_field.dart';

/// `enum` which identifies [Address] in [_AddrComm]
enum _BoxId {
  /// Identify [Address] object.
  origin,

  /// Identify [Address] object.
  destination,

  /// Identify [List] of [Address].
  waypoints
}

/// Address Comunicator.
class _AddrComm extends ChangeNotifier {
  /// [Address] to identify an origin.
  final Address _origin = Address();

  /// [Address] to identify a destination.
  final Address _destination = Address();

  /// [List] of [Address] to identify waypoints.
  final ValueNotifier<List<Address>> _waypoints =
      ValueNotifier<List<Address>>(List<Address>());

  /// Writes an [Address] by a [_BoxId].
  void writeAddr(_BoxId id, Address addr) {
    if (id == _BoxId.origin) _origin.update(addr);
    if (id == _BoxId.destination) _destination.update(addr);
    if (id == _BoxId.waypoints && !_waypoints.value.contains(addr)) {
      _waypoints.value.add(addr);
      _waypoints.notifyListeners();
    }
  }

  /// Reads an [Address] by a [_BoxId].
  Address readAddr(_BoxId id) {
    assert(id != _BoxId.waypoints);
    if (id == _BoxId.origin)
      return _origin;
    else
      return _destination;
  }

  /// Gets an [WaypointsManager] by verifying the [_BoxId].
  WaypointsManager readAddrList(_BoxId id) {
    assert(id == _BoxId.waypoints);
    return WaypointsManager._(
        _waypoints, _onReorderAddrList, _onDeleteAddrListElement);
  }

  /// Reorders the [Address] in the `waypoints` [List].
  void _onReorderAddrList(int oldIndex, int newIndex) {
    final addr = _waypoints.value.removeAt(oldIndex);
    _waypoints.value.insert(newIndex, addr);
    _waypoints.notifyListeners();
  }

  /// Removes an element in the `waypoints` [List].
  void _onDeleteAddrListElement(int index) {
    _waypoints.value.remove(index);
    _waypoints.notifyListeners();
  }
}

/// Permits read and reorder a [List] of [Address].
class WaypointsManager {
  /// Constructor for [WaypointsManager].
  WaypointsManager._(this.valueNotifier, this.onReorder, this.onDelete);

  /// A [ValueNotifier] to create a [Widget] updable.
  final ValueNotifier<List<Address>> valueNotifier;

  /// [Function] to reorder a [List] of [Address].
  /// It is to can use a [ReorderableList](https://pub.dev/packages/flutter_reorderable_list).
  final void Function(int oldIndex, int newIndex) onReorder;

  /// [Function] to remove an element from the [List] of [Address].
  final void Function(int index) onDelete;
}
