# Address Search Text Field

A text field that displays an address search bar that finds a location from a reference and gets nearby addresses. Selecting the desired address returns an object with the latitude, longitude, and full address of the place.
It uses [location](https://pub.dev/packages/location), [geolocator](https://pub.dev/packages/geolocator), [geocoder](https://pub.dev/packages/geocoder) plugins.

## Getting Started

To use this plugin, add `address_search_text_field` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  address_search_text_field: ^1.1.0
```

### Android

**NOTE:** As plugins switched to the AndroidX version of the Android Support Libraries. This means you need to make sure your Android project is also upgraded to support AndroidX. Detailed instructions can be found [here](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility).

1. Add the following to your "gradle.properties" file:

```
android.useAndroidX=true
android.enableJetifier=true
```
2. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file to 28:

```
android {
  compileSdkVersion 28

  ...
}
```

## Permissions

### Android

On Android you'll need to add either the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission to your Android Manifest file (located under android/app/src/main). To do so add one of the following two lines as direct children of the `<manifest>` tag:

``` xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
Also you should add internet permission
``` xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS

On iOS you'll need to add the `NSLocationWhenInUseUsageDescription` to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following:

``` xml
<key>NSLocationWhenInUseUsageDescription</key>
<true/>
<key>NSLocationAlwaysUsageDescription</key>
<true/>
```

## Usage

Import the package:
```dart
import 'package:address_search_text_field/address_search_text_field.dart';
```
Implement it by creating an AddressSearchTextField variable. You can call **widget** function which returns a TextField Widget. It requires context, country and onDone as parameters, also can add exceptions for found addresses, InputDecoration and TextStyle for TextField.

```dart
Widget addressSearch = AddressSearchTextField.widget(
  context: context,
  decoration: InputDecoration(),
  style: TextStyle(),
  country: country,
  exceptions: <String>[],
  onDone: (AddressPoint value) {},
);
```

| Parameters | Description |
|------------|-------------|
| context | BuildContext (Not Null) (required) |
| decoration | InputDecoration (optional)|
| style | TextStyle (optional) |
| country | String (Not Null) (required) |
| exceptions | List < String > (optional)|
| onDone | Function(AddressPoint) (required) |

At onDone function you get an AddressPoint object with confirmation if place has been found, full address and coordinates. [Example](https://pub.dev/packages/address_search_text_field#-example-tab-)

## Outcomes

```dart
onDone: (AddressPoint point) {
  print(point.toString());
}
```

There are three possible outcomes:
1. If no search has been performed then the object will have null values ​​in its address, latitude and longitude variables.
2. If a place has been found from the reference, all the variables will be initialized.
3. If the desired location has not been found and the reference entered by the user is selected, there will be no latitude and longitude values ​​and the address will be the user's reference since nothing was found.

**NOTE:** User usually has to tap the text field in the search bar again to find the place with its full reference

![](https://raw.githubusercontent.com/JosLuna98/address_search_text_field/master/screenshot/untitled.gif)


##  License

MIT License
