library address_search_text_field;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

/// Describes the configuration for a [Widget].
/// 
/// Creates a custom [TextField] wich [onTap()] shows 
/// a custom [AlertDialog] with a search bar and a
/// list with results.
class AddressSearchTextField {
  static final TextEditingController _controller = TextEditingController();
  static final Location _locationService = Location();

  /// Constructor to run location service.
  AddressSearchTextField() {
    _initService();
  }

  /// creates and returns a [TextField].
  static Widget widget({
    @required BuildContext context,
    InputDecoration decoration = const InputDecoration(),
    TextStyle style = const TextStyle(),
    @required String country,
    List<String> exceptions = const [],
    @required void Function(AddressPoint value) onDone,
  }) {
    return TextField(
      readOnly: true,
      controller: _controller,
      decoration: decoration,
      style: style,
      textCapitalization: TextCapitalization.words,
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext _context) =>
            _AddressSearch(_controller, country, exceptions, onDone),
      ),
    );
  }

  /// Initialize gps service and ask for permissions.
  static void _initService() async {
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
}

/// Widget based in an [AlertDialog] with a search bar and list of results.
class _AddressSearch extends StatefulWidget {
  final TextEditingController controller;
  final String country;
  final List<String> exceptions;
  final void Function(AddressPoint value) onDone;

  /// Constructs the [StatefulWidget] from a concrete [country].
  _AddressSearch(this.controller, this.country, this.exceptions, this.onDone);

  @override
  __AddressSearchState createState() =>
      __AddressSearchState(controller, country, exceptions, onDone);
}

/// State of [_AddressSearch].
class __AddressSearchState extends State<_AddressSearch> {
  final TextEditingController controller;
  final String country;
  final List<String> exceptions;
  final void Function(AddressPoint value) onDone;
  final AddressPoint _addressPoint = AddressPoint._();
  final List<String> _places = List();
  bool _loading;
  
  /// Creates an [_AddressSearch] widget.
  __AddressSearchState(
      this.controller, this.country, this.exceptions, this.onDone);

  @override
  void initState() {
    super.initState();
    _addressPoint._country = country;
    _loading = false;
    controller.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 60.0,
            width: size.width * 0.80,
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
                  width: size.width * 0.63,
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
                  onTap: () {
                    _addressPoint._address = controller.text;
                    onDone(_addressPoint);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Container(
            height: size.height * 0.28,
            width: size.width * 0.80,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Center(
              child: _list(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a [Widget] depending on the state of the search
  /// process and its result.
  ///
  /// Returns [CircularProgressIndicator] while it's searching the address.
  /// Returns [Text] with `No hay resultados...` message if search failed.
  /// Returns [ListView] if search found places.
  Widget _list(BuildContext context) {
    if (_loading)
      return CircularProgressIndicator();
    else {
      if (_places.isNotEmpty)
        return ListView.separated(
          padding: EdgeInsets.all(10.0),
          itemCount: _places.length,
          separatorBuilder: (BuildContext context, int index) =>
              (index != _places.length - 1) ? Divider() : Container(),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: ListTile(
                title: Text(_places[index]),
                trailing: Icon(Icons.send),
              ),
              onTap: () {
                controller.text = _places[index];
                _addressPoint._address = controller.text;
                onDone(_addressPoint);
                Navigator.of(context).pop();
              },
            );
          },
        );
      else
        return Text(
          "No hay resultado...",
          style: TextStyle(color: Colors.grey.shade500),
        );
    }
  }

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
}

/// An object to control the results from [AddressSearchTextField] class.
///
/// Saves info about a found place in a concrete [country].
class AddressPoint {
  String _address;
  double _latitude;
  double _longitude;
  String _country;

  /// Constructs an [AddressPoint] object to save and use the [AddressSearchTextfield] result.
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

  /// Returns a [String] with country name given in the constructor.
  String get country => _country;

  /// Returns a [bool] to know if object has a found [address].
  bool get found => (_address.toLowerCase().endsWith(_country.toLowerCase()) &&
      ((_latitude != null && _latitude != 0.0) &&
          (_longitude != null && _longitude != 0.0)));

  /// Returns a [String] with full address or reference if it 
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

  /// Returns a [double] with point's latitude if
  /// it exists, otherwise it returns null.
  double get latitude {
    if (found) return _latitude;
    return null;
  }

  /// Returns a [double] with point's longitude if
  /// it exists, otherwise it returns null.
  double get longitude {
    if (found) return _longitude;
    return null;
  }

  /// Returns a [String] to read variables values of the object.
  @override
  String toString() => "addr: $address, lat: $latitude, lng: $longitude";
}
