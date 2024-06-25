import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';
import 'package:tuk_tuk_project_driver/screens/main_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../assistants/assistants_method.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  void initState() {
      AssistanntMethods.isLogedIn().then((onValue){
        if(onValue){

          Future.delayed(Duration(milliseconds: 3000),(){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main_screen()));
          });
        }
        else{
          Future.delayed(Duration(milliseconds: 3000),(){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          });
        }
      });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(255, 255, 1, 100), Color.fromRGBO(255, 255, 255, 1)], // Replace with your preferred colors
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(5),
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50,bottom: 60),
                    child: Image.asset('assets/logo2.png'),
                  ),
                ),

                SizedBox(height: 50,),
                SpinKitThreeBounce(
                  color: Color.fromRGBO(28, 42, 58, 1),
                  size: 20.0,
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}