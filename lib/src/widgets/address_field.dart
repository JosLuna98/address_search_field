import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:address_search_field/src/services/geo_methods.dart';
import 'package:address_search_field/src/widgets/address_dialog.dart';

/// Builder for [AddressField].
class AddressFieldBuilder {
  /// Variable for [AddressField].
  bool barrierDismissible;

  /// Variable for [AddressField].
  AddressDialogBuilder addressDialog;

  /// Variable for [AddressField].
  TextEditingController controller;

  /// Variable for [AddressField].
  String initialValue;

  /// Variable for [AddressField].
  FocusNode focusNode;

  /// Variable for [AddressField].
  InputDecoration decoration;

  /// Variable for [AddressField].
  TextInputType keyboardType;

  /// Variable for [AddressField].
  TextCapitalization textCapitalization;

  /// Variable for [AddressField].
  TextInputAction textInputAction;

  /// Variable for [AddressField].
  TextStyle style;

  /// Variable for [AddressField].
  StrutStyle strutStyle;

  /// Variable for [AddressField].
  TextDirection textDirection;

  /// Variable for [AddressField].
  TextAlign textAlign;

  /// Variable for [AddressField].
  TextAlignVertical textAlignVertical;

  /// Variable for [AddressField].
  bool autofocus;

  /// Variable for [AddressField].
  ToolbarOptions toolbarOptions;

  /// Variable for [AddressField].
  bool showCursor;

  /// Variable for [AddressField].
  String obscuringCharacter;

  /// Variable for [AddressField].
  bool obscureText;

  /// Variable for [AddressField].
  bool autocorrect;

  /// Variable for [AddressField].
  SmartDashesType smartDashesType;

  /// Variable for [AddressField].
  SmartQuotesType smartQuotesType;

  /// Variable for [AddressField].
  bool enableSuggestions;

  /// Variable for [AddressField].
  bool maxLengthEnforced;

  /// Variable for [AddressField].
  int maxLines;

  /// Variable for [AddressField].
  int minLines;

  /// Variable for [AddressField].
  bool expands;

  /// Variable for [AddressField].
  int maxLength;

  /// Variable for [AddressField].
  ValueChanged<String> onChanged;

  /// Variable for [AddressField].
  VoidCallback onEditingComplete;

  /// Variable for [AddressField].
  ValueChanged<String> onFieldSubmitted;

  /// Variable for [AddressField].
  FormFieldSetter<String> onSaved;

  /// Variable for [AddressField].
  FormFieldValidator<String> validator;

  /// Variable for [AddressField].
  List<TextInputFormatter> inputFormatters;

  /// Variable for [AddressField].
  bool enabled;

  /// Variable for [AddressField].
  double cursorWidth;

  /// Variable for [AddressField].
  double cursorHeight;

  /// Variable for [AddressField].
  Radius cursorRadius;

  /// Variable for [AddressField].
  Color cursorColor;

  /// Variable for [AddressField].
  Brightness keyboardAppearance;

  /// Variable for [AddressField].
  EdgeInsets scrollPadding;

  /// Variable for [AddressField].
  bool enableInteractiveSelection;

  /// Variable for [AddressField].
  InputCounterWidgetBuilder buildCounter;

  /// Variable for [AddressField].
  ScrollPhysics scrollPhysics;

  /// Variable for [AddressField].
  Iterable<String> autofillHints;

  /// Variable for [AddressField].
  AutovalidateMode autovalidateMode;

  /// Constructor for [AddressFieldBuilder].
  AddressFieldBuilder({
    this.barrierDismissible = true,
    @required this.addressDialog,
    TextEditingController controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.toolbarOptions,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforced = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
  }) : this.controller = controller ?? TextEditingController();

  /// Build an [AddressField].
  AddressField build({
    @required GeoMethods geoMethods,
  }) {
    return AddressField(
      barrierDismissible: barrierDismissible,
      addressDialog: addressDialog,
      geoMethods: geoMethods,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforced: maxLengthEnforced,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// [TextFormField] that `onTap` shows a [AddressDialog].
class AddressField extends StatelessWidget {
  final bool barrierDismissible;
  final AddressDialogBuilder addressDialog;
  final GeoMethods geoMethods;
  final TextEditingController controller;
  final String initialValue;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final bool autofocus;
  final ToolbarOptions toolbarOptions;
  final bool showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
  final bool enableSuggestions;
  final bool maxLengthEnforced;
  final int maxLines;
  final int minLines;
  final bool expands;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onFieldSubmitted;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final List<TextInputFormatter> inputFormatters;
  final bool enabled;
  final double cursorWidth;
  final double cursorHeight;
  final Radius cursorRadius;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final InputCounterWidgetBuilder buildCounter;
  final ScrollPhysics scrollPhysics;
  final Iterable<String> autofillHints;
  final AutovalidateMode autovalidateMode;

  /// Constructor for [AddressField].
  AddressField({
    this.barrierDismissible = true,
    @required this.addressDialog,
    @required this.geoMethods,
    TextEditingController controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.toolbarOptions,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforced = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
  }) : this.controller = controller ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: decoration,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforced: maxLengthEnforced,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode,
      onTap: () => showDialog(
        barrierDismissible: barrierDismissible,
        useSafeArea: true,
        context: context,
        builder: (BuildContext dialogContext) => addressDialog.build(
          geoMethods: geoMethods,
          controller: controller,
        ),
      ),
    );
  }
}
