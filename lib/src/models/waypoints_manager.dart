part of 'package:address_search_field/address_search_field.dart';

/// Callback method.
typedef void OnReorderCallback(int oldIndex, int newIndex);

/// Callback method.
typedef void UpdateCallback(int index, Address newAddress);

/// Callback method.
typedef void RemoveCallback(int index);

/// Callback method.
typedef void ClearCallback();

/// Permits read and reorder a [List] of [Address].
class WaypointsManager {
  /// Constructor for [WaypointsManager].
  WaypointsManager._(
      this.valueNotifier, this.onReorder, this.update, this.remove, this.clear);

  /// A [ValueNotifier] to create a [Widget] updable.
  final ValueNotifier<List<Address?>> valueNotifier;

  /// [Function] to reorder a [List] of [Address].
  /// It is to can use a [ReorderableList](https://pub.dev/packages/flutter_reorderable_list).
  final OnReorderCallback onReorder;

  /// [Function] to update an element in the [List] of [Address].
  final UpdateCallback update;

  /// [Function] to remove an element in the [List] of [Address].
  final RemoveCallback remove;

  /// [Function] to clear the [List] of [Address].
  final ClearCallback clear;
}
