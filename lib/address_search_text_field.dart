library address_search_text_field;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

class SearchAddressTextField {
  static final TextEditingController _controller = TextEditingController();
  static final AddressPoint _addressPoint = AddressPoint._(_controller);
  static final Location _locationService = Location();
  static String _country;

  static Widget widget({
    @required BuildContext context,
    InputDecoration decoration = const InputDecoration(),
    @required String country,
    List<String> exceptions = const [],
  }) {
    _initService();
    _country = country;
    return TextField(
      readOnly: true,
      controller: _controller,
      decoration: decoration,
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext _context) =>
            _Content(_addressPoint, _controller, country, exceptions),
      ),
    );
  }

  AddressPoint get values => _addressPoint._values(_country);

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

class _Content extends StatefulWidget {
  final AddressPoint addressPoint;
  final TextEditingController controller;
  final String country;
  final List<String> exceptions;
  _Content(this.addressPoint, this.controller, this.country, this.exceptions);

  @override
  _ContentState createState() =>
      _ContentState(addressPoint, controller, country, exceptions);
}

class _ContentState extends State<_Content> {
  final AddressPoint addressPoint;
  final TextEditingController controller;
  final String country;
  final List<String> exceptions;
  _ContentState(
      this.addressPoint, this.controller, this.country, this.exceptions);

  final List<String> _places = List();
  bool _loading;

  @override
  void initState() {
    super.initState();
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
          addressPoint.latitude = placeMarks[0].position.latitude;
          addressPoint.longitude = placeMarks[0].position.longitude;
        }
      } on NoSuchMethodError catch (_) {} on PlatformException catch (_) {} catch (_) {
        debugPrint("ERROR CATCHED: " + _.toString());
      }
      try {
        Coordinates coordinates =
            Coordinates(addressPoint.latitude, addressPoint.longitude);
        List<Address> addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        addresses.asMap().forEach((index, value) {
          String place = value.addressLine;
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

class AddressPoint {
  TextEditingController _ctrl = TextEditingController();
  double latitude = 0.0;
  double longitude = 0.0;

  AddressPoint._(controller) : _ctrl = controller;

  AddressPoint(
      {@required this.latitude,
      @required this.longitude,
      @required String address})
      : _ctrl = TextEditingController.fromValue(
            TextEditingValue(text: address ?? ""));

  String get address => _ctrl.text;
  set address(String value) => _ctrl.text = value;

  AddressPoint _values(String country) {
    return AddressPoint(
      address: (_ctrl.text.isNotEmpty) ? _ctrl.text : null,
      latitude: (_ctrl.text.endsWith(country)) ? latitude : null,
      longitude: (_ctrl.text.endsWith(country)) ? longitude : null,
    );
  }

  @override
  String toString() =>
      "address: ${(_ctrl.text.isNotEmpty) ? _ctrl.text : null}, lat: ${(latitude != 0.0) ? latitude : null}, lng: ${(longitude != 0.0) ? longitude : null}";
}
