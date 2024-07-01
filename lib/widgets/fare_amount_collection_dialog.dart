import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(10),
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10,),

              Text(
                "Fair Amount".toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),

              SizedBox(height: 5,),

              Divider(
                thickness: 2,
                color: Colors.white,
              ),

              SizedBox(height: 10,),

              Text(
                "Total Distance - "+widget.totalFareAmount.toString()+" Km",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),

              SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.all(10),
                child: Text("Please collect the corresponding amount according to the Total Distance from the passenger.",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 10),

              Padding(
                  padding:EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: (){
                        Restart.restartApp();
                    },

                    child:Text("Collect Cash",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 20
                      ),
                    ),
                    ),
                  ),

            ],
          ),
        ),
      ),
    );
  }
}
