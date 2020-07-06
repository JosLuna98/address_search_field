/// An address search box that gets nearby addresses by typing a reference,
/// returns an object with place primary data. The object can also find an
/// address using coordinates.
library address_search_field;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

part 'src/models/address_point.dart';
part 'src/services/location_service.dart';
part 'src/widgets/address_search_box.dart';

/// A [TextField] wich `onTap` shows
/// a custom [AlertDialog] with a search bar and a
/// list with results called [AddressSearchBox].
class AddressSearchField extends StatelessWidget {
  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController controller;

  /// The decoration to show around the text field.
  ///
  /// By default, draws a horizontal line under the text field but can be
  /// configured to show an icon, label, hint text, and error text.
  ///
  /// Specify null to remove the decoration entirely (including the
  /// extra padding introduced by the decoration to save space for the labels).
  final InputDecoration decoration;

  /// The style to use for the text being edited.
  ///
  /// This text style is also used as the base style for the [decoration].
  ///
  /// If null, defaults to the `subtitle1` text style from the current [Theme].
  final TextStyle style;

  /// Tapping outside the box dismiss the widget. default true.
  final bool barrierDismissible;

  /// Country where look for an address.
  final String country;

  /// City where look for an address.
  final String city;

  /// Hint text for [AddressSearchBox].
  final String hintText;

  /// Message when there are no results in [AddressSearchBox].
  final String noResultsText;

  /// Resulting addresses to be ignored.
  final List<String> exceptions;

  /// If it finds coordinates, they will be set to the reference.
  final bool coordForRef;

  /// Callback to run when search ends.
  final FutureOr<void> Function(BuildContext dialogContext, AddressPoint point)
      onDone;

  /// Callback to run if the user no sends data.
  final FutureOr<void> Function() onCleaned;

  /// Creates a [TextField] wich `onTap` shows
  /// a custom [AlertDialog] with a search bar and a
  /// list with results called [AddressSearchBox].
  AddressSearchField({
    TextEditingController controller,
    this.decoration = const InputDecoration(),
    this.style = const TextStyle(),
    this.barrierDismissible = true,
    @required this.country,
    this.city = "",
    @required this.hintText,
    @required this.noResultsText,
    this.exceptions = const <String>[],
    this.coordForRef = false,
    this.onDone,
    this.onCleaned,
  })  : assert(country.isNotEmpty, "Country can't be empty"),
        assert(country != null),
        assert(hintText != null),
        assert(noResultsText != null),
        this.controller = controller ?? TextEditingController() {
    initLocationService();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: this.controller,
      decoration: this.decoration,
      style: this.style,
      textCapitalization: TextCapitalization.words,
      onTap: () => showDialog(
        barrierDismissible: this.barrierDismissible,
        context: context,
        builder: (BuildContext context) => AddressSearchBox(
          controller: this.controller,
          country: this.country,
          city: this.city,
          hintText: this.hintText,
          noResultsText: this.noResultsText,
          exceptions: this.exceptions,
          coordForRef: this.coordForRef,
          onDone: this.onDone,
          onCleaned: this.onCleaned,
        ),
      ),
    );
  }
}
