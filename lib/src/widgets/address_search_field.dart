import 'package:flutter/material.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:address_search_field/src/widgets/address_search_dialog.dart';

/// Helps to create an [AddressSearchField].
class AddressFieldCtor {
  /// decoration for [TextField] in [AddressSearchField].
  InputDecoration decoration;

  /// style for [TextField] in [AddressSearchField].
  TextStyle style;

  /// `bool` for [AddressSearchField].
  bool barrierDismissible;

  /// constructor of the [AddressSearchDialog].
  AddressDialogCtor addressDialog;

  /// Constructor for [AddressFieldCtor].
  AddressFieldCtor({
    this.decoration = const InputDecoration(),
    this.style,
    this.barrierDismissible = true,
    @required this.addressDialog,
  });
}

/// [TextField] that `onTap` shows a [AddressSearchDialog].
class AddressSearchField extends StatelessWidget {
  /// Controller for [TextField] in the widget and [AddressSearchDialog].
  final TextEditingController controller;

  /// [Decoration] for [TextField].
  final InputDecoration decoration;

  /// Style for text in [TextField].
  final TextStyle style;

  /// Sets if the [AddressSearchDialog] will dismiss at touch outside.
  final bool barrierDismissible;

  /// Constructor for [AddressSearchDialog].
  final AddressDialogCtor addressDialog;

  /// [GeoMethods] instance to use Google APIs.
  final GeoMethods geoMethods;

  /// Constructor for [AddressSearchField].
  AddressSearchField({
    TextEditingController controller,
    this.decoration = const InputDecoration(),
    this.style,
    this.barrierDismissible = true,
    @required this.addressDialog,
    @required this.geoMethods,
  }) : this.controller = controller ?? TextEditingController();

  /// Constructor for [AddressSearchField] by [AddressFieldCtor].
  factory AddressSearchField.ctor({
    @required AddressFieldCtor constructor,
    TextEditingController controller,
    @required GeoMethods geoMethods,
  }) {
    return AddressSearchField(
      controller: controller,
      decoration: constructor.decoration,
      style: constructor.style,
      barrierDismissible: (constructor.barrierDismissible != null)
          ? constructor.barrierDismissible
          : true,
      addressDialog: constructor.addressDialog,
      geoMethods: geoMethods,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: controller,
      decoration: decoration,
      style: style,
      textCapitalization: TextCapitalization.words,
      onTap: () => showDialog(
        barrierDismissible: barrierDismissible,
        useSafeArea: true,
        context: context,
        builder: (BuildContext dialogContext) => AddressSearchDialog.ctor(
          constructor: addressDialog,
          controller: controller,
          geoMethods: geoMethods,
        ),
      ),
    );
  }
}
