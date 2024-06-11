import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10,),

            Text(
              "Trip Fare Amount",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            Text(
              "Rs."+widget.totalFareAmount.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 50,
              ),
            ),

            SizedBox(height: 10),

            Padding(
                padding:EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  onPressed: (){
                    Future.delayed(Duration(milliseconds: 2000),(){
                      Navigator.push(context,MaterialPageRoute(builder: (c)=>LoginScreen()));
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Collect Cash",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Rs."+widget.totalFareAmount.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 50,
                        ),
                      ),
                    ],
                  ),
                ),
            ),

          ],
        ),
      ),
    );
  }
}
