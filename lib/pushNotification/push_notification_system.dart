import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:tuk_tuk_project_driver/models/user_ride_request_information.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuk_tuk_project_driver/pushNotification/notification_dialog_box.dart';
import '../assistants/assistants_method.dart';
import '../screens/new_trip_screen.dart';



class PushNotifcationSystem{
  late StreamSubscription<DatabaseEvent> rideRequestSubscription;
  FirebaseMessaging messaging=FirebaseMessaging.instance;


  Future initializeCloudMessging(BuildContext context) async{

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
        {
          if(remoteMessage!=null){
            readUserRideRequestInformation(remoteMessage.data["rideRequestId"],context);
          }
        }
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage)
    {
        readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],context);
    }
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage)
    {
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    }
    );
  }

   readUserRideRequestInformation(String userRideRequestId,BuildContext context) {

     rideRequestSubscription = FirebaseDatabase.instance.ref().child("All Ride Request").child(userRideRequestId).child("driverId").onValue.listen((event){

      if(event.snapshot.value=="waiting"){

        FirebaseDatabase.instance.ref().child("All Ride Request").child(userRideRequestId).once().then((snapData)
        async {
          if(snapData.snapshot.value!=null)
          {
            audioPlayer.open(Audio("assets/music_notification.mp3"));
            audioPlayer.play();

            double originLat=double.parse((snapData.snapshot.value!as Map)["origin"]["latitude"]);
            double originLng=double.parse((snapData.snapshot.value!as Map)["origin"]["longitude"]);
            String originAddress=(snapData.snapshot.value!as Map)["originAddress"];

            double destinationLat=double.parse((snapData.snapshot.value!as Map)["destination"]["latitude"]);
            double destinationLng=double.parse((snapData.snapshot.value!as Map)["destination"]["longitude"]);
            String destinationAddress=(snapData.snapshot.value!as Map)["destinantionAddress"];

            String userName=(snapData.snapshot.value!as Map)["userName"];
            String userPhone=(snapData.snapshot.value!as Map)["userphone"];

            String?rideRequestId=snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails=UserRideRequestInformation();
            userRideRequestDetails.originLatlng=LatLng(originLat,originLng);
            userRideRequestDetails.originAddress=originAddress;
            userRideRequestDetails.destinationLatlng=LatLng(destinationLat, destinationLng);
            userRideRequestDetails.destinationAddress=destinationAddress;
            userRideRequestDetails.userName=userName;
            userRideRequestDetails.userPhone=userPhone;
            userRideRequestDetails.rideRequestId=rideRequestId;



            var response = await showDialog(
                context: context,
                builder: (BuildContext context)=>NotificationDialogBox(userRideRequestDetails: userRideRequestDetails,)
            );

            if(response =="accepted"){
              rideRequestSubscription.cancel();
              acceptRideRequest(context, userRideRequestDetails);
            }
            else{
              rideRequestSubscription.cancel();
            }

          }
          else{
            Fluttertoast.showToast(msg:"This Ride Request Id do not exists.");
          }
        });
      }
      else{
        rideRequestSubscription.cancel();
        Fluttertoast.showToast(msg:"This Ride Request has been cancelled.");
        Navigator.pop(context);
      }
    });
  }

  Future generatenadGetToken() async{
    String? registrationToken=await messaging.getToken();
    print("FCM registration token:${registrationToken}");
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("token")
        .set(registrationToken);
    
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
    
  }

  acceptRideRequest(BuildContext context,UserRideRequestInformation? userRideRequestDetails){
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value=="idle"){
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("accepted");
        AssistanntMethods.pauseLiveLocationupdates();
        Navigator.push(context,MaterialPageRoute(builder: (context)=>NewTripScreen(userRideRequestDetails: userRideRequestDetails)));
      }
      else{
        Fluttertoast.showToast(msg: "Ride request does not exist");
      }
    });
  }

}

