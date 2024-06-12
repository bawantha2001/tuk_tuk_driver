import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../infoHandler/App_info.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({super.key});

  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {

  double ratingNumber=0;

  @override
  void intiState(){
    super.initState();
  }

  getRatingNumber(){
    setState(() {
      ratingNumber=double.parse(Provider.of<AppInfo>(context,listen:false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle(){
    if(ratingNumber>=0){
      setState(() {
        titleStarsRating="Very Bad";
      });
    }
    else if(ratingNumber>=1){
      setState(() {
        titleStarsRating=" Bad";
      });
    }
    else if(ratingNumber>=2){
      setState(() {
        titleStarsRating="Good";
      });
    }
    else if(ratingNumber>=3){
      setState(() {
        titleStarsRating="Very Good";
      });
    }
    else if(ratingNumber>=4){
      setState(() {
        titleStarsRating="Excellent";
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20,),

              Text(
                "Your Rating",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.black
                ),
              ),

              SizedBox(height: 20,),

              // SmoothStarRating(
              //   rating:ratingNumber,
              //   allowHalfRating:true,
              //   starCount:5,
              //   color:Colors.blue,
              //   borderColor:Colors.blue,
              //   size:46
              // ),

              SizedBox(height: 20,),

              Text(
                titleStarsRating!,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 20,),



            ],
          ),
        ),
      ),
    );
  }
}
