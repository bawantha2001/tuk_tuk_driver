import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:tuk_tuk_project_driver/screens/register_screen.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key,required this.verificationId,required this.phoneNumber});
  final String phoneNumber;
  final String verificationId;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final otpTextEdittingcont = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  void _submit() async{
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog()
    );

    try{
      final cred = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otpTextEdittingcont.text.trim());

      await firebaseAuth.signInWithCredential(cred).then((onValue){
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=> RegisterScreen(phoneNumber: widget.phoneNumber, currentUser: onValue.user)));
      }).catchError((error){
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Error Ocured : $error");
      });

    }catch(error){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error Ocured : $error");
    }

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  Image.asset("assets/logo.jpg",),
                  SizedBox(height: 20,),
                  Text(
                    'Enter The Veryfication Code',
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
                          'Enter the 6 digit number that we send to ${widget.phoneNumber}.',
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
                              Pinput(
                                defaultPinTheme: PinTheme(
                                    width: 50,
                                    height: 50,
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                    ),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 2.0,
                                      color: Color.fromRGBO(28, 42, 58, 1)
                                    )
                                  )
                                ),
                                length: 6,
                                onChanged: (text)=>setState(() {
                                  otpTextEdittingcont.text=text;
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
                              Text(
                                'Didn\'t Recieved Anything?',
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

