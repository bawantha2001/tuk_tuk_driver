import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tuk_tuk_project_driver/assistants/request_assistant.dart';
import 'package:tuk_tuk_project_driver/global/map_key.dart';
import 'package:tuk_tuk_project_driver/infoHandler/App_info.dart';
import 'package:tuk_tuk_project_driver/models/directions.dart';
import 'package:tuk_tuk_project_driver/models/predicted_places.dart';
import 'package:tuk_tuk_project_driver/widgets/progress_dialog.dart';

import '../global/global.dart';
class PlacePredictionTitleDesign extends StatefulWidget {

  final PredictedPlaces? predictedPlaces;

  PlacePredictionTitleDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTitleDesign> createState() => _PlacePredictionTitleDesignState();
}

class _PlacePredictionTitleDesignState extends State<PlacePredictionTitleDesign> {


  getPlaceDirectionDetails(String placeId,context) async{
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog()
    );

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.recieveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if(responseApi == "Error Occured : failed No Responce"){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLattitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropofflocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context,"obtaineDropoff");

    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        getPlaceDirectionDetails(widget.predictedPlaces!.place_id!, context);
      },
      child: SizedBox(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.add_location,color: Colors.blue,),

              SizedBox(width: 10,),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue
                    ),
                  ),

                  Text(
                    widget.predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
