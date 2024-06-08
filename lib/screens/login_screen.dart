import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tuk_tuk_project_driver/screens/forgot_screen.dart';
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
            color: Color.fromRGBO(226, 227, 225, 1)
          ),
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Image.asset("assets/tukReg.jpg",),
                  SizedBox(height: 20,),
                  Text(
                    'Add Your Phone Number',
                    style: TextStyle(
                      color: Color.fromRGBO(28, 42, 58, 1),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 5,),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(15,20,15,50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Enter your phone number in oder to send your OTP security code.',
                          style: TextStyle(
                            color: Color.fromRGBO(28, 42, 58, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15,),

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
                                      backgroundColor: Color.fromRGBO(28, 42, 58, 1),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      minimumSize: Size(double.infinity, 50)
                                  ),
                                  onPressed: (){
                                    _submit();
                                  }, child: Text(
                                'Next Step',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white
                                ),
                              )),

                              SizedBox(height: 10),

                              SizedBox(height: 10),
                              Text(
                                'I accept the',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15
                                ),
                              ),

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
