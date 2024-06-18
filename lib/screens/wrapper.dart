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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Main_screen()));
        }
        else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      });
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitThreeBounce(
              color: Color.fromRGBO(28, 42, 58, 1),
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}