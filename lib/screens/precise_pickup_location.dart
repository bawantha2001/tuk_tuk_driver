import 'dart:async';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../assistants/assistants_method.dart';
import '../global/map_key.dart';
import '../infoHandler/App_info.dart';
import '../models/directions.dart';
import '../widgets/progress_dialog.dart';

class PrecisePickupLocation extends StatefulWidget {
  const PrecisePickupLocation({super.key});

  @override
  State<PrecisePickupLocation> createState() => _PrecisePickupLocationState();
}

class _PrecisePickupLocationState extends State<PrecisePickupLocation> {

  LatLng? pickLocation;
  loc.Location location=loc.Location();
  String? _address;
  bool iscammoving = false;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  Position? userCurrentposition;
  double bottomPaddingofMap=100;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  locateUserPosition() async{
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog()
    );

    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentposition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentposition!.latitude, userCurrentposition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadabaleAddress = await AssistanntMethods.searchAddressGeographicCoordinates(userCurrentposition!, context);

    Navigator.pop(context);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
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

               getAddressfromLatLng();
             },
          ),

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
          ),

          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20),
              child: Text(Provider.of<AppInfo>(context).userPickupLocation != null ?
              (Provider.of<AppInfo>(context).userPickupLocation!.locationName!)
                  : "Not Getting Address",
                overflow: TextOverflow.visible,softWrap: true,
              ),
            ),
          ),
          
          Positioned(
            bottom: 0,
              left: 0,
              right: 0,
              child:
              Padding(
                padding: EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context,"obtainepickup");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text("Set Current Location",
                      style:TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white
                  ),),
                ),
              ),
          )
        ],
      ),
    );
  }
}
