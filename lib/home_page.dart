import 'package:flutter/material.dart';
import './auth.dart';
import './main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(HomePage());

class HomePage extends StatelessWidget {
  HomePage({this.auth, this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;
  
  @override
  Widget build(BuildContext context) {

    void _signOut() async {
      try {
        await auth.signOut();
        onSignOut();
      } catch (e) {
        print(e);
      }
    }
      return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new FlatButton(
              onPressed: _signOut,
              child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.white))
          )
        ],
      ),
      body: MyMap(),
    );
  }
}

class MyMap extends StatefulWidget {
  @override
  State<MyMap> createState() => MyMapSampleState();
}
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


class MyMapSampleState extends State<MyMap> {

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _markers.clear();
      
      final marker = Marker(
          markerId: MarkerId("curr_loc"),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: LatLng(40.688841, -74.044015),
          zoom: 11,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Get Location',
        child: Icon(Icons.flag),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
