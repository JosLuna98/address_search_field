import 'dart:async';
import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

var _initialPositon;

Future<Coords> _getPosition() async {
  final Location location = Location();
  if (!await location.serviceEnabled()) {
    if (!await location.requestService()) throw 'GPS service is disabled';
  }
  if (await location.hasPermission() == PermissionStatus.denied) {
    if (await location.requestPermission() != PermissionStatus.granted)
      throw 'No GPS permissions';
  }
  final data = await location.getLocation();
  return Future.value(Coords(data.latitude, data.longitude));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initialPositon = await _getPosition();
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
  GoogleMapController _controller;

  final TextEditingController origCtrl = TextEditingController();

  final TextEditingController destCtrl = TextEditingController();

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Plugin example app'),
          ),
          body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                RouteSearchBox(
                  geoMethods: geoMethods,
                  originIsMyLocation: true,
                  originCtrlr: origCtrl,
                  destinationCtrlr: destCtrl,
                  builder: (context, originBuilder, destinationBuilder,
                      waypointBuilder,
                      {getDirections, waypointsMgr}) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      color: Colors.green[50],
                      height: 150.0,
                      child: Column(
                        children: [
                          TextField(
                            controller: origCtrl,
                            onTap: () => showDialog(
                              context: context,
                              builder:
                                  (context) => // You can build your own widget to search addresses.
                                      originBuilder.build(
                                (context, snapshot,
                                        {controller,
                                        getGeometry,
                                        searchAddress}) =>
                                    AddressSearchDialog(
                                  snapshot: snapshot,
                                  controller: controller,
                                  searchAddress: searchAddress,
                                  getGeometry: getGeometry,
                                  onDone: (address) => null,
                                ),
                              ),
                            ),
                          ),
                          TextField(
                            controller: destCtrl,
                            onTap: () => showDialog(
                              context: context,
                              builder:
                                  (context) => // You can build the default widget in the plugin to search addresses.
                                      destinationBuilder.buildDefault(
                                builder: AddressDialogBuilder(),
                                onDone: (address) => null,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                child: Text('Waypoints'),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) => Waypoints(
                                          waypointsMgr, waypointBuilder),
                                    )),
                              ),
                              ElevatedButton(
                                child: Text('Search'),
                                onPressed: () async {
                                  try {
                                    final result = await getDirections();
                                    markers.clear();
                                    polylines.clear();
                                    markers.addAll([
                                      Marker(
                                          markerId: MarkerId('origin'),
                                          position: result.origin.coords),
                                      Marker(
                                          markerId: MarkerId('dest'),
                                          position: result.destination.coords)
                                    ]);
                                    result.waypoints.asMap().forEach(
                                        (key, value) => markers.add(Marker(
                                            markerId: MarkerId('point$key'),
                                            position: value.coords)));
                                    polylines.add(Polyline(
                                      polylineId: PolylineId('result'),
                                      points: result.points,
                                      color: Colors.blue[400],
                                      width: 5,
                                    ));
                                    setState(() {});
                                    await _controller.animateCamera(
                                        CameraUpdate.newLatLngBounds(
                                            result.bounds, 60.0));
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  height: constraints.constrainHeight() - 205.0,
                  child: GoogleMap(
                    compassEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    rotateGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: _initialPositon,
                      zoom: 14.5,
                    ),
                    onMapCreated: (GoogleMapController controller) =>
                        _controller = controller,
                    polylines: polylines,
                    markers: markers,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Waypoints extends StatelessWidget {
  const Waypoints(this.waypointsMgr, this.waypointBuilder);

  final WaypointsManager waypointsMgr;
  final AddressSearchBuilder waypointBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add_location_alt),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => waypointBuilder.buildDefault(
                builder: AddressDialogBuilder(),
                onDone: (address) => null,
              ),
            ),
          )
        ],
      ),
      body: ValueListenableBuilder<List<Address>>(
        valueListenable: waypointsMgr.valueNotifier,
        builder: (context, value, _) => ListView.separated(
          itemCount: value.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int index) =>
              ListTile(title: Text(value[index].reference)),
        ),
      ),
    );
  }
}
