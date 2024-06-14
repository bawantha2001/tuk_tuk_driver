import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuk_tuk_project_driver/screens/car_info_screen.dart';
import 'package:image_picker/image_picker.dart';


import '../widgets/progress_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key,required this.phoneNumber,required this.currentUser});
  final String phoneNumber;
  final User? currentUser;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameTextEdittingcont = TextEditingController();
  final emailTextEdittingcont = TextEditingController();
  File? _image;


  final _formkey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submit() async{

    if(_formkey.currentState!.validate()){
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => ProgressDialog()
      );

        if(widget.currentUser!=null){
          Map userMap={
            "id":widget.currentUser!.uid,
            "name":nameTextEdittingcont.text.trim(),
            "email":emailTextEdittingcont.text.trim(),
            "phone":widget.phoneNumber,
          };

          DatabaseReference userRef=FirebaseDatabase.instance.ref().child("drivers");

          userRef.child(widget.currentUser!.uid).set(userMap).then((onValue) async {

            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Successfully Registered");
            Navigator.push(context, MaterialPageRoute(builder: (c) => CarInfoScreen(currentUser: widget.currentUser,)));

          }).catchError((error){

            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Error ocured : $error");

          });
        }

    }
    else{
      Fluttertoast.showToast(msg: "Not all field are valid");
    }

  }



  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
                  Image.asset("assets/logo.jpg",),
                  SizedBox(height: 20,),
                  Text(
                    'Add Your Details',
                    style: TextStyle(
                      color: Color.fromRGBO(28, 42, 58, 1),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(15,20,15,50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formkey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Your Full Name',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[700]
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

                                  prefixIcon: Icon(Icons.person,color: Colors.grey,),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text){
                                  if(text==null || text.isEmpty){
                                    return 'Name can\'t be empty';
                                  }
                                  if(text.length<2){
                                    return 'Please enter a valid Name';
                                  }
                                  if(text.length>50){
                                    return 'Name can\'t be more than 50';
                                  }
                                },
                                onChanged: (text)=>setState(() {
                                  nameTextEdittingcont.text=text;
                                }),
                              ),

                              SizedBox(height: 15,),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'NIC Number',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[700]
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

                                  prefixIcon: Icon(Icons.credit_card,color: Colors.grey,),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text){
                                  if(text==null || text.isEmpty){
                                    return 'NIC can\'t be empty';
                                  }
                                  if(text.length<2){
                                    return 'Please enter a valid NIC';
                                  }
                                  if(text.length>50){
                                    return 'Name can\'t be more than 12';
                                  }
                                },
                                onChanged: (text)=>setState(() {
                                  nameTextEdittingcont.text=text;
                                }),
                              ),

                              SizedBox(height: 15,),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'License Number',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[700]
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

                                  prefixIcon: Icon(Icons.numbers_sharp,color: Colors.grey,),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text){
                                  if(text==null || text.isEmpty){
                                    return 'License can\'t be empty';
                                  }
                                  if(text.length<2){
                                    return 'Please enter a valid License';
                                  }
                                  if(text.length>50){
                                    return 'License can\'t be more than 15';
                                  }
                                },
                                onChanged: (text)=>setState(() {
                                  nameTextEdittingcont.text=text;
                                }),
                              ),

                              SizedBox(height: 15,),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Contact Number',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[700]
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

                                  prefixIcon: Icon(Icons.phone,color: Colors.grey,),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text){
                                  if(text==null || text.isEmpty){
                                    return 'contact can\'t be empty';
                                  }
                                  if(text.length<2){
                                    return 'contact enter a valid Name';
                                  }
                                  if(text.length>50){
                                    return 'contact can\'t be more than 10';
                                  }
                                },
                                onChanged: (text)=>setState(() {
                                  nameTextEdittingcont.text=text;
                                }),
                              ),

                              SizedBox(height: 15,),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                      color: Colors.grey[700]
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
                                  prefixIcon: Icon(Icons.email,color: Colors.grey,),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text){
                                  if(text==null || text.isEmpty){
                                    return 'Email can\'t be empty';
                                  }

                                  if(EmailValidator.validate(text)==true){
                                    return null;
                                  }
                                  if(text.length<2){
                                    return 'Please enter a valid Email';
                                  }
                                  if(text.length>90){
                                    return 'Email can\'t be more than 90';
                                  }
                                },
                                onChanged: (text)=>setState(() {
                                  emailTextEdittingcont.text=text;
                                }),
                              ),

                              SizedBox(height: 15,),

                              GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.image, color: Colors.grey),
                                      SizedBox(width: 10),
                                      Text(
                                        _image == null ? 'Front side of License' : 'Image Selected',
                                        style: TextStyle(color: Colors.grey[700],fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 15,),

                              GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.image, color: Colors.grey),
                                      SizedBox(width: 10),
                                      Text(
                                        _image == null ? 'Rear side of License' : 'Image Selected',
                                        style: TextStyle(color: Colors.grey[700],fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
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
                                'Finish',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white
                                ),
                              )),

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
