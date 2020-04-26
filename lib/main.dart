import 'dart:async';
import 'dart:io';
//import 'package:latlong/latlong.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import './login_page.dart';
import './auth.dart';
import './root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

// For beacon reading
  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;
  var startpos;
  var startpos2;
// For google maps
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
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

 checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }
   pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }
  
  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk ||
        !locationServiceEnabled ||
        !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }
    final regions = <Region>[
      Region(
        identifier: 'Cubeacon',
        proximityUUID: 'CB10023F-A318-3394-4199-A8730C7C1AEC',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      print(result);
      if (result != null && mounted) {
        setState(() {
          _regionBeacons[result.region] = result.beacons;
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
          });
          _beacons.sort(_compareParameters);
        });
      }
    });
  }

  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      print('BluetoothState = $state');
      streamController.add(state);

      switch (state) {
        case BluetoothState.stateOn:
          initScanBeacon();
          break;
        case BluetoothState.stateOff:
          await pauseScanBeacon();
          await checkAllRequirements();
          break;
      }
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
      WidgetsBinding.instance.addPostFrameCallback((_)=>broadcasting());
      listeningState();
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
void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        startpos=currentLocation.latitude;
      startpos2=currentLocation.longitude;

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
          actions: <Widget>[
            if (!authorizationStatusOk)
              IconButton(
                  icon: Icon(Icons.portable_wifi_off),
                  color: Colors.red,
                  onPressed: () async {
                    await flutterBeacon.requestAuthorization;
                  }),
            if (!locationServiceEnabled)
              IconButton(
                  icon: Icon(Icons.location_off),
                  color: Colors.red,
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      await flutterBeacon.openLocationSettings;
                    } else if (Platform.isIOS) {

                    }
                  }),
            StreamBuilder<BluetoothState>(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final state = snapshot.data;

                  if (state == BluetoothState.stateOn) {
                    return IconButton(
                      icon: Icon(Icons.bluetooth_connected),
                      onPressed: () {},
                      color: Colors.lightBlueAccent,
                    );
                  }

                  if (state == BluetoothState.stateOff) {
                    return IconButton(
                      icon: Icon(Icons.bluetooth),
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          try {
                            await flutterBeacon.openBluetoothSettings;
                          } on PlatformException catch (e) {
                            print(e);
                          }
                        } else if (Platform.isIOS) {

                        }
                      },
                      color: Colors.red,
                    );
                  }

                  return IconButton(
                    icon: Icon(Icons.bluetooth_disabled),
                    onPressed: () {},
                    color: Colors.grey,
                  );
                }

                return SizedBox.shrink();
              },
              stream: streamController.stream,
              initialData: BluetoothState.stateUnknown,
            ),
          ],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(38.5449, -121.7405),
            zoom: 11.0,
          ),
           markers: _markers.values.toSet(),
        ),
        // body: new TabBarView(
        //   controller: controller,
        //   children: <Widget>[
        //     questions.Questions(),
        //     mapuse.MyApp(),
        //   ],
        
        floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Get Location',
        child: Icon(Icons.location_searching),

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          
      




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
    WidgetsBinding.instance.removeObserver(this);
    streamController?.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;
    controller.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new RootPage(auth: new Auth()),
    );
  }
}
