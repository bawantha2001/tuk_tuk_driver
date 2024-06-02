import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/assistants/request_assistant.dart';
import 'package:tuk_tuk_project_driver/global/map_key.dart';
import 'package:tuk_tuk_project_driver/models/predicted_places.dart';
import 'package:tuk_tuk_project_driver/widgets/place_prediction_title.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placesPredictedList = [];

  findplaceAutoCompleteSearch(String inputText)async{
    if(inputText.length>1){
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:LK";

      var responseAutoCompleteSearch = await RequestAssistant.recieveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error Occured : failed No Responce"){
        return;
      }

      if(responseAutoCompleteSearch["status"] == "OK"){
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child:Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white,),
          ),
          title: Text(
            "Search & Set dropoff location",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0.0,
        ),

        body: Column(
          children: [
            Container(
              decoration:BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 5,
                    offset: Offset(
                      0.7,0.7
                    )
                  )
                ]
              ),
              
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.adjust_sharp,
                          color: Colors.white,
                        ),

                        SizedBox(height: 10.0,),

                        Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: TextField(
                                onChanged: (value){
                                  findplaceAutoCompleteSearch(value);
                                },
                                decoration: InputDecoration(
                                  hintText: "Search your drop-off location here ",fillColor: Colors.white54,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    left: 11,
                                    top: 0,
                                    bottom: 0
                                  )
                                ),
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),

            (placesPredictedList.length>0)?Expanded(
                child: ListView.separated(
                  itemCount: placesPredictedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index){
                    return PlacePredictionTitleDesign(
                      predictedPlaces: placesPredictedList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index){
                    return Divider(
                      height: 0,
                      color: Colors.blue,
                      thickness: 0,
                    );
                  },
                ),
            ): Container(),
          ],
        ),
      ),
    );
  }
}
