import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/models/user_ride_request_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class NewTripScreen extends StatefulWidget {
  // const NewTripScreen({super.key});
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({
    userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {


  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Set<Marker> setOfMarkers=Set<Marker>();
  Set<Circle> setOfCircle=Set<Circle>();
  Set<Polyline> setOfPolyline=Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates=[];
  PolylinePoints polylinePoints=PolylinePoints();

  double mapPadding=0;
  BitmapDescriptor?iconAnimatedMaker;
  var geoLocator=Geolocator();

  Position? onlineDriverCurrentPosition;
  String rideRequestStatus="accepted";
  String durationFromOriginToDestination="";
  bool isRequestDirectionDetails=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller){
              _controllGoogleMap.complete(controller);
              newTripGoogleMapController=controller;

              setState(() {
                mapPadding=350;
              });

              var driverCurrentLatlng=LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

              var userPickUpLatlng=widget.userRideRequestDetails!.originLatlng;
              durationFromOriginToDestination(driverCurrentLatlng,userPickUpLatlng,ColorScheme.dark());

              getDriversLocationRealTime();
          }
            
          )
        ],
      ),
    )
  }
}
