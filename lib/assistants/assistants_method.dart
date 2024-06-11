import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuk_tuk_project_driver/assistants/request_assistant.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/global/map_key.dart';
import 'package:tuk_tuk_project_driver/infoHandler/App_info.dart';
import 'package:tuk_tuk_project_driver/models/directions.dart';
import 'package:tuk_tuk_project_driver/models/trips_history_model.dart';
import 'package:tuk_tuk_project_driver/models/user_models.dart';
import 'package:http/http.dart' as http;
import '../models/direction_details_info.dart';


class AssistanntMethods{

  static void readCurrentOnlineUserInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef=FirebaseDatabase.instance
    .ref()
    .child("Driver_info")
    .child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value!=null){
        userModelCurrrentInfo = usermodel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressGeographicCoordinates(Position position, context) async{

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.recieveRequest(apiUrl);


    if(requestResponse != "Error Occured : failed No Responce"){

      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLattitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context,listen: false).updatePickuplocationAddress(userPickupAddress);

    }

    return humanReadableAddress;
  }



  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng origingPosition,LatLng destinationPosition) async{

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${origingPosition.latitude},${origingPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responceDirectionApi = await RequestAssistant.recieveRequest(urlOriginToDestinationDirectionDetails);

    // if(responceDirectionApi == "Error Occured : failed No Responce"){
    //   return null;
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responceDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responceDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responceDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responceDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responceDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static pauseLiveLocationupdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(firebaseAuth.currentUser!.uid);
  }


  static double calculateFairAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double timetravelFairAmountPerMinute = (directionDetailsInfo.duration_value!/60)*0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value!/1000)*0.1;

    double totalFareAmount = timetravelFairAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double localCurrencyTotalFare=totalFareAmount*100;

    //return double.parse(totalFareAmount.toStringAsFixed(1));

    if(driverVehicleType=="Bike"){
      double resultFareAmount=(localCurrencyTotalFare.truncate()*0.8);
      return resultFareAmount;
    }
    if(driverVehicleType=="Car"){
      double resultFareAmount=(localCurrencyTotalFare.truncate()*1.5);
      return resultFareAmount;

    }
    if(driverVehicleType=="Threewheeler"){
      double resultFareAmount=(localCurrencyTotalFare.truncate()*1);
      return resultFareAmount;
    }
    else{
      return localCurrencyTotalFare.truncate().toDouble();
    }
  }

  static void readTripsKeysForOnlineDrivers(context){
    FirebaseDatabase.instance.ref().child("All Ride requests").orderByChild("driverId").equalTo(firebaseAuth.currentUser!.uid).once().then((snap){
      if(snap.snapshot.value==null){
        Map keysTripsId=snap.snapshot.value as Map;

        int overAllTripsCounter=keysTripsId.length;
        Provider.of<AppInfo>(context,listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        List<String> tripsKeysList=[];
        keysTripsId.forEach((key,value){
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context,listen: false).updateOverAllTripsKeys(tripsKeysList);
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context){
    var tripsAllKeys=Provider.of<AppInfo>(context,listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((snap){
        var eachTripHistory=TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"]=="ended"){
          Provider.of<AppInfo>(context,listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);

        }
      });
    }
  }


  static void readDriverEarnings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
        if((snap.snapshot.value!=null)){
          String driverEarnings=snap.snapshot.value.toString();
          Provider.of<AppInfo>(context,listen: false).updateDriverTotalEarnings(driverEarnings);

        }
    });

    readTripsKeysForOnlineDrivers(context);
  }

  static void readDriverRatings(context){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("ratings").once().then((snap){
      if((snap.snapshot.value!=null)){
        String driverRatings=snap.snapshot.value.toString();
        Provider.of<AppInfo>(context,listen: false).updateDriverAverageRatings(driverRatings);

      }
    });
  }


  static sendNotificationToDriverNow(String deviceRegostrationToken, String userRideRequestId, context)async{
    // String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      "Cintent Type":"application/json",
      "Authorization": cloudMessaginServerToken,

    };

    Map bodyNotification ={
      // "body" : "Destination Address: \n$destinationAddress.",
      "title": "New Trip Request"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat ={
      "notification" : bodyNotification,
      "date" : dataMap,
      "priority" : "high",
      "to" : deviceRegostrationToken,
    };

    var responceNotification = http.post(
      
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat)
    );

  }



}