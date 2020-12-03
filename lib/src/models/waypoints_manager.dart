part of 'package:address_search_field/address_search_field.dart';

/// Permits read and reorder a [List] of [Address].
class WaypointsManager {
  /// Constructor for [WaypointsManager].
  WaypointsManager._(
      this.valueNotifier, this.onReorder, this.remove, this.clear);

  /// A [ValueNotifier] to create a [Widget] updable.
  final ValueNotifier<List<Address>> valueNotifier;

  /// [Function] to reorder a [List] of [Address].
  /// It is to can use a [ReorderableList](https://pub.dev/packages/flutter_reorderable_list).
  final void Function(int oldIndex, int newIndex) onReorder;

  /// [Function] to remove an element from the [List] of [Address].
  final void Function(int index) remove;

  /// [Function] to clear the [List] of [Address].
  final void Function() clear;
}
