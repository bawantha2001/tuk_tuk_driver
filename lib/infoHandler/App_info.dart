import 'package:flutter/cupertino.dart';
import 'package:tuk_tuk_project_driver/models/directions.dart';
import 'package:tuk_tuk_project_driver/models/trips_history_model.dart';

class AppInfo extends ChangeNotifier{

  Directions? userPickupLocation, userDropoffLocation;
  int countTotalTrips=0;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];
  String driverTotalEarnings="0";
  String driverAverageRatings="0";



  void updatePickuplocationAddress(Directions userPickupAddress){
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropofflocationAddress(Directions userDropoffAddress){
    userDropoffLocation = userDropoffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter){
    countTotalTrips=overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeysList){
    historyTripsKeysList=tripsKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory){
    allTripsHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }

  updateDriverTotalEarnings(String driverEarnings){
    driverTotalEarnings=driverEarnings;
  }

  updateDriverAverageRatings(String driverRatings){
    driverAverageRatings=driverRatings;
  }

}