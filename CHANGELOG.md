## [1.2.0]

* Parameter for the controller to **AddressSearchTextField**
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
