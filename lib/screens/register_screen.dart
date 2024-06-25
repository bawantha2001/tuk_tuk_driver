import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuk_tuk_project_driver/screens/car_info_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/progress_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.phoneNumber, required this.currentUser});
  final String phoneNumber;
  final User? currentUser;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEdittingcont = TextEditingController();
  final emailTextEdittingcont = TextEditingController();
  final nicTextEdittingcont = TextEditingController();
  final licenseTextEdittingcont = TextEditingController();
  File? _frontImage;
  File? _rearImage;
  File? _profilePhoto;

  final _formkey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source, {bool isProfile = false, bool isFront = false}) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profilePhoto = File(pickedFile.path);
        } else if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _rearImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      final storageRef = FirebaseStorage.instanceFor(bucket: "gs://tuk-tuk-project-f640b").ref();
      final imagesRef = storageRef.child(path);
      await imagesRef.putFile(imageFile);
      final downloadUrl = await imagesRef.getDownloadURL();
      print('Upload complete! Image URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      Fluttertoast.showToast(msg: "Error uploading image: $e");
      return null;
    }
  }

  void _submit() async {
    if (_formkey.currentState!.validate()) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(),
      );

      try {
        if (widget.currentUser != null) {
          String? frontImageUrl;
          String? rearImageUrl;
          String? profilePhotoUrl;

          if (_frontImage != null) {
            frontImageUrl = await _uploadImage(_frontImage!, "drivers/${widget.currentUser!.uid}/front_license.jpg");
          }

          if (_rearImage != null) {
            rearImageUrl = await _uploadImage(_rearImage!, "drivers/${widget.currentUser!.uid}/rear_license.jpg");
          }

          if (_profilePhoto != null) {
            profilePhotoUrl = await _uploadImage(_profilePhoto!, "drivers/${widget.currentUser!.uid}/profile_photo.jpg");
          }

          Map<String, dynamic> userMap = {
            "id": widget.currentUser!.uid,
            "name": nameTextEdittingcont.text.trim(),
            "email": emailTextEdittingcont.text.trim(),
            "phone": widget.phoneNumber,
            "nic": nicTextEdittingcont.text.trim(),
            "license": licenseTextEdittingcont.text.trim(),
            "profile_photo_url": profilePhotoUrl,
            "front_license_url": frontImageUrl,
            "rear_license_url": rearImageUrl,
            "status" : "inactive"
          };

          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

          await userRef.child(widget.currentUser!.uid).set(userMap);

          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Successfully Registered");
          Navigator.push(context, MaterialPageRoute(builder: (c) => CarInfoScreen(currentUser: widget.currentUser)));
        }
      } catch (error) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Error occurred: $error");
      }
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;


    return GestureDetector(
      onTap: () {
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
                    padding: const EdgeInsets.only(top: 40,bottom: 10),
                    child: Image.asset('assets/logo2.png'),
                  ),                  SizedBox(height: 20),
                  Text(
                    'Add Your Details',
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
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
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
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
                                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Name can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid Name';
                                  }
                                  if (text.length > 50) {
                                    return 'Name can\'t be more than 50';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  nameTextEdittingcont.text = text;
                                }),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'NIC Number',
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
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
                                  prefixIcon: Icon(Icons.credit_card, color: Colors.grey),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'NIC can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid NIC';
                                  }
                                  if (text.length > 12) {
                                    return 'NIC can\'t be more than 12';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  nicTextEdittingcont .text = text;
                                }),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'License Number',
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
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
                                  prefixIcon: Icon(Icons.credit_card, color: Colors.grey),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'License can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid License';
                                  }
                                  if (text.length > 12) {
                                    return 'License can\'t be more than 12';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  licenseTextEdittingcont .text = text;
                                }),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
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
                                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Email can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid Email';
                                  }
                                  if (text.length > 50) {
                                    return 'Email can\'t be more than 50';
                                  }
                                  if (!EmailValidator.validate(text)) {
                                    return 'Please enter a valid Email';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEdittingcont.text = text;
                                }),
                              ),
                              SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromRGBO(28, 42, 58, 1),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text('Profile Photo',style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(height: 10),
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: _profilePhoto != null ? FileImage(_profilePhoto!) : null,
                                          child: _profilePhoto == null ? Icon(Icons.person, size: 40) : null,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _pickImage(ImageSource.gallery, isProfile: true);
                                          },
                                          child: Text(_frontImage==null?'Select':'Selected'),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text('Front License',style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: _frontImage != null ? Image.file(_frontImage!, height: 80, width: 80) : Icon(Icons.image, size: 80),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _pickImage(ImageSource.gallery, isFront: true);
                                          },
                                          child: Text(_frontImage==null?'Select':'Selected'),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text('Rear License',style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: _rearImage != null ? Image.file(_rearImage!, height: 80, width: 80) : Icon(Icons.image, size: 80),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _pickImage(ImageSource.gallery);
                                          },
                                          child: Text(_rearImage==null?'Select':'Selected'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 20),

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
                                onPressed: _submit,
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
