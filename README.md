# Address Search Text Field

A text field that displays an address search bar that finds a location from a reference and gets nearby addresses. Selecting the desired address returns an object with the latitude, longitude, and full address of the place.
It's use [location](https://pub.dev/packages/location), [geolocator](https://pub.dev/packages/geolocator), [geocoder](https://pub.dev/packages/geocoder) plugins.

## Getting Started

To use this plugin, add `address_search_text_field` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). For example:

```yaml
dependencies:
  address_search_text_field: 0.0.1
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

On Android you'll need to add either the `ACCESS_COARSE_LOCATION` or the `ACCESS_FINE_LOCATION` permission to your Android Manifest. To do so open the AndroidManifest.xml file (located under android/app/src/main) and add one of the following two lines as direct children of the `<manifest>` tag:

``` xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

On iOS you'll need to add the `NSLocationWhenInUseUsageDescription` to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following:

``` xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

If you would like to access the device's location when your App is running in the background, you should also add the `NSLocationAlwaysAndWhenInUseUsageDescription` (if your App support iOS 10 or earlier you should also add the key `NSLocationAlwaysUsageDescription`) key to your Info.plist file:

``` xml
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location when open and in the background.</string>
```

## Usage

Import the package:
```dart
import 'package:address_search_text_field/address_search_text_field.dart';
```
Implement it by creating a SearchAddressTextField variable. You can call the widget using **widget** function and giving it a context and country, also can add exceptions for the found addresses and a InputDecoration for TextField.
```dart
class MyHomePage extends StatelessWidget {
  final SearchAddressTextField searchAddress = SearchAddressTextField();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          width: size.width * 0.80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SearchAddressTextField.widget(
                context: context,
                country: "Ecuador",
                exceptions: [
                  "Esmeraldas, Ecuador",
                  "Esmeraldas Province, Ecuador",
                  "Ecuador"
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              FlatButton(
                child: Text("get data"),
                color: Colors.blue,
                onPressed: () {
                  AddressPoint point = searchAddress.values;
                  print(point.toString());
                }
              )
            ]
          )
        )
      )
    );
  }
}
```
Then you just need to call **values** function to get an AddressPoint object with the found address and coordinates.