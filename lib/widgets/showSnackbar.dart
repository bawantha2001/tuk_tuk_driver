import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Showsnackbar{

  static void showSnackbar(String title,String errorMessage){
    Get.snackbar(
      title,
      errorMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      icon: Icon(Icons.error,color: Colors.white,),
      shouldIconPulse: true,
    );
  }

  static void showsuccessSnackbar(String title,String errorMessage){

    Get.snackbar(
      title,
      errorMessage,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      icon: Icon(Icons.credit_score,color: Colors.white,),
      shouldIconPulse: true,
    );
  }
}