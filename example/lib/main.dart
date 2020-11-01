import 'dart:async';
import 'package:flutter/material.dart';
import 'package:address_search_field/address_search_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafeArea(child: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Completer<GoogleMapController> _controller = Completer();

  final TextEditingController oriCtrl =
      TextEditingController.fromValue(TextEditingValue(text: 'las palmas'));

  final TextEditingController desCtrl =
      TextEditingController.fromValue(TextEditingValue(text: 'gran aki'));

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Polyline> polylines = Set<Polyline>();
  final Set<Marker> markers = Set<Marker>();

  final GeoMethods geoMethods = GeoMethods(
    googleApiKey: 'GOOGLE_API_KEY',
    language: 'es-419',
    countryCode: 'ec',
    country: 'Ecuador',
    city: 'Esmeraldas',
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: size.height - 230.0,
                width: size.width,
                child: GoogleMap(
                  compassEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  rotateGesturesEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  polylines: polylines,
                  markers: markers,
                ),
              ),
              Container(
                color: Colors.white,
                height: 150.0,
                width: size.width,
                child: RouteSearchBox(
                  geoMethods: geoMethods,
                  originCtrl: oriCtrl,
                  originCtor: AddressFieldCtor(
                    addressDialog: AddressDialogCtor(
                      onDone: (address) async {
                        print(address);
                        if (address.hasCoords) {
                          markers.clear();
                          polylines.clear();
                          markers.add(Marker(
                            markerId: MarkerId('origin'),
                            position: CoordsConvert(address.coords).toLatLng(),
                          ));
                          if (_controller.isCompleted) {
                            (await _controller.future).animateCamera(
                                CameraUpdate.newLatLngBounds(
                                    BoundsConvert(address.bounds).toLatLng(),
                                    60.0));
                          }
                        }
                        return address != null;
                      },
                    ),
                  ),
                  destinationCtrl: desCtrl,
                  destinationCtor: AddressFieldCtor(
                    addressDialog: AddressDialogCtor(
                      onDone: (address) async {
                        print(address);
                        if (address.hasCoords) {
                          markers.clear();
                          polylines.clear();
                          markers.add(Marker(
                            markerId: MarkerId('destination'),
                            position: CoordsConvert(address.coords).toLatLng(),
                          ));
                          if (_controller.isCompleted && address.hasCoords) {
                            (await _controller.future).animateCamera(
                                CameraUpdate.newLatLngBounds(
                                    BoundsConvert(address.bounds).toLatLng(),
                                    60.0));
                          }
                        }
                        return address != null;
                      },
                    ),
                  ),
                  widgetBuilder:
                      (context, originField, destinationField, getDirections) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        originField,
                        destinationField,
                        RaisedButton(
                          onPressed: () async {
                            Directions result = await getDirections([]);
                            if (_controller.isCompleted) {
                              setState(() {
                                markers.clear();
                                markers.add(Marker(
                                  markerId: MarkerId('origin'),
                                  position: CoordsConvert(result.origin.coords)
                                      .toLatLng(),
                                ));
                                markers.add(Marker(
                                  markerId: MarkerId('destination'),
                                  position:
                                      CoordsConvert(result.destination.coords)
                                          .toLatLng(),
                                ));
                                polylines.clear();
                                polylines.add(Polyline(
                                  polylineId: PolylineId("route"),
                                  points: ListConvert(result.points).toLatLng(),
                                  color: Colors.green,
                                  width: 5,
                                ));
                              });
                              (await _controller.future).animateCamera(
                                  CameraUpdate.newLatLngBounds(
                                      BoundsConvert(result.bounds).toLatLng(),
                                      60.0));
                            }
                            print(result);
                          },
                          child: Text("let's go!"),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
