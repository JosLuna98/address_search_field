# Address Search Field

An address search field which helps to autocomplete an address by a reference. It can be used to get Directions beetwen two points.
It uses [HTTP](https://pub.dev/packages/http/versions/0.12.2), [Google Maps for Flutter](https://pub.dev/packages/google_maps_flutter/versions/1.0.5) plugins. (This last plugin is to use compatible objects that can be converted). [FlutterToast](https://pub.dev/packages/fluttertoast) plugin is used to improve the frontend.

![](https://raw.githubusercontent.com/JosLuna98/address_search_field/master/screenshot/untitled.gif)

## Getting Started

To use this plugin, add `address_search_field` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  address_search_field: ^2.1.0
```

## Permissions

### Android

On Android you'll need to add the internet permission to your Android Manifest file (located under android/app/src/main). To do so add next lines as direct child of the `<manifest>` tag:

``` xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Usage

Import the package:
```dart
import 'package:address_search_field/address_search_field.dart';
```

## GeoMethods

```dart
GeoMethods(
  googleApiKey: String,
  language: String,
  countryCode: String,
  country: String,
  city: String,
  mode: String,
);
```

* This object make calls to Google APIs using the parameters set. It can do requests to Google places, geocode and directions APIs.
* Language support list [here](https://developers.google.com/maps/faq#languagesupport).
* List of countries [here](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).

## AddressDialog

```dart
AddressDialog(
  controller: TextEditingController(),
  color: Color,
  backgroundColor: Color,
  hintText: String,
  noResultText: String,
  cancelText: String,
  continueText: String,
  useButtons: bool,
  onDone: FutureOr<bool> Function(Address addressPoint),
  geoMethods: GeoMethods
);
```

* This widget is a `Dialog` box to search a place or address in an autocompleted results list.
* onDone `Function` let you work with the resulted `Address` from the search. When it returns `true` the `Dialog` does `pop()`.
* It has a result object that helps this widget to work in a `RouteSearchBox`.

## AddressField

```dart
AddressField(
  controller: TextEditingController(),
  /// ... more variables of `TextFormField`
  barrierDismissible: bool,
  addressDialog: AddressDialogBuilder,
  geoMethods: GeoMethods,
);
```

* This widget is a `TextFormField` that `onTap` shows a `AddressDialog`.
* It uses an `AddressDialogBuilder` object to build an `AddressDialog` sharing variables like controller and geoMethods.

## RouteSearchBox

```dart
RouteSearchBox(
  geoMethods: GeoMethods,
  originBldr: AddressFieldBuilder,
  destinationBldr: AddressFieldBuilder,
  widgetBuilder: Widget Function(
    BuildContext context,
    AddressField originField,
    AddressField destinationField,
    Future<Directions> Function(List<Address> waypoints) getDirections,
  ),
);
```

* This widget use a custom `WidgetBuilder` with two `AddressField` to call Google Directions API and get `Directions` beetwen two or more points.
* It uses an `AddressFieldBuilder` object to build an `AddressField` sharing variables like controller and geoMethods.
* In its constructor it edits the `AddressFieldBuilder` to use the `result` variable connecting directly these two widgets.
* The `widgetBuilder` lets you build a widget using two `AddressField` to get two `Address` objects and be able to call Google Directions API by `getDirections` to finally get a `Directions` object.

##  License

MIT License
