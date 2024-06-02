import '../models/ActiveNearbyAvailableDrivers.dart';

class GeofireAssistant {

  static List<Activenearbyavailabledrivers> activenearbyavailabledriversList = [];

  static void deleteofflineDriverFromList (String driverId){
    int indexNumber = activenearbyavailabledriversList.indexWhere((element) => element.driverId == driverId);
    
    activenearbyavailabledriversList.removeAt(indexNumber);
  }

  static void updateActiveNearByAvailableDriverLocation(Activenearbyavailabledrivers driverWhoMove){
    int indexNumber = activenearbyavailabledriversList.indexWhere((element) => element.driverId == driverWhoMove.driverId);

    activenearbyavailabledriversList[indexNumber].locationLattitude = driverWhoMove.locationLattitude;
    activenearbyavailabledriversList[indexNumber].locationLongitude = driverWhoMove.locationLongitude;


  }


}