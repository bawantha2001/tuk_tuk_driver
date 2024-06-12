import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';

import '../infoHandler/App_info.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 40,),
          Container(
            color: Colors.white,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text("Your Earnings",
                    style: TextStyle(
                        color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10,),

                  Text(
                   "\ Rs."+Provider.of<AppInfo>(context,listen: false).driverTotalEarnings,
                    style:TextStyle(
                      color: Colors.black,
                      fontSize: 60,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            width: 400,
            child: ElevatedButton(
                onPressed: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (c)=>TripHistoryScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                ),
                child: Padding(
                  padding:EdgeInsets.symmetric(horizontal: 20,vertical: 20) ,
                  child: Row(
                    children: [
                      Image.asset(
                        onlineDriverData.car_type=="car"?"assets/car.png"
                            :onlineDriverData.car_type=="Threewheeler"?"assets/tuk.png"
                            :onlineDriverData.car_type=="van"?"assets/van.png"
                            :"assets/lorry.png",
                        scale: 4,
                      ),

                      SizedBox(width: 10,),

                      Text(
                        "Trips Completed",
                        style: TextStyle(
                            color: Colors.black,
                          fontSize: 20
                        ),
                      ),

                      Expanded(
                          child: Container(
                            child: Text(
                              Provider.of<AppInfo>(context,listen: false).allTripsHistoryInformationList.length.toString(),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),

                            ),
                          )
                      )
                    ],
                  ),
                )
            )
            ,
          )

        ],
      ),
    );
  }
}
