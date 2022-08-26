## [5.0.3]
* Fix null check operator in setLocation method.
## [5.0.2]
* Add style options for icon and text colors.
* Update dependencies.
## [5.0.1]
* ## BREAKING CHANGES: read documentation is needed.
## [4.0.0]
* Fix null safety migration.
## [3.1.0-nullsafety.0]
* `AddressSearchDialog` widget is private now.
* `google_maps_flutter` and `http` plugins implementation updated.
* Migrate to null safety.
* Documentation updated.
## [3.0.10]
* `country` parameter is not longer required in `GeoMethods`.
* `countryCode` parameter is not longer required in `GeoMethods`.
* New parameter `countryCodes` added in `GeoMethods` to autocomplete an address filtering up to 5 countries.
* New method `copyWith` added in `GeoMethods` to use a modified copy from an object of this type.
* `countryCode` parameter is required in the `GeoMethods` object to run `getDirections` method.
## [3.0.9]
* `city` parameter is not longer required in `GeoMethods`.
## [3.0.8]
* New `typedef`s for functions.
* All tests passed.
## [3.0.7]
* New extensions to convert `List<Address>` to `List<Coords>` and `List<Address>` to `List<Coords>`.
#### RouteSearchBox
* `relocate` function has a new param called `changeReference` to update `Coords` in an internal `Address` now.
#### Address
* Internal params are public and final now.
* `update` function becomes in `copyWith` and it gives back an `Address`.
#### WaypointsManager
* `update` function added.
## [3.0.6]
* Extensions for `LatLng` and `LatLngBounds` to convert them into `Coords` and `Bounds` addded.
## [3.0.5]
* New `AddressLocator` widget to set an initial address reference in a `TextEditingController`.
* `originIsMyLocation` param removed in `RouteSearchBox`.
## [3.0.4]
* New `AddressId` enum to identify address which will be updated by `r
#### WaypointsManager
* `onDelete` function becomes in `remove`
* `clear` function added.
#### GeoMethods
* Error prevented in `getDirections` function.
#### RouteSearchBox
* `relocate` function permits to change origin and destination `Address` using an `AddressId` and `Coords` now.
## [3.0.3+1]
* `RouteError` enum created to identify errors easly.
* `relocate` function added to `RouteSearchBox` builder to reload origin address.
## [3.0.2]
* fix issue in `AddressSearchBuilder.deft` constructor.
## [3.0.1]
* Function in WaypointsManager added to remove elements in the list of waypoints.
## [3.0.0]
* ## BREAKING CHANGES: read documentation is needed.
## [2.1.0+1]
* Documentation improved.
* Better implementation of dart extensions in example.
## [2.1.0]
* `AddressSearchField` is called `AddressField` now.
* `AddressSearchDialog` is called `AddressDialog` now.
* `AddressFieldCtor` is called `AddressFieldBuilder` now.
* `AddressDialogCtor` is called `AddressDialogBuilder` now.
* `RouteSearchBox` doesn't have two `TextEditingController`.
* `AddressField` is converted from `TextField` to a `TextFormField`.
* `AddressField` can use all the `TextFormField` parameters.
* FlutterToast looks better in web.
## [2.0.1]
* Error handling for `GeoMethods` added.
* `duration` and `distance` values in `Directions` class casted.
* `updateCoords` function in `Address` class removed.
* [FlutterToast](https://pub.dev/packages/fluttertoast) implemented to show info messages.
* Implement of flutter web support in progress.
## [2.0.0+1]
* Everything is new, excepting the plugin context. See [README](https://pub.dev/packages/address_search_field#-readme-tab-).
## [1.4.2]
* Add explicit dialog context like a parameter in the onDone function.
## [1.4.1]
* Fix possible bug from useless conditional.
## [1.4.0]
* Remake of [AddressSearchTextField](https://pub.dev/packages/address_search_text_field) Plugin due to the update of Flutter 1.17 and Dart 2.8
* `LocationService` class is now an async static function called `initLocationService`
* Updated the [README.md](https://pub.dev/packages/address_search_field#-readme-tab-) for a better explanation of plugin.
## [1.3.5+1]
* discontinued.
## [1.3.5]
* The *onCleaned* function parameter added in **AddressSearchTextField** and **AddressSearchBox**.
## [1.3.4]
* Limiter sufix icon in **AddressSearchBox** to search for an address removed.
* The search for an address is optimized.
* New *city*, *hintText* and *noResultsText* parameters added in **AddressSearchTextField** and **AddressSearchBox**.
## [1.3.3+2]
* A bug when the user selects their reference in **AddressSearchBox** widget fixed.
## [1.3.3]
* A *barrierDismissible* parameter added in **AddressSearchTextField**.
* The *onEditingComplete* and *onChanged* internal functions in **AddressSearchBox** adapted to new functionalities.
* The *onDone* function is no longer required.
## [1.3.2]
* sufix icon in **AddressSearchBox** modified to can limit addresses requests.
## [1.3.1]
* Limiter to search for an address removed.
## [1.3.0+1]
* Static method *widget* removed from **AddressSearchTextField**, it's a stateless widget now.
* **AddressSearchTextField** widget doesn't need context parameter.
## [1.2.2]
* **AddressPoint** returns valid latitude and longitude values when *found* is false.
* UI issues in **AddressSearchBox** fixed.
## [1.2.1]
* Dependency in example app fixed.
* *coordForRef* boolean added, if **AddressSearchBox** finds coordinates by a written reference but not nearby places and the user selects the reference, then those coordinates can be used.
## [1.2.0]
* Parameter for the controller added to **AddressSearchTextField**
* Private *_AddressSearch* widget is now public and is named **AddressSearchBox**, it can be used independently.
* *onDone* function in **AddressSearchBox** can now be asynchronous and have a CircularProgressIndicator while it's running.
* *onDone* function now doesn't pop the widget, you have to add the code to close it.
* **AddressPoint** object has a new method to find an address from passed latitude and longitude values.
## [1.1.0]
* Optimized
* Class name changed to **AddressSearchTextField**
* *country* parameter added to AddressPoint object
* AddressPoint object only has *getters* for its values
## [1.0.0]
* Static functions issue fixed.
* *result* getter function removed.
* Callback with *result* added.
* parameter for TextStyle added.
## [0.1.0+1]
* *values* is named *result* now.
* Update documentation.
## [0.0.1]
* First release.