import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/assistants/assistants_method.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/models/user_ride_request_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';
import 'package:tuk_tuk_project_driver/screens/wrapper.dart';
import 'package:tuk_tuk_project_driver/widgets/fare_amount_collection_dialog.dart';
import 'package:tuk_tuk_project_driver/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';


class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({this.userRideRequestDetails,});

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

  String? buttonTitle="Arrived";
  Color? buttonColor=Colors.green;

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

  Future <void> drawPolyLineFromOriginToDestination(LatLng originLatLng,LatLng destinationLatLng) async{
    showDialog(
        context: context,
        builder: (BuildContext context)=>ProgressDialog(),
    );

    var directionDetailsInfo = await AssistanntMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    PolylinePoints nPoints=PolylinePoints();
    List<PointLatLng> decodePolyLinePointResultsList=nPoints.decodePolyline(directionDetailsInfo.e_points!);
    polyLinePositionCoordinates.clear();

    if(decodePolyLinePointResultsList.isNotEmpty){
      decodePolyLinePointResultsList.forEach((PointLatLng pointLatlng){
        polyLinePositionCoordinates.add(LatLng(pointLatlng.latitude, pointLatlng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline=Polyline(
        color: Colors.black,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 3
      );
      
      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude>destinationLatLng.latitude && originLatLng.longitude>destinationLatLng.longitude){
      boundsLatLng=LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude>destinationLatLng.longitude){
      boundsLatLng=LatLngBounds(
          southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,originLatLng.longitude)
      );
    }
    else if(originLatLng.latitude>destinationLatLng.latitude){
      boundsLatLng=LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude,destinationLatLng.longitude)
      );
    }
    else{
      boundsLatLng=LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng,55));

    Marker originMarker=Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker=Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle=Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 5,
      strokeWidth: 3,
      strokeColor:Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle=Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 5,
      strokeWidth: 3,
      strokeColor:Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    saveAssignedDriverDetailsToUserRideRequest();
    super.initState();
  }


  getDriversLocationRealTime(){
    LatLng oldLatLng=LatLng(0, 0);

    streamSubscriptionDriverLivePosition=Geolocator.getPositionStream().listen((Position position)
    {
      driverCurrentPosition=position;
      onlineDriverCurrentPosition=position;

      LatLng latLngLiveDriverPosition=LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker=Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMaker!,
        infoWindow: InfoWindow(title: "This is your position"),
      );

      setState(() {
        CameraPosition cameraPosition=CameraPosition(target: latLngLiveDriverPosition,zoom: 18);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        
        setOfMarkers.removeWhere((element)=>element.markerId.value=="AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng=latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      Map driverLatLngDataMap={
        "latitude":onlineDriverCurrentPosition!.latitude.toString(),
        "longitude":onlineDriverCurrentPosition!.longitude.toString(),
      };

      FirebaseDatabase.instance.ref().child("All Ride Request").child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);

    });
  }

  updateDurationTimeAtRealTime() async{
    if(isRequestDirectionDetails==false){
      isRequestDirectionDetails=true;

      if(onlineDriverCurrentPosition==null){
        return;
      }

      var originLatLng=LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
      var destinationLatLng;

      if(rideRequestStatus=="accepted"){
        destinationLatLng=widget.userRideRequestDetails!.originLatlng;
      }
      else{
        destinationLatLng=widget.userRideRequestDetails!.destinationLatlng;
      }

      var directionInformation= await AssistanntMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation!=null){
        setState(() {
          durationFromOriginToDestination=directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails=false;
    }
  }


  createDriverIconMarker(){
    if(iconAnimatedMaker==null){
      ImageConfiguration imageConfiguration=createLocalImageConfiguration(context,size: Size(2,2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/car_marker.png").then((value)
        {
          iconAnimatedMaker=value;
        });
    }
  }

  saveAssignedDriverDetailsToUserRideRequest(){
    DatabaseReference databaseReference=FirebaseDatabase.instance.ref().child("All Ride Request").child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap={
      "latitude":driverCurrentPosition!.latitude.toString(),
      "longitude":driverCurrentPosition!.longitude.toString(),
    };

    if(databaseReference.child("driverId")!="waiting"){
      databaseReference.child("driverLocation").set(driverLocationDataMap);

      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      databaseReference.child("car_details").set(onlineDriverData.car_model.toString()+" "+onlineDriverData.car_number.toString()+" "+onlineDriverData.car_type.toString());
      databaseReference.child("car_image").set(onlineDriverData.carImage);

      saveRideRequestIdToDriverHistory();
    }

    else{
      Fluttertoast.showToast(msg: "Ride is already taken by another driver.");
      Navigator.push(context,MaterialPageRoute(builder: (c)=>Wrapper()));
    }


  }

  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripsHistoryRef=FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("triphistory");
    tripsHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }


  endTripNow() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder:(BuildContext context)=> ProgressDialog()
    );

    var currentDriverPositionLatLng=LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var tripDirectionDetails= await AssistanntMethods.obtainOriginToDestinationDirectionDetails(currentDriverPositionLatLng,widget.userRideRequestDetails!.originLatlng!);

    double totalFareAmount=AssistanntMethods.calculateFairAmountFromOriginToDestination(tripDirectionDetails);
    FirebaseDatabase.instance.ref().child("All Ride Request").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());
    FirebaseDatabase.instance.ref().child("All Ride Request").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("ended");
    streamSubscriptionDriverLivePosition!.cancel();

    Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext context)=>FareAmountCollectionDialog(
          totalFareAmount: totalFareAmount,
        )
    );

    saveFareAmountToDriverEarnings(totalFareAmount);
  }


  saveFareAmountToDriverEarnings(double totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value!=null){
        double oldEarnings=double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings=totalFareAmount+oldEarnings;

        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }
      else{
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalFareAmount.toString());
      }
    });

  }



  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();


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

              drawPolyLineFromOriginToDestination(driverCurrentLatlng,userPickUpLatlng!,);

              getDriversLocationRealTime();
          }
            
          ),
          
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 18,
                        spreadRadius: 0.5,
                        offset: Offset(0.6, 0.6)
                      )
                    ]
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                            durationFromOriginToDestination,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10,),

                        Divider(thickness: 1,color: Colors.grey,),

                        SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.userRideRequestDetails!.userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                              ),
                            ),

                            IconButton(
                                onPressed: (){},
                                icon:Icon(Icons.phone,
                                color: Colors.black,)
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset('assets/locations.png',
                            width: 30,
                            height: 30,
                            ),

                            SizedBox(height: 10),

                            Expanded(
                                child: Container(
                                  child: Text(
                                    widget.userRideRequestDetails!.originAddress!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),

                        SizedBox(height: 10,),

                        Row(
                          children: [
                            Image.asset('assets/locationh.png',
                              width: 30,
                              height: 30,
                            ),

                            SizedBox(height: 10),

                            Expanded(
                                child: Container(
                                  child: Text(
                                    widget.userRideRequestDetails!.destinationAddress!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                            )
                          ],
                        ),

                        
                        SizedBox(height: 10,),

                        Divider(thickness: 1,color: Colors.grey,),
                        
                        SizedBox(height: 10,),
                        
                        ElevatedButton.icon(
                            onPressed: () async {
                              if(rideRequestStatus=="accepted"){
                                rideRequestStatus="arrived";
                                FirebaseDatabase.instance.ref().child("All Ride Request").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle="Let's Go";
                                  buttonColor=Colors.lightGreen;
                                });


                                await drawPolyLineFromOriginToDestination(
                                  widget.userRideRequestDetails!.originLatlng!,
                                  widget.userRideRequestDetails!.destinationLatlng!,
                                );

                              }

                              else if(rideRequestStatus=="arrived"){
                                rideRequestStatus="ontrip";

                                FirebaseDatabase.instance.ref().child("All Ride Request").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);

                                setState(() {
                                  buttonTitle="End Trip";
                                  buttonColor=Colors.redAccent;
                                });
                              }

                              else if(rideRequestStatus=="ontrip"){
                                endTripNow();
                              }
                            },

                            icon: Icon(Icons.directions_car,color: Colors.black,size: 25,),
                            label: Text(
                              buttonTitle!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        )


                      ],
                    ),
                  ),
                ),
              )
          )
        ],
      ),
    );
  }
}
