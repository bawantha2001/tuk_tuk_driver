import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation{

  LatLng? originLatlng;
  LatLng? destinationLatlng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;


  UserRideRequestInformation(
  {
    this.originLatlng,
    this.destinationLatlng,
    this.originAddress,
    this.destinationAddress,
    this.rideRequestId,
    this.userName,
    this.userPhone,

  });
}