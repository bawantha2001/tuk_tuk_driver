import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tuk_tuk_project_driver/screens/forgot_screen.dart';
import 'package:tuk_tuk_project_driver/screens/main_screen.dart';
import '../widgets/progress_dialog.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final phoneTextEdittingcont = TextEditingController();
  final passwordTextEdittingcont = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  void _submit() async{

    if(_formkey.currentState!.validate()){
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => ProgressDialog()
      );

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> Main_screen()));

      }
      else {
        // No user is signed in
        Fluttertoast.showToast(msg: "User is not signed in");
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneTextEdittingcont.text.trim(),
            verificationCompleted:(PhoneAuthCredential credentials){
            },

            verificationFailed: (error){
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Error Ocured : $error");
              print("Error Ocured : $error");
            },

            codeSent: (verifcationId, forceResendingToken){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c)=> ForgotPasswordScreen(verificationId: verifcationId,phoneNumber: phoneTextEdittingcont.text.trim(),)));
            },

            codeAutoRetrievalTimeout: (error){
              Fluttertoast.showToast(msg: "Time out");
            });

      }


    }
    else{
      Fluttertoast.showToast(msg: "Not all field are valid");
    }

  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(255, 255, 1, 100), Color.fromRGBO(255, 255, 255, 1)], // Replace with your preferred colors
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50,bottom: 60),
                    child: Image.asset('assets/logo2.png'),
                  ),
                  SizedBox(height: 20,),
                  Text(
                    ' Your Phone Number',
                    style: TextStyle(
                      fontFamily: 'Poppins', // Use your custom font
                      fontSize: 25,
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

                  SizedBox(height: 20,),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(15,20,15,50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Enter your phone number to send your OTP .',
                          style: TextStyle(
                            color: Color.fromRGBO(28, 42, 58, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 35,),

                        Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              IntlPhoneField(
                                keyboardType: TextInputType.phone,
                                initialCountryCode: 'LK',
                                dropdownIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  hintStyle: TextStyle(
                                      color: Colors.grey
                                  ),

                                  filled: true,
                                  fillColor:Colors.grey.shade200,

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1), // Set the color you want for the enabled border
                                      width: 2.0,
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1), // Set the color you want for the focused border
                                      width: 2.0,
                                    ),
                                  ),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.solid,
                                    ),
                                  ),

                                ),
                                onChanged: (text)=>setState(() {
                                  phoneTextEdittingcont.text=text.completeNumber;
                                }),
                              ),


                              SizedBox(height: 40,),

                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromRGBO(252, 240, 1, 85),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      side: BorderSide(
                                        color: Color.fromRGBO(28, 42, 58, 1), // Change this to your preferred border color
                                        width: 1, // Change this to your preferred border width
                                      ),
                                    ),
                                    minimumSize: Size(200, 50),
                                  ),
                                  onPressed: (){
                                    _submit();
                                  }, child: Text(
                                'Next Step',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black
                                ),
                              )),

                              SizedBox(height: 10),

                              // SizedBox(height: 10),
                              // Text(
                              //   'I accept the',
                              //   style: TextStyle(
                              //       color: Colors.grey,
                              //       fontSize: 15
                              //   ),
                              // ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
