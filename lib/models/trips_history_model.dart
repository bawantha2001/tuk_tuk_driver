import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? userName;
  String? userPhone;


  TripsHistoryModel({
   this.time,
   this.originAddress,
   this.destinationAddress,
   this.status,
   this.fareAmount,
   this.userName,
   this.userPhone,
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot snapshot){
    time=(snapshot.value as Map)['time'];
    originAddress=(snapshot.value as Map)['originAddress'];
    destinationAddress=(snapshot.value as Map)['destinationAddress'];
    status=(snapshot.value as Map)['status'];
    fareAmount=(snapshot.value as Map)['fareAmount'];
    userName=(snapshot.value as Map)['userName'];
    userPhone=(snapshot.value as Map)['userPhone'];
  }
}