part of 'package:address_search_field/address_search_field.dart';

/// `enum` which identifies [Address] in [_AddrComm] class.
enum AddressId {
  /// Identify [Address] object.
  origin,

  /// Identify [Address] object.
  destination,

  /// Identify [List] of [Address].
  _waypoints
}
