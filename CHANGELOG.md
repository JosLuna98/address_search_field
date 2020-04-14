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
* Private *_AddressSearch* widget is now public and is called **AddressSearchBox**, it can be used independently.
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

* *values* is now called *result*.
* Update documentation.

## [0.0.1]

* First release.
