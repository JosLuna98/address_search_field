library address_search_text_field;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

/// Check gps service and ask for permissions.
void _initService() async {
  final Location _locationService = Location();

  bool serviceEnabled = await _locationService.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await _locationService.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  PermissionStatus permissionGranted = await _locationService.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await _locationService.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
}

/// Describes the configuration for a [Widget].
///
/// Creates a [TextField] wich [onTap] shows
/// a custom [AlertDialog] with a search bar and a
/// list with results called [AddressSearchBox].
class AddressSearchTextField {
  static final TextEditingController _controller = TextEditingController();

  /// Constructor to run location service.
  AddressSearchTextField() {
    _initService();
  }

  /// creates and returns a [TextField] which calls
  /// an [AddressSearchBox] widget.
  ///
  /// The controller for [TextField] may be null because
  /// it would initialize with an internal [TextEditingController].
  static Widget widget({
    @required BuildContext context,
    TextEditingController controller,
    InputDecoration decoration = const InputDecoration(),
    TextStyle style = const TextStyle(),
    @required String country,
    List<String> exceptions = const [],
    bool coordForRef = false,
    @required void Function(AddressPoint value) onDone,
  }) {
    assert(country.isNotEmpty, "Country can't be empty");
    return TextField(
      readOnly: true,
      controller: controller ?? _controller,
      decoration: decoration,
      style: style,
      textCapitalization: TextCapitalization.words,
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext _context) => AddressSearchBox(
          controller: controller ?? _controller,
          country: country,
          exceptions: exceptions,
          coordForRef: coordForRef,
          onDone: onDone,
        ),
      ),
    );
  }
}

/// Widget based in an [AlertDialog] with a search bar and list of results,
/// all in one box.
class AddressSearchBox extends StatefulWidget {
  /// Manages text in the address search bar.
  final TextEditingController controller;

  /// Country to look for an address.
  final String country;

  /// Resulting addresses to be ignored.
  final List<String> exceptions;

  /// If it finds coordinates, they will be set to the reference.
  final bool coordForRef;

  /// Callback to run when search ends.
  final void Function(AddressPoint value) onDone;

  /// Constructs an [AddressSearchBox] widget from a concrete [country].
  AddressSearchBox({
    TextEditingController controller,
    @required this.country,
    this.exceptions = const <String>[],
    this.coordForRef = false,
    @required this.onDone,
  })  : assert(country.isNotEmpty, "Country can't be empty"),
        this.controller = controller ?? TextEditingController();

  @override
  _AddressSearchBoxState createState() => _AddressSearchBoxState(
      controller, country, exceptions, coordForRef, onDone);
}

/// State of [AddressSearchBox].
class _AddressSearchBoxState extends State<AddressSearchBox> {
  final TextEditingController controller;
  final String country;
  final List<String> exceptions;
  final bool coordForRef;
  final void Function(AddressPoint value) onDone;
  final AddressPoint _addressPoint = AddressPoint._();
  final List<String> _places = List();
  Size _size = Size(0.0, 0.0);
  bool _loading;
  bool _waiting;

  /// Creates the state of an [AddressSearchBox] widget.
  _AddressSearchBoxState(this.controller, this.country, this.exceptions,
      this.coordForRef, this.onDone) {
    _initService();
  }

  @override
  void initState() {
    super.initState();
    _addressPoint._country = country;
    _loading = false;
    _waiting = false;
    controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      content: _waiting
          ? _loadingIndicator
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _addressSearchBar,
                _addressSearchResult,
              ],
            ),
    );
  }

  /// Returns the address search bar widget to write an address reference.
  Widget get _addressSearchBar => Container(
        height: 60.0,
        width: _size.width * 0.80,
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 12.0,
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: _size.width * 0.63,
              child: TextField(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                    prefix: Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 8.0),
                      child: Icon(Icons.search),
                    ),
                    hintText: "Dirección"),
              ),
            ),
            GestureDetector(
              child: Icon(Icons.send),
              onTap: () async {
                _addressPoint._address = controller.text;
                if (_places.isNotEmpty && coordForRef)
                  _addressPoint._address += ", " + country;
                controller.text = _addressPoint.address;
                _asyncFunct();
              },
            ),
          ],
        ),
      );

  /// Returns a [Widget] depending on the state of the search
  /// process and its result.
  ///
  /// Returns [CircularProgressIndicator] while it's searching the address.
  /// Returns [Text] with `No hay resultados...` message if search failed.
  /// Returns [ListView] if search found places.
  Widget get _addressSearchResult => Container(
        height: _size.height * 0.28,
        width: _size.width * 0.80,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          ),
        ),
        child: Center(
          child: _loading
              ? CircularProgressIndicator()
              : ((_places.isNotEmpty)
                  ? ListView.separated(
                      padding: EdgeInsets.all(10.0),
                      itemCount: _places.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          (index != _places.length - 1)
                              ? Divider()
                              : Container(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          child: ListTile(
                            title: Text(_places[index]),
                            trailing: Icon(Icons.send),
                          ),
                          onTap: () {
                            controller.text = _places[index];
                            _addressPoint._address = controller.text;
                            _asyncFunct();
                          },
                        );
                      },
                    )
                  : Text(
                      "No hay resultado...",
                      style: TextStyle(color: Colors.grey.shade500),
                    )),
        ),
      );

  /// Returns a [CircularProgressIndicator] while [onDone] function is processing.
  Widget get _loadingIndicator => Container(
        height: _size.height * 0.28 + 60.0,
        width: _size.width * 0.80,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  /// [Listener] for widget's [TextEditingController] that will
  /// search for addresses by user's reference.
  ///
  /// The reference is used to get coordinates and find nearby places.
  void _listener() async {
    if (!_loading) {
      _places.clear();
      try {
        setState(() => _loading = true);
      } catch (_) {
        _loading = true;
      }
      try {
        List<Placemark> placeMarks;
        if (controller.text.isNotEmpty) {
          placeMarks = await Geolocator()
              .placemarkFromAddress(controller.text + ", Esmeraldas, Ecuador");
        }
        if (placeMarks.isNotEmpty) {
          _addressPoint._latitude = placeMarks[0].position.latitude;
          _addressPoint._longitude = placeMarks[0].position.longitude;
        }
      } on NoSuchMethodError catch (_) {} on PlatformException catch (_) {} catch (_) {
        debugPrint("ERROR CATCHED: " + _.toString());
      }
      try {
        Coordinates coordinates =
            Coordinates(_addressPoint._latitude, _addressPoint._longitude);
        List<Address> addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        addresses.asMap().forEach((index, value) {
          String place = value.addressLine;
          // Checks if place is not duplicated, if it's a country place and if it's not into exceptions
          if (!_places.contains(place) &&
              place.endsWith(country) &&
              !exceptions.contains(place)) _places.add(place);
        });
      } on NoSuchMethodError catch (_) {} on PlatformException catch (_) {} catch (_) {
        debugPrint("ERROR CATCHED: " + _.toString());
      }
      try {
        setState(() => _loading = false);
      } catch (_) {
        _loading = false;
      }
    }
  }

  /// If the user runs an asynchronous process in [onDone] function
  /// it will display an [CircularProgressIndicator] (changing [_waiting]
  /// vairable) in the [AddressSearchBox] until the process ends.
  void _asyncFunct() async {
    setState(() {
      _waiting = true;
    });
    await Future.delayed(
      Duration(),
      () => onDone(_addressPoint),
    );
    try {
      setState(() => _waiting = false);
    } catch (_) {
      _waiting = false;
    }
  }
}

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
    _initService();
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
    return null;
  }

  /// Returns longitude if
  /// it exists, otherwise it returns null.
  double get longitude {
    if (found) return _longitude;
    return null;
  }

  /// Returns a [String] to read variables values of the object.
  @override
  String toString() => "addr: $address, lat: $latitude, lng: $longitude";
}
