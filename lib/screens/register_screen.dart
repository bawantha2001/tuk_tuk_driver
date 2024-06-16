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

  final _formkey = GlobalKey<FormState>();

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _rearImage = File(pickedFile.path);
        }
      });
    }
  }


  // Future<String?> _uploadImage(File imageFile, String path) async {
  //   try {
  //     // Create a reference to the location you want to upload to in Firebase Storage
  //     final storageRef = FirebaseStorage.instance.ref();
  //     final imagesRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  //
  //     // Upload the file to Firebase Storage
  //     await imagesRef.putFile(_frontImage!);
  //
  //     // Get the download URL
  //     final downloadUrl = await imagesRef.getDownloadURL();
  //
  //     print('Upload complete! Image URL: $downloadUrl');
  //   } catch (e) {
  //     print("Error uploading image: $e");
  //     Fluttertoast.showToast(msg: "Error uploading image: $e");
  //     return null;
  //   }
  // }


  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final storageRef = FirebaseStorage.instanceFor(bucket: "gs://tuk-tuk-project-f640b").ref();
      final imagesRef = storageRef.child(path);

      // Upload the file to Firebase Storage
      await imagesRef.putFile(imageFile);

      // Get the download URL
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

          if (_frontImage != null) {
            frontImageUrl = await _uploadImage(_frontImage!, "drivers/${widget.currentUser!.uid}/front_license.jpg");
          }

          if (_rearImage != null) {
            rearImageUrl = await _uploadImage(_rearImage!, "drivers/${widget.currentUser!.uid}/rear_license.jpg");
          }

          Map<String, dynamic> userMap = {
            "id": widget.currentUser!.uid,
            "name": nameTextEdittingcont.text.trim(),
            "email": emailTextEdittingcont.text.trim(),
            "phone": widget.phoneNumber,
            "nic": nicTextEdittingcont.text.trim(),
            "license": licenseTextEdittingcont.text.trim(),
            "front_license_url": frontImageUrl,
            "rear_license_url": rearImageUrl,
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
          decoration: BoxDecoration(color: Color.fromRGBO(226, 227, 225, 1)),
          child: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Image.asset("assets/logo.jpg"),
                  SizedBox(height: 20),
                  Text(
                    'Add Your Details',
                    style: TextStyle(
                      color: Color.fromRGBO(28, 42, 58, 1),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
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
                                  prefixIcon: Icon(Icons.numbers_sharp, color: Colors.grey),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'License can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid License';
                                  }
                                  if (text.length > 15) {
                                    return 'License can\'t be more than 15';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  licenseTextEdittingcont .text = text;
                                }),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Contact Number',
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
                                  prefixIcon: Icon(Icons.phone, color: Colors.grey),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Contact can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid Contact Number';
                                  }
                                  if (text.length > 10) {
                                    return 'Contact can\'t be more than 10';
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
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Email',
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

                                  if (EmailValidator.validate(text) == true) {
                                    return null;
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid Email';
                                  }
                                  if (text.length > 90) {
                                    return 'Email can\'t be more than 90';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEdittingcont.text = text;
                                }),
                              ),
                              SizedBox(height: 15),

                              GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery, true),
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
                                        _frontImage == null ? 'Front side of License' : 'Image Selected',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery, false),
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
                                        _rearImage == null ? 'Rear side of License' : 'Image Selected',
                                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(28, 42, 58, 1),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  minimumSize: Size(double.infinity, 50),
                                ),
                                onPressed: () {
                                  _submit();
                                },
                                child: Text(
                                  'Finish',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
