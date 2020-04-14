part of '../../address_search_text_field.dart';

/// Widget based in an [AlertDialog] with a search bar and list of results,
/// all in one box.
class AddressSearchBox extends StatefulWidget {
  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController controller;

  /// Country to look for an address.
  final String country;

  /// Resulting addresses to be ignored.
  final List<String> exceptions;

  /// If it finds coordinates, they will be set to the reference.
  final bool coordForRef;

  /// Callback to run when search ends.
  final void Function(AddressPoint point) onDone;

  /// Constructs an [AddressSearchBox] widget from a concrete [country].
  AddressSearchBox({
    TextEditingController controller,
    @required this.country,
    this.exceptions = const <String>[],
    this.coordForRef = false,
    this.onDone,
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
  final FutureOr<void> Function(AddressPoint value) onDone;
  final AddressPoint _addressPoint = AddressPoint._();
  final List<String> _places = List();
  Size _size = Size(0.0, 0.0);
  bool _loading;
  bool _waiting;
  bool _searched;

  /// Creates the state of an [AddressSearchBox] widget.
  _AddressSearchBoxState(this.controller, this.country, this.exceptions,
      this.coordForRef, this.onDone) {
    LocationService.init();
  }

  @override
  void initState() {
    super.initState();
    _addressPoint._country = country;
    _loading = false;
    _waiting = false;
    _searched = false;
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return SimpleDialog(
      contentPadding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      children: <Widget>[
        _waiting
            ? _loadingIndicator
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _addressSearchBar,
                    _addressSearchResult,
                  ],
                ),
              ),
      ],
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
              color: Colors.black12,
              blurRadius: 12.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 10.0),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: _size.width * 0.80 - 70.0,
              child: TextField(
                onEditingComplete: () async {
                  await _searchAddress();
                  setState(() => _searched = true);
                },
                onChanged: (_) =>
                    (_searched) ? setState(() => _searched = false) : null,
                controller: controller,
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                    prefix: Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 8.0),
                      child: Icon(Icons.location_city),
                    ),
                    hintText: "Dirección"),
              ),
            ),
            GestureDetector(
              child: Icon((!_searched) ? Icons.search : Icons.send),
              onTap: (!_searched)
                  ? () async {
                      await _searchAddress();
                      setState(() => _searched = true);
                    }
                  : () async {
                      _addressPoint._address = controller.text;
                      if (_places.isNotEmpty && coordForRef) {
                        _addressPoint._address += ", " + country;
                        controller.text = _addressPoint.address;
                      }
                      await _asyncFunct(notFound: true && !coordForRef);
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
                          onTap: () async {
                            controller.text = _places[index];
                            _addressPoint._address = controller.text;
                            await _asyncFunct();
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
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  /// It uses the user's reference to search for nearby addresses
  /// and places to obtain coordinates.
  Future<void> _searchAddress() async {
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

  /// If the user runs an asynchronous process in [onDone] function
  /// it will display an [CircularProgressIndicator] (changing [_waiting]
  /// vairable) in the [AddressSearchBox] until the process ends.
  FutureOr<void> _asyncFunct({bool notFound = false}) async {
    setState(() {
      _waiting = true;
    });
    if (notFound) {
      _addressPoint._latitude = 0.0;
      _addressPoint._longitude = 0.0;
    }
    if (onDone != null) await onDone(_addressPoint);
    try {
      setState(() {
        _waiting = false;
      });
    } catch (_) {
      _waiting = false;
    } finally {
      _searched = false;
      _places.clear();
    }
  }
}
