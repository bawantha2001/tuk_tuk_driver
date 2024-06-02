import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuk_tuk_project_driver/assistants/assistants_method.dart';
import 'package:tuk_tuk_project_driver/assistants/geofire_assistant.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/global/map_key.dart';
import 'package:tuk_tuk_project_driver/infoHandler/App_info.dart';
import 'package:tuk_tuk_project_driver/models/ActiveNearbyAvailableDrivers.dart';
import 'package:tuk_tuk_project_driver/screens/Search_places_screen.dart';
import 'package:tuk_tuk_project_driver/screens/precise_pickup_location.dart';
import 'package:tuk_tuk_project_driver/screens/wrapper.dart';
import 'package:tuk_tuk_project_driver/widgets/progress_dialog.dart';

import '../models/directions.dart';
import 'drawer_screen.dart';

class Main_screen extends StatefulWidget {
  const Main_screen({super.key});

  @override
  State<Main_screen> createState() => _Main_screenState();
}


class _Main_screenState extends State<Main_screen> {

  LatLng? pickLocation;
  loc.Location location=loc.Location();
  String? _address;
  bool iscammoving = false;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerWeight = 220;
  double waittingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestRideContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentposition;
  var geolocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingofMap=0;

  List<LatLng> pLineCoordinateList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;
  bool dropoffobtained = false;

  bool activeDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  String selectedVehicleType = "";

  DatabaseReference? referenceRideRequest;

  String userRideRequestStatus = "";

  String driverRideStatus = "Driver is coming";

  bool requestPositionInfo = true;

  List<Activenearbyavailabledrivers> onlinNearbyAvailableDriversList = [];

  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  locateUserPosition() async{
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog()
    );

    try{
      Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      userCurrentposition = cPosition;

      LatLng latLngPosition = LatLng(userCurrentposition!.latitude, userCurrentposition!.longitude);

      CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 15);

      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String humanReadabaleAddress = await AssistanntMethods.searchAddressGeographicCoordinates(userCurrentposition!, context);
      print("this Is our address = "+humanReadabaleAddress);

      AssistanntMethods.readCurrentOnlineUserInfo();
      userName = userModelCurrrentInfo!.name!;
      userEmail = userModelCurrrentInfo!.email!;

      initalizeGeoFireListner();
      // AssistanntMethods.readTripsKeysForOnlineUser(context);

      Navigator.pop(context);
    }catch(error){
      Navigator.pop(context);
    }


  }

  initalizeGeoFireListner(){
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentposition!.latitude, userCurrentposition!.longitude, 10)!
    .listen((map){
      print(map);

      if(map != null){
        var callBack = map["callBack"];

        switch(callBack){
          case Geofire.onKeyEntered:
            Activenearbyavailabledrivers activenearbyavailabledriver = Activenearbyavailabledrivers();
            activenearbyavailabledriver.locationLongitude = map["latitude"];
            activenearbyavailabledriver.locationLongitude = map["longitude"];
            activenearbyavailabledriver.driverId = map["key"];
            GeofireAssistant.activenearbyavailabledriversList.add(activenearbyavailabledriver);
            if(activeDriverKeysLoaded == true){
              displayActiveDriversOnUsersMap();
            }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.deleteofflineDriverFromList(map["key"]);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onKeyMoved:
            Activenearbyavailabledrivers activenearbyavailabledriver = Activenearbyavailabledrivers();
            activenearbyavailabledriver.locationLattitude = map["latitude"];
            activenearbyavailabledriver.locationLongitude = map["longitude"];
            activenearbyavailabledriver.driverId = map["key"];
            GeofireAssistant.updateActiveNearByAvailableDriverLocation(activenearbyavailabledriver);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onGeoQueryReady:
            activeDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {

      });
    });
  }

  displayActiveDriversOnUsersMap(){
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();
      for(Activenearbyavailabledrivers eachdriver in GeofireAssistant.activenearbyavailabledriversList){
        LatLng eachDriverActivePosition = LatLng(eachdriver.locationLattitude!, eachdriver.locationLongitude!);
        
        Marker marker = Marker(
            markerId: MarkerId(eachdriver.driverId!),
            position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markerSet = driversMarkerSet;
      });

    });

    print("users $Activenearbyavailabledrivers");
  }

  createAciveNearbyDriverIconMarker(){
    if(activeNearbyIcon == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size:Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/tuk-tuk.png").then((value){
        activeNearbyIcon = value;
      });
    }
  }
  
  
  Future<void> drawPolyLineFromOriginToDestination()async{

    var originPosition = Provider.of<AppInfo>(context,listen: false).userPickupLocation;
    var destinationPosition = Provider.of<AppInfo>(context,listen: false).userDropoffLocation;
    
    var originLatLng = LatLng(originPosition!.locationLattitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLattitude!, destinationPosition!.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog()
    );

    var directionDetalisInfo = await AssistanntMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetalisInfo;
    });

    Navigator.pop(context);
    
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList = polylinePoints.decodePolyline(directionDetalisInfo.e_points!);

    pLineCoordinateList.clear();

    if(decodePolylinePointsResultList.isNotEmpty){
      decodePolylinePointsResultList.forEach((PointLatLng pointLatLng){
        pLineCoordinateList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.blue,
        polylineId: PolylineId("polylineID"),
        jointType: JointType.round,
        points: pLineCoordinateList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      latLngBounds = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
      }

    else if(originLatLng.longitude > destinationLatLng.longitude){
      latLngBounds =   LatLngBounds(
        southwest: LatLng(originLatLng.latitude,destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude,originLatLng.longitude),
      );
    }

    else if(originLatLng.latitude > destinationLatLng.latitude){
      latLngBounds =   LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude,originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude,destinationLatLng.longitude),
      );
    }
    else{
      latLngBounds =   LatLngBounds(
        southwest: originLatLng,
        northeast: destinationLatLng,
      );
    }
    
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName,snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName,snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
        circleId: CircleId("originId"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationId"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });

  }

  void showSugestedRidesContainer(){
    setState(() {
      suggestRideContainerHeight = 400;
      bottomPaddingofMap = 400;
    });
  }

  getAddressfromLatLng() async{
    try{
      GeoData data = await Geocoder2.getDataFromCoordinates(latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: mapKey);

      setState(() {
        Directions userPickupAddress = Directions();
        userPickupAddress.locationLattitude = pickLocation!.latitude;
        userPickupAddress.locationLongitude = pickLocation!.longitude;
        userPickupAddress.locationName = data.address;

        Provider.of<AppInfo>(context,listen: false).updatePickuplocationAddress(userPickupAddress);
      });

    }catch(e){
      print(e.toString());
    }

  }

  checkIfLocationPermissionAllowed()async{
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }

  }

  saveRideRequestInformation(String selectedVehicleType){
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Request").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropoffLocation;

    Map originLocationMap = {
      "latitude":originLocation!.locationLattitude.toString(),
      "longitude":originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      "latitude":destinationLocation!.locationLattitude.toString(),
      "longitude":destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap ={
      "origin":originLocationMap,
      "destination":destinationLocationMap,
      "time":DateTime.now().toString(),
      "userName":userModelCurrrentInfo!.name,
      "userphone":userModelCurrrentInfo!.phone,
      "originAddress":originLocation.locationName,
      "destinantionAddress":destinationLocation.locationName,
      "driverId" : "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripRidesRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap)async{
      if(eventSnap.snapshot.value == null){
        return;
      }
      if((eventSnap.snapshot.value as Map)["car_details"] != null){
        setState(() {
          driverCardDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverPhone"] != null){
        setState(() {
          driverCardDetails = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverName"] != null){
        setState(() {
          driverCardDetails = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"] != null){
        setState(() {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverLocation"] != null){
        double driverCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        if(userRideRequestStatus == "accepted"){
          updateArrivalTimeToUserPickupLocation(driverCurentPositionLatLng);
        }

        if(userRideRequestStatus == "arrived"){
          setState(() {
            driverRideStatus = "Driver has arrived";
          });
        }

        if(userRideRequestStatus == "ontrip"){
          updateReachingTimeToUserDropOffLocation(driverCurentPositionLatLng);
        }

        if(userRideRequestStatus =="ended"){
          if((eventSnap.snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].tostring());

            // var response =
            // await showDialog(
            //     context: context,
            //     builder: (BuildContext context) => payFareAmountDialog(
            //       fareAmount: fareAmount,
            //     )
            // );
            //
            // if(response == "Cash Paid"){
            //   if((eventSnap.snapshot.value as Map)["driverId"] != null){
            //
            //     String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
            //     //Navigator.push(context, MaterialPageRoute(builder: (context) => RateDriverScreen()));
            //     referenceRideRequest!.onDisconnect();
            //     tripRidesRequestInfoStreamSubscription!.cancel();
            //
            //   }
            // }
          }
        }
      }

    });

    onlinNearbyAvailableDriversList = GeofireAssistant.activenearbyavailabledriversList;
    searchNearestOnlineDrivers(selectedVehicleType);

  }



  updateArrivalTimeToUserPickupLocation(driverCurentPositionLatLng) async{
    if(requestPositionInfo == true){
      requestPositionInfo = false;
      LatLng userPickupPosition = LatLng(userCurrentposition!.latitude, userCurrentposition!.longitude);
      
      var directionDetailsInfo = await AssistanntMethods.obtainOriginToDestinationDirectionDetails(
          driverCurentPositionLatLng, userPickupPosition);

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Driver is coming"+directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;

    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurentPositionLatLng)async{
    if(requestPositionInfo == true){
      requestPositionInfo = false;
      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropoffLocation;
      
      LatLng userDestinationPosition = LatLng(dropOffLocation!.locationLattitude!, dropOffLocation.locationLongitude!);

      var directionDetailsInfo = await AssistanntMethods.obtainOriginToDestinationDirectionDetails(
          driverCurentPositionLatLng, userDestinationPosition);

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Going towards Destination"+directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  searchNearestOnlineDrivers(String selectedVehicleType)async{
    if(onlinNearbyAvailableDriversList.length == 0) {
      referenceRideRequest!.remove();

      setState(() {
        polylineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinateList.clear();
      });

      Fluttertoast.showToast(
          msg: "No online nearest driver available...try again");

      Future.delayed(Duration(microseconds: 4000), () {
        referenceRideRequest!.remove();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      });
      return;
    }

    await retrieveOnlineDriversInformation(onlinNearbyAvailableDriversList);

    print("Driver List = "+dList.toString());

    for(int i=0;i<dList.length;i++){
      if(dList[i]["car_details"]["type"] == selectedVehicleType){
        AssistanntMethods.sendNotificationToDriverNow(dList[i]["token"],referenceRideRequest!.key!,context);
      }
    }

    Fluttertoast.showToast(msg: "Notification sent successfully");

    showSearchingForDriversContainer();
    
    await FirebaseDatabase.instance.ref().child("All Ride Request").child(referenceRideRequest!.key!).child("driverId").onValue.listen((eventRideRequestSnapshot){
      print("EentSnapshot: ${(eventRideRequestSnapshot.snapshot.value)}");
      if(eventRideRequestSnapshot.snapshot.value != null){
        if(eventRideRequestSnapshot.snapshot.value != "waiting"){
          showUIForAssignDriverInfo();
        }
      }
    });
  }

  retrieveOnlineDriversInformation(List onlinNearestAvailableDriversList)async{
    dList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for(int i=0;i<onlinNearestAvailableDriversList.length;i++){
      await ref.child(onlinNearestAvailableDriversList[i].driverId.toString()).once().then((dataSnapshot){
        var driverKeyInfo = dataSnapshot.snapshot.value;

        dList.add(driverKeyInfo);
        print("Driver key info = "+ dList.toString());
      });
    }
  }

  showUIForAssignDriverInfo(){
    setState(() {
      waittingResponsefromDriverContainerHeight = 0;
      searchingForDriverContainerHeight = 0;
      assignedDriverInfoContainerHeight = 0;
      bottomPaddingofMap = 200;
    });
  }

  void showSearchingForDriversContainer(){
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    checkIfLocationPermissionAllowed();

  }


  @override
  Widget build(BuildContext context) {

    createAciveNearbyDriverIconMarker();

    return  GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: _kGooglePlex,

              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,

              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController=controller;

                setState(() {

                });

                locateUserPosition();
              },

              onCameraMove: (CameraPosition? position){
                 if(pickLocation != position!.target){
                   setState(() {
                     iscammoving=true;
                     pickLocation = position.target;
                   });
                 }
               },

               onCameraIdle: (){

                setState(() {
                  iscammoving=false;
                });

                if(!dropoffobtained){
                  getAddressfromLatLng();
                }

               },
            ),

            !dropoffobtained?
            iscammoving?
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset("assets/locationh.png"),
              ),
            )
                :
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Image.asset("assets/locations.png"),
              ),
            )
                :

            Positioned(
              top: 50,
                left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: (){
                      _scaffoldState.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.menu,
                        color: Color.fromRGBO(28, 42, 58, 1),
                      ),
                    ),
                  ),
                )
            ),

            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child:Padding(
                  padding: EdgeInsets.fromLTRB(10,50,10,10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                width: 2,
                              color: Color.fromRGBO(28, 42, 58, 1)
                            )
                        ),

                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),

                              ),
                              child: Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.all(5),
                                    child: GestureDetector(
                                      onTap: () async {
                                        if(dropoffobtained){
                                        var responseFromSearchScreen = await Navigator.push(context,  MaterialPageRoute(builder: (c)=>PrecisePickupLocation()));

                                          if(responseFromSearchScreen == "obtainepickup"){
                                            setState(() {
                                              dropoffobtained = true;
                                              openNavigationDrawer = false;
                                            });
                                          }

                                          await drawPolyLineFromOriginToDestination();
                                        }

                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, color: Colors.blue,),
                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("PICKUP",
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,fontWeight: FontWeight.bold,
                                              ),
                                              ),
                                              Text(Provider.of<AppInfo>(context).userPickupLocation != null ?
                                              (Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0,24)+"..."
                                                  : "Not Getting Address",
                                                style: Provider.of<AppInfo>(context).userPickupLocation != null ?
                                                TextStyle(
                                                  color: Color.fromRGBO(28, 42, 58, 1),
                                                  fontSize: 16,fontWeight: FontWeight.bold,
                                                ):
                                                TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),

                                  ),

                                  SizedBox(height: 5,),

                                  Divider(height: 1,
                                  thickness: 2,
                                  color: Colors.orange,),

                                  SizedBox(height: 5,),

                                  Padding(padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: ()async{
                                      var responseFromSearchScreen = await Navigator.push(context,  MaterialPageRoute(builder: (c)=>SearchPlacesScreen()));

                                      if(responseFromSearchScreen == "obtaineDropoff"){

                                        setState(() {
                                          dropoffobtained = true;
                                          openNavigationDrawer = false;
                                        });

                                      }

                                      await drawPolyLineFromOriginToDestination();

                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, color: Colors.orange,),
                                        SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("DROP",
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 12,fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(Provider.of<AppInfo>(context).userDropoffLocation != null ?
                                            Provider.of<AppInfo>(context).userDropoffLocation!.locationName!
                                                : "Where to",
                                              style: Provider.of<AppInfo>(context).userDropoffLocation != null ?
                                              TextStyle(
                                                color: Color.fromRGBO(28, 42, 58, 1),
                                                fontSize: 16,fontWeight: FontWeight.bold,
                                              ):
                                              TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ElevatedButton(
                          //     onPressed: (){
                          //       Navigator.push(context, MaterialPageRoute(builder: (context) => PrecisePickupLocation()));
                          //     },
                          //     child: Text(
                          //       "Change Pick up",
                          //       style: TextStyle(
                          //         color: Colors.white
                          //       ),
                          //     ),
                          //
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.blue,
                          //     textStyle: TextStyle(
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 16,
                          //     ),
                          //   ),
                          // ),

                          SizedBox(width: 10,),

                          ElevatedButton(
                            onPressed: (){
                              if(Provider.of<AppInfo>(context,listen: false).userDropoffLocation != null){
                                showSugestedRidesContainer();
                              }
                              else{
                                Fluttertoast.showToast(msg: "Please Selcet Destination Places");
                              }
                            },
                            child: Text(
                              "Show fair",
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(28, 42, 58, 1),
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                        ],
                      )
                    ],
                  ),
                )
            ),

            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: suggestRideContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)
                    ),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(15),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.blue,),
                              SizedBox(width: 5,),
                              Text("PICKUP",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,fontWeight: FontWeight.bold,
                                ),
                              ),
                      
                              SizedBox(width: 20,),
                      
                              Text(Provider.of<AppInfo>(context).userPickupLocation != null ?
                              (Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0,24)+"..."
                                  : "Not Getting Address",
                                style: Provider.of<AppInfo>(context).userPickupLocation != null ?
                                TextStyle(
                                  color: Color.fromRGBO(28, 42, 58, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ):
                                TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: 5,),

                          Divider(height: 1,
                            thickness: 2,
                            color: Colors.blue,
                          ),

                          SizedBox(height: 5,),
                      
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.orange,),
                              SizedBox(width: 5,),
                              Text("DROP",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 15,fontWeight: FontWeight.bold,
                                ),
                              ),
                      
                              SizedBox(width: 20,),
                      
                              Text(Provider.of<AppInfo>(context).userDropoffLocation != null ?
                              (Provider.of<AppInfo>(context).userDropoffLocation!.locationName!): "Not Getting Address",
                                style: Provider.of<AppInfo>(context).userPickupLocation != null ?
                                TextStyle(
                                  color: Colors.orange,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )
                                    : TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                      
                          SizedBox(height: 20,),
                      
                          Text("SUGGESTED RIDES",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      
                          SizedBox(height: 5,),
                      
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedVehicleType = "car";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicleType == "car" ? Colors.blue:Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Image.asset("assets/car.png",scale: 8,),
                      
                                        Text("Car",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                        ),
                                        ),
                      
                                        SizedBox(height: 2),
                      
                                        Text(tripDirectionDetailsInfo != null ? "Rs. ${((AssistanntMethods.calculateFairAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2) *107).toStringAsFixed(1)}":"Fair Amounnt",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                        ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedVehicleType = "tuk";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicleType == "tuk" ? Colors.blue:Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Image.asset("assets/tuk.png",scale: 8,),
                      
                                        Text("Tuk",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                      
                                        SizedBox(height: 2),
                      
                                        Text(tripDirectionDetailsInfo != null ? "Rs. ${((AssistanntMethods.calculateFairAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 1) *107).toStringAsFixed(1)}":"Fair Amounnt",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedVehicleType = "lorry";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicleType == "lorry" ? Colors.blue:Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Image.asset("assets/lorry.png",scale: 8,),
                      
                                        Text("Lorry",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                      
                                        SizedBox(height: 2),
                      
                                        Text(tripDirectionDetailsInfo != null ? "Rs. ${((AssistanntMethods.calculateFairAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 5) *107).toStringAsFixed(1)}":"Fair Amounnt",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      
                      
                          SizedBox(height: 15,),
                      
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    selectedVehicleType = "van";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicleType == "van" ? Colors.blue:Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      children: [
                                        Image.asset("assets/van.png",scale: 8,),
                      
                                        Text("Van",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                          ),
                                        ),
                      
                                        SizedBox(height: 2),
                      
                                        Text(tripDirectionDetailsInfo != null ? "Rs. ${((AssistanntMethods.calculateFairAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 3.5) *107).toStringAsFixed(1)}":"Fair Amounnt",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]
                          ),
                      
                          SizedBox(height: 20,),
                      
                          ElevatedButton(
                            onPressed: (){
                              if(selectedVehicleType != ""){
                                saveRideRequestInformation(selectedVehicleType);
                              }
                              else{
                                Fluttertoast.showToast(msg: "Please select a vehicle");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Background color// Text color
                              shadowColor: Colors.black, // Shadow color
                              elevation: 5, // Elevation of the button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Center(
                              child: Text(
                                "Request a Ride",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),


                          SizedBox(height: 10,)
                        ],
                      ),
                    ),
                  ),
                ),
            ),

            // Positioned(
            //   top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(15)),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.all(20),
            //     child: Text(Provider.of<AppInfo>(context).userPickupLocation != null ?
            //     (Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0,24)+"..."
            //         : "Not Getting Address",
            //       overflow: TextOverflow.visible,softWrap: true,
            //     ),
            //   ),
            // )


          ],
        ),
      ),
    );
  }
}
