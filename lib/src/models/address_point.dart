part of '../../address_search_field.dart';

/// An object to control the results from [AddressSearchBox] class.
///
/// Saves info about a found place in a concrete [country].
///
/// It also allows to generate a new asynchonous object from latitude and
/// longitude values passed to [fromPoint] method.
class AddressPoint {
  String _address;
  double _latitude;
  double _longitude;
  String _country;

  /// Constructs an [AddressPoint] object to save and
  /// use the [AddressSearchBox] result.
  AddressPoint({
    @required String address,
    @required double latitude,
    @required double longitude,
    @required String country,
  })  : _address = address,
        _latitude = latitude,
        _longitude = longitude,
        _country = country;

  /// Constructs an [AddressPoint] object to only be used in this file.
  AddressPoint._()
      : _address = "",
        _latitude = 0.0,
        _longitude = 0.0,
        _country = "";

  /// Generates an [AddressPoint] from finding address from latitude
  /// and longitude values passed.
  static Future<AddressPoint> fromPoint(
      {@required double latitude, @required double longitude}) async {
    assert(latitude != null && longitude != null,
        "fromPoint method won't work without coordinates");
    await initLocationService();
    String address;
    String country;
    try {
      Coordinates coordinates = Coordinates(latitude, longitude);
      List<Address> addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      address = addresses[0].addressLine;
      country = address.split(", ").last;
      return AddressPoint(
        address: address,
        latitude: latitude,
        longitude: longitude,
        country: country,
      );
    } on NoSuchMethodError catch (_) {} on PlatformException catch (_) {} catch (_) {
      debugPrint("ERROR CATCHED: " + _.toString());
    }
    return null;
  }

  /// Returns country name given in the constructor.
  String get country => _country;

  /// Returns a [bool] to know if object has a found [address].
  bool get found => (_address.toLowerCase().endsWith(_country.toLowerCase()) &&
      ((_latitude != null && _latitude != 0.0) &&
          (_longitude != null && _longitude != 0.0)));

  /// Returns full address or reference if it
  /// exists, otherwise it returns null.
  String get address {
    if (_address.isEmpty) return null;
    if (!found)
      return (_address + ", " + _country)
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    return _address;
  }

  /// Returns latitude if
  /// it exists, otherwise it returns null.
  double get latitude {
    if (found) return _latitude;
    return 0.0;
  }

  /// Returns longitude if
  /// it exists, otherwise it returns null.
  double get longitude {
    if (found) return _longitude;
    return 0.0;
  }

  /// Returns a [String] with all variables values of the object.
  @override
  String toString() => "addr: $address, lat: $latitude, lng: $longitude";
}
