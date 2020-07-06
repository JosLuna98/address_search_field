# Address Search Field

A text field that displays an address search box to find a location by typing a reference and gets nearby addresses. Selecting the desired address returns an object with the latitude, longitude, and full address of the place.
It uses [location](https://pub.dev/packages/location), [geolocator](https://pub.dev/packages/geolocator), [geocoder](https://pub.dev/packages/geocoder) plugins.

![](https://raw.githubusercontent.com/JosLuna98/address_search_field/master/screenshot/untitled.gif)

**NOTE:** This package was made with Flutter 1.17 and Dart 2.8, make sure you have your environment within the version range.
```yaml
environment:
  sdk: ">=2.7.0 <3.0.0"
  flutter: ">=1.10.0"
```

## Getting Started

To use this plugin, add `address_search_field` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  address_search_field: ^1.4.2
```

## Permissions

### Android

On Android you'll need to add either the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission to your Android Manifest file (located under android/app/src/main). To do so add one of the following two lines as direct children of the `<manifest>` tag:

``` xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
Also you have to add internet permission
``` xml
<uses-permission android:name="android.permission.INTERNET"/>
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

* This widget is a search box to write a reference about a place and find an address.

```dart
AddressSearchBox(
  controller: TextEditingController(),
  country: String,
  city: String,
  hintText: String,
  noResultText: String,
  exceptions: <String>[],
  coordForRef: bool,
  onDone: (BuildContext dialogContext, AddressPoint point) {},
  onCleaned: () {},
);
```

| Parameters | Type | Description |
|------------|------|-------------|
| controller | Optional | The controller allows you to interact with the text in the field. |
| country | Required, Not Null | You have to set in which country to search. |
| city | Optional | You may set in which city to search. |
| hintText | Required, Not Null | Text suggestion according to your language in the search box. |
| noResultsText | Required, Not Null | Message according to your language when the search box doesn't find anything. |
| exceptions | Optional| Results you don't want to show. |
| coordForRef | Optional | It's false by default. With the value true, it will use what the user typed in the search box as a valid Address. |
| onDone | Optional | When the search stops, it gives you an AddressPoint object with confirmation if a place has been found, full address, and coordinates. |
| onCleaned | Optional | When the search box is closed with an empty text field, this function is executed. |

* This widget is a `TextField` that displays a` AddressSearchBox` by tapping it. It has 3 more parameters to personalize the `TextField`.

```dart
AddressSearchField(
  controller: TextEditingController(),
  decoration: InputDecoration(),
  style: TextStyle(),
  barrierDismissible: bool,
  country: String,
  city: String,
  hintText: String,
  noResultsText: String,
  exceptions: <String>[],
  coordForRef: bool,
  onDone: (BuildContext dialogContext, AddressPoint point) {},
  onCleaned: () {},
);
```

| Parameters | Type | Description |
|------------|------|-------------|
| decoration | Optional | The decoration to show around the text field. |
| style | Optional | The style to use for the text being edited. |
| barrierDismissible | Optional | It's true by default. With the value false, it won't close the search box when you tap outside it. |

* When the address search is complete, you can get an `AddressPoint` object that provides the following values:

```dart
onDone: (BuildContext dialogContext, AddressPoint point) {
  bool found = point.found;
  String address = point.address;
  String country = point.country;
  double latitude = point.latitude;
  double longitude = point.longitude;
  Navigator.of(dialogContext).pop(); // Use it JUST in a AddressSearchField widget to close the dialog.
}
```

There are three possible outcomes:
1. If no search has been performed then the object will have null values ​​in its address, latitude and longitude variables.
2. If a place has been found from the reference, all the variables will be initialized.
3. If the desired location has not been found and the reference entered by the user is selected, there will be no latitude and longitude values ​​and the address will be the user's reference since nothing was found.

**NOTE:** You can also find an address by it's coordinates using `await AddressPoint.fromPoint(latitude, longitude)`. If the address is not found, it will return `null`.

```dart
() async {
  AddressPoint point = await AddressPoint.fromPoint(latitude, longitude);
  if (point != null) print(point.address);
}
```

* This plugin also has an async static function called **initLocationService** to verify and request location permissions. You can use optional callbacks when location service is not enabled or if permission is not granted.

```dart
() async => await initLocationService(
  noServiceEnabled: () {},
  noPermissionGranted: () {},
);
```

##  License

MIT License
