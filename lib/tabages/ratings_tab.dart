import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../infoHandler/App_info.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/star.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({super.key});

  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {

  double ratingNumber = 4;
  String titleStarsRating = "Excellent"; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    getRatingNumber(); // Call getRatingNumber in initState to initialize the rating
  }

  getRatingNumber() {
    setState(() {
      ratingNumber = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });

    setupRatingsTitle();
  }

  setupRatingsTitle() {
    if (ratingNumber >= 4) {
      setState(() {
        titleStarsRating = "Excellent";
      });
    } else if (ratingNumber >= 3) {
      setState(() {
        titleStarsRating = "Very Good";
      });
    } else if (ratingNumber >= 2) {
      setState(() {
        titleStarsRating = "Good";
      });
    } else if (ratingNumber >= 1) {
      setState(() {
        titleStarsRating = "Bad";
      });
    } else {
      setState(() {
        titleStarsRating = "Very Bad";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the scaffold background transparent
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 255, 1, 1), // Start color (yellow)
              Color.fromRGBO(255, 255, 255, 1), // End color (white)
            ],
          ),
        ),
        child: Center(
          child: Dialog(
            backgroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(4),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Your Rating",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  RatingBar.builder(
                    initialRating: ratingNumber,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0), // Adjust the horizontal padding as needed
                      child: CustomPaint(
                        size: Size(40, 40),
                        painter: StarPainter(
                          color: Colors.amber,
                          borderColor: Colors.black,
                          filled: true,
                        ),
                      ),
                    ),
                    onRatingUpdate: (double value) {
                      setState(() {
                        ratingNumber = value;
                        setupRatingsTitle(); // Update the title based on the new rating
                      });
                    },
                  ),                  SizedBox(height: 20),
                  Text(
                    titleStarsRating,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
