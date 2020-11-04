import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:address_search_field/src/widgets/route_search_box.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:address_search_field/src/models/address.dart';

/// Helps to create an [AddressSearchDialog].
class AddressDialogCtor {
  /// Color for [AddressSearchDialog].
  Color color;

  /// Background color for [AddressSearchDialog].
  Color backgroundColor;

  /// Hint text for [AddressSearchDialog].
  String hintText;

  /// No results text for [AddressSearchDialog].
  String noResultsText;

  /// Cancel text for [AddressSearchDialog].
  String cancelText;

  /// Continue text for [AddressSearchDialog].
  String continueText;

  /// Error text for [AddressSearchDialog].
  String errorText;

  /// `bool` for [AddressSearchDialog].
  bool useButtons;

  /// `Function` for [AddressSearchDialog].
  FutureOr<bool> Function(Address address) onDone;

  /// `Address` for [AddressSearchDialog].
  Address result;

  /// Constructor for [AddressDialogCtor].
  AddressDialogCtor({
    this.color,
    this.backgroundColor,
    this.hintText,
    this.noResultsText,
    this.cancelText,
    this.continueText,
    this.errorText,
    this.useButtons = true,
    @required this.onDone,
    this.result,
  });
}

/// Dialog box to search a place or address in an autocompleted results list.
class AddressSearchDialog extends StatefulWidget {
  /// Controller for [TextField] in the widget.
  final TextEditingController controller;

  /// Color for details in the widget.
  final Color color;

  /// Bakcground color for widget.
  final Color backgroundColor;

  /// Message to show when the [TextField] of the widget is empty.
  final String hintText;

  /// Message to show when the [ListView] of the widget is empty.
  final String noResultsText;

  /// Text for [RaisedButton] of the widget to cancel.
  final String cancelText;

  /// Text for [RaisedButton] of the widget to continue.
  final String continueText;

  /// Text for [Fluttertoast] when something goes wrong.
  final String errorText;

  /// Sets if the [AddressSearchDialog] will have buttons at bottom.
  final bool useButtons;

  /// Runs when an address is selected.
  final FutureOr<bool> Function(Address addressPoint) onDone;

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// Parameter to work with a [RouteSearchBox].
  final Address result;

  /// Constructor for [AddressSearchDialog].
  AddressSearchDialog({
    TextEditingController controller,
    this.color,
    this.backgroundColor,
    String hintText,
    String noResultsText,
    String cancelText,
    String continueText,
    String errorText,
    this.useButtons = true,
    @required this.onDone,
    @required this.geoMethods,
    this.result,
  })  : this.controller = controller ?? TextEditingController(),
        this.hintText = hintText ?? 'Address or reference',
        this.noResultsText = noResultsText ?? "There're no results",
        this.cancelText = cancelText ?? 'Cancel',
        this.continueText = continueText ?? 'Continue',
        this.errorText = errorText ?? 'Unexpected error' {
    if (!useButtons)
      assert(cancelText == null && continueText == null,
          "cancelText and continueText won't be visible when useButtons is false");
  }

  /// Constructor for [AddressSearchDialog] by [AddressDialogCtor].
  factory AddressSearchDialog.ctor({
    @required AddressDialogCtor constructor,
    TextEditingController controller,
    @required GeoMethods geoMethods,
  }) {
    return AddressSearchDialog(
      controller: controller,
      color: constructor.color,
      backgroundColor: constructor.backgroundColor,
      hintText: constructor.hintText,
      noResultsText: constructor.noResultsText,
      cancelText: constructor.cancelText,
      continueText: constructor.continueText,
      useButtons:
          (constructor.useButtons != null) ? constructor.useButtons : true,
      onDone: constructor.onDone,
      geoMethods: geoMethods,
      result: constructor.result,
    );
  }

  @override
  _AddressSearchDialogState createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  _AddressSearchDialogState()
      : this._isLoading = false,
        this._places = List<Address>();

  Size _size;
  bool _isLoading;
  final List<Address> _places;

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _searchBar,
            Divider(color: Colors.grey, height: 0.2),
            _resultsList,
            (widget.useButtons)
                ? Divider(color: Colors.grey, height: 0.2)
                : Container(),
            (widget.useButtons) ? _dialogButtons : Container(),
          ],
        ),
      ],
    );
  }

  Widget get _searchBar {
    return Container(
      height: 55.0,
      width: (_size.width * 0.8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: (_size.width * 0.8) * 0.03125), // 0.03125
            child: Icon(
              Icons.location_city,
              size: (_size.width * 0.8) * 0.0625,
            ),
          ),
          SizedBox(
            width: (_size.width * 0.8) * 0.72,
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              autocorrect: false,
              textCapitalization: TextCapitalization.words,
              cursorColor: widget.color ?? Theme.of(context).primaryColor,
              onEditingComplete: () async => await _searchAddress(),
              decoration: InputDecoration(
                suffix: GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 13.0,
                    ),
                  ),
                  onTap: _clearSearchBar,
                ),
                hintText: widget.hintText,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.color ?? Theme.of(context).primaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.color ?? Theme.of(context).primaryColor),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.color ?? Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(
                  right: (_size.width * 0.8) * 0.0425), // 0.03125
              child: Icon(
                Icons.search_rounded,
                color: widget.color ?? Theme.of(context).primaryColor,
                size: (_size.width * 0.8) * 0.0625,
              ),
            ),
            onTap: () async => await _searchAddress(),
          )
        ],
      ),
    );
  }

  Widget get _resultsList {
    return Container(
      height: _size.height * 0.35,
      width: _size.width * 0.80,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: (widget.useButtons)
            ? BorderRadius.all(Radius.zero)
            : BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
      ),
      child: Center(
        child: (_isLoading)
            ? CircularProgressIndicator()
            : ((_places.isNotEmpty)
                ? ListView.separated(
                    itemCount: _places.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        (index != _places.length - 1) ? Divider() : Container(),
                    itemBuilder: (BuildContext context, int index) => ListTile(
                      title: Text(_places[index].reference),
                      onTap: () async => (widget.onDone != null)
                          ? await _selected(_places[index])
                          : null,
                    ),
                  )
                : Text(widget.noResultsText,
                    style: TextStyle(color: Colors.grey.shade500))),
      ),
    );
  }

  Widget get _dialogButtons {
    return Container(
      height: 45,
      width: _size.width * 0.80,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: GestureDetector(
              child: Text(
                widget.cancelText,
                style: TextStyle(
                    color: widget.color ?? Theme.of(context).primaryColor),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: Text(
                widget.continueText,
                style: TextStyle(
                    color: widget.color ?? Theme.of(context).primaryColor),
              ),
              onTap: () async => (widget.onDone != null)
                  ? await _selected(Address(reference: widget.controller.text))
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAddress() async {
    try {
      setState(() => _isLoading = true);
      _places.clear();
      final List<Address> list = await widget.geoMethods
          .autocompletePlace(query: widget.controller.text);
      if (list == null) Fluttertoast.showToast(msg: widget.errorText);
      _places.addAll(list ?? <Address>[]);
      setState(() => _isLoading = false);
    } catch (e) {
      _isLoading = false;
    }
  }

  void _clearSearchBar() {
    try {
      widget.controller.clear();
      setState(() => _places.clear());
    } catch (e) {
      _places.clear();
    }
  }

  Future<void> _selected(Address address) async {
    if (address.hasReference && address.hasPlaceId) {
      Address add = await widget.geoMethods.getPlaceGeometry(
          reference: address.reference, placeId: address.placeId);
      if (add != null)
        address.update(add);
      else
        Fluttertoast.showToast(msg: widget.errorText);
    }
    if (await widget.onDone(address)) {
      widget.controller.text = address.reference;
      if (widget.result != null) widget.result.update(address);
      Navigator.of(context).pop();
    }
  }
}
