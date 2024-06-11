import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuk_tuk_project_driver/assistants/assistants_method.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HometabPage extends StatefulWidget {
  const HometabPage({Key? key}) : super(key: key);

  @override
  State<HometabPage> createState() => _HometabPageState();
}

class _HometabPageState extends State<HometabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllGoogleMap.complete(controller);
            newGoogleMapController = controller;
            locateDriverPosition();
          },
        ),
        statusText != "Now Online"
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        )
            : Container(),
        Positioned(
          top: statusText != "Now Online"
              ? MediaQuery.of(context).size.height * 0.45
              : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (!isDriverActive) {
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();
                    setState(() {
                      statusText = "Now Online";
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });
                  } else {
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });
                    Fluttertoast.showToast(msg: "You are offline now");
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),

                child: statusText != "Now Online"
                    ? Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),)
                    : Icon(
                  Icons.phonelink_ring,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void locateDriverPosition() async {
    Position cPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latLngPosition =
    LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
    CameraPosition(target: latLngPosition, zoom: 15);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadabaleAddress = await AssistanntMethods.searchAddressGeographicCoordinates(
        driverCurrentPosition!, context);
    print("this Is our address = " + humanReadabaleAddress);
  }

  void readCurrentDriverInformation() async {
    currentUser = firebaseAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.name = (snap.snapshot.value as Map)["name"];
        onlineDriverData.address = (snap.snapshot.value as Map)["address"];
        onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.car_model =
        (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriverData.car_number =
        (snap.snapshot.value as Map)["car_details"]["car_number"];
        driverVehicleType =
        (snap.snapshot.value as Map)["car_details"]["type"];
      }
    });
  }

  void driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (pos != null) {
      driverCurrentPosition = pos;

      Geofire.initialize("activeDrivers");
      Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude);

      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("drivers")
          .child(currentUser!.uid)
          .child("newRideStatus");

      ref.set("idle");
      ref.onValue.listen((event) {});
    }
  }

  void updateDriversLocationAtRealTime() {
    if (isDriverActive) {
      streamSubscriptionPosition =
          Geolocator.getPositionStream().listen((Position position) {
            if (isDriverActive) {
              Geofire.setLocation(currentUser!.uid, position.latitude, position.longitude);
              LatLng latLng = LatLng(position.latitude, position.longitude);
              newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
            }
          });
    }
  }

  void driverIsOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}
