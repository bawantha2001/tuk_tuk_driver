import 'package:flutter/cupertino.dart';
import 'package:tuk_tuk_project_driver/models/directions.dart';

class AppInfo extends ChangeNotifier{

  Directions? userPickupLocation, userDropoffLocation;
  int countTotalTrips=0;
  List<String> historyTripsKeysList = [];
  // List<TripHistoryModel> allTripHistoryInformationModelList = [];

  void updatePickuplocationAddress(Directions userPickupAddress){
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropofflocationAddress(Directions userDropoffAddress){
    userDropoffLocation = userDropoffAddress;
    notifyListeners();
  }

}