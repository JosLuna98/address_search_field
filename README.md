# Address Search Field
Widget builders to create 'address search widgets' which helps to autocomplete an address using a reference. They can be used to get Directions beetwen two places with optional waypoints. These widgets are made to be showed by `onTap` in a `TextField` with the `showDialog` function.
It uses [HTTP](https://pub.dev/packages/http/versions/0.12.2), [Google Maps for Flutter](https://pub.dev/packages/google_maps_flutter/versions/1.0.5) plugins. (This last plugin is to use extended objects that can be usable with `GoogleMap` Widget).
![](https://raw.githubusercontent.com/JosLuna98/address_search_field/master/screenshot/address_search_field.gif)
## Getting Started
To use this plugin, add `address_search_field` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:
```yaml
dependencies:
  address_search_field: ^3.1.0
```
## Permissions
### Android
On Android you'll need to add the internet permission to your Android Manifest file (located under android/app/src/main). To do so add next lines as direct child of the `manifest>` tag:
``` xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
### iOS
On iOS you'll need to add the `NSLocationWhenInUseUsageDescription` to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following:
``` xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Permission to get your location</string>
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
* This object makes calls to Google APIs using the parameters set. It can do requests to Google places, geocode and directions APIs [Get API key](https://developers.google.com/maps/documentation/embed/get-api-key).
* Language support list [here](https://developers.google.com/maps/faq#languagesupport).
* List of countries [here](https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes).

Example:
```dart
final geoMethods = GeoMethods(
  googleApiKey: 'GOOGLE_API_KEY',
  language: 'en',
  countryCode: 'us',
  countryCodes: ['us', 'es', 'co'],
  country: 'United States',
  city: 'New York',
);
    
geoMethods.autocompletePlace(query: 'place streets or reference'); // It will search in unite states, espain and colombia. It just can filter up to 5 countries.
geoMethods.geoLocatePlace(coords: Coords(0.10, 0.10));
geoMethods.getPlaceGeometry(reference: 'place streets', placeId: 'ajFDN3662fNsa4hhs42FAjeb5n');
geoMethods.getDirections(origin: Address(coords: Coords(0.10, 0.10)), destination: Address(coords: Coords(0.10, 0.10))); // It needs a specific region, it will search in unite states.
```
## AddressSearchBuilder
This widget is a builder which provides of parameters and methods to create a widget that can search addresses and permits to work with them using an `Address` object.

Example:
```dart
GeoMethods geoMethods;
TextEditingController controller;

AddressSearchBuilder.deft(
  geoMethods: geoMethods,
  controller: controller,
  builder: AddressDialogBuilder(),
  onDone: (Address address) => null,
);
```
>`AddressSearchDialog.deft` creates the widget showed on post's top. If you don't add `.deft` at end you can create your own widget to work with the addresses information.

Example:
```dart
GeoMethods geoMethods;
TextEditingController controller;

AddressSearchBuilder(
  geoMethods: geoMethods,
  controller: controller,
  builder: (
    BuildContext context,
    AsyncSnapshot<List<Address>> snapshot, {
    TextEditingController controller,
    Future<void> Function() searchAddress,
    Future<Address> Function(Address address) getGeometry,
  }) {
    return MyCustomWidget(
      snapshot: snapshot,
      controller: controller,
      searchAddress: searchAddress,
      getGeometry: getGeometry,
      onDone: (Address address) => null,
    );
  },
);
```
## AddressDialogBuilder
This builder uses parameters to customize an `AddressSearchDialog` which is called from `AddressSearchBuilder`.

Example:
```dart
AddressDialogBuilder(
  color: Color,
  backgroundColor: Color,
  hintText: String,
  noResultText: String,
  cancelText: String,
  continueText: String,
  useButtons: bool,
);
```
## AddressLocator
This widget is a simple way to set an initial address reference in a `TextEditingController` when the `AddressSearchBuilder` is not created by a `RouteSearchBox`. `locator` param provides a `relocate` function to do it and get an `Address`.

Example:
```dart
GeoMethods geoMethods;
TextEditingController controller;
Coords initialCoords;
Address initialAddress;

AddressLocator(
  geoMethods: geoMethods,
  controller: controller,
  locator: (relocate) async {
    if(controller.text.isEmpty) 
      initialAddress.update(await relocate(initialCoords)) // by initial coordinates you can get an address reference to be predefined in the widget and save all the address data in a variable.
  },
  child: TextField(
    onTap: () => AddressSearchBuilder.deft(
      geoMethods: geoMethods,
      controller: controller,
      builder: AddressDialogBuilder(),
      onDone: (Address address) {},
    ),
  ),
);
```
## RouteSearchBox
This is a special widget with a builder which provides of three `AddressSearchBuilder` to search an origin `Address`, destination `Address` and optionally waypoints in a `List<Address>`. This widget is used to get directions from the points got by the builder's `AddressSearchBuilder`s. `relocate` function permits to set an initial position as origin or destination from an initial coordinates parameter.
A completed example of how to use this widget could be found [here](https://pub.dev/packages/address_search_field/example).

Example:
```dart
GeoMethods geoMethods;
TextEditingController originCtrl;
TextEditingController destCtrl;
Coords initialCoords;

RouteSearchBox(
  geoMethods: geoMethods,
  originCtrl: originCtrl,
  destinationCtrl: destCtrl,
  builder: (
    BuildContext context,
    AddressSearchBuilder originBuilder,
    AddressSearchBuilder destinationBuilder, {
    Future<Directions> Function() getDirections,
    void Function(AddressId addrId, Coords coords) relocate,
    AddressSearchBuilder waypointBuilder,
    WaypointsManager waypointsMgr,
  }) {
    if(originCtrl.text.isEmpty) relocate(AddressId.origin, initialCoords);
    return Column(
      children: [
        TextField(
          controller: originCtrl,
          onTap: () => showDialog(
            context: context,
            builder:
                (context) => 
                    originBuilder.buildDefault(
              builder: AddressDialogBuilder(),
              onDone: (Address address) => null,
            ),
          ),
        ),
        TextField(
          controller: destCtrl,
          onTap: () => showDialog(
            context: context,
            builder:
                (context) => 
                    destinationBuilder.buildDefault(
              builder: AddressDialogBuilder(),
              onDone: (Address address) => null,
            ),
          ),
        ),
      ],
    );
  },
);
```
##  License
MIT License

## Contact
You can contact me if you have problems or ideas. Hablo español e inglés.

josluna1098@gmail.com