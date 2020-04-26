import 'dart:async';
//import 'package:latlong/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import './questions.dart' as questions;
import './map_main.dart' as mapuse;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin{

  GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  TabController controller;
  static const UUID = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const MAJOR_ID = 1;
  static const MINOR_ID = 100;
  static const TRANSMISSION_POWER = -59;
  static const IDENTIFIER = 'com.example.myDeviceRegion';
  static const LAYOUT = 'm:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24';
  static const MANUFACTURER_ID = 0x0118;

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  @override
  void initState() {
    super.initState();
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
      WidgetsBinding.instance.addPostFrameCallback((_)=>broadcasting());
      controller=new TabController(length: 2, vsync: this);
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }
  
  broadcasting() async{
    beaconBroadcast
      .setUUID(UUID)
      .setMajorId(MAJOR_ID)
      .setMinorId(MINOR_ID)
      .setTransmissionPower(-59)
      .setIdentifier(IDENTIFIER)
      .setLayout(LAYOUT)
      .setManufacturerId(MANUFACTURER_ID)
      .start();
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          title: const Text('HackDSC'),
          centerTitle: true,
          // bottom: new TabBar(
          //   controller: controller,
          //   tabs: <Widget>[
          //   new Tab(icon: new Icon(Icons.question_answer)),
          //   new Tab(icon: new Icon(Icons.map)
          //   )
          // ]
          // ),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
        // body: new TabBarView(
        //   controller: controller,
        //   children: <Widget>[
        //     questions.Questions(),
        //     mapuse.MyApp(),
        //   ],
        
        floatingActionButton: new FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.red,
          child: new Icon(Icons.question_answer),
          ),
          





        // body: SingleChildScrollView(
        //   child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       mainAxisSize: MainAxisSize.min,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: <Widget>[
        //         Text('Is transmission supported?',
        //             style: Theme.of(context).textTheme.headline),
        //         Text('$_isTransmissionSupported',
        //             style: Theme.of(context).textTheme.subhead),
        //         Container(height: 16.0),
        //         Text('Is beacon started?', style: Theme.of(context).textTheme.headline),
        //         Text('$_isAdvertising', style: Theme.of(context).textTheme.subhead),
        //         Container(height: 16.0),
        //         Center(
        //           child: RaisedButton(
        //             onPressed: () {
        //               beaconBroadcast
        //                   .setUUID(UUID)
        //                   .setMajorId(MAJOR_ID)
        //                   .setMinorId(MINOR_ID)
        //                   .setTransmissionPower(-59)
        //                   .setIdentifier(IDENTIFIER)
        //                   .setLayout(LAYOUT)
        //                   .setManufacturerId(MANUFACTURER_ID)
        //                   .start();
        //             },
        //             child: Text('START'),
        //           ),
        //         ),
        //         Center(
        //           child: RaisedButton(
        //             onPressed: () {
        //               beaconBroadcast.stop();
        //             },
        //             child: Text('STOP'),
        //           ),
        //         ),
        //         Text('Beacon Data', style: Theme.of(context).textTheme.headline),
        //         Text('UUID: $UUID'),
        //         Text('Major id: $MAJOR_ID'),
        //         Text('Minor id: $MINOR_ID'),
        //         Text('Tx Power: $TRANSMISSION_POWER'),
        //         Text('Identifier: $IDENTIFIER'),
        //         Text('Layout: $LAYOUT'),
        //         Text('Manufacturer Id: $MANUFACTURER_ID'),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }
}

class Agora {
}