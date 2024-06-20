import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuk_tuk_project_driver/screens/main_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/progress_dialog.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key, required this.currentUser});
  final User? currentUser;

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final TextEditingController carmodelTextEditingController = TextEditingController();
  final TextEditingController carnumberTextEditingController = TextEditingController();
  final TextEditingController carcolorTextEditingController = TextEditingController();
  List<String> carTypes = ["car", "tuk", "lorry", "van"];
  String? selectedCarType;
  final _formKey = GlobalKey<FormState>();
  Map<String, File?> _images = {
    'front': null,
    'inside': null,
    'rear': null,
    'insurance': null,
    'license': null
  };

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images[imageType] = File(pickedFile.path);
      });
    }
  }

  Future<Map<String, String>> _uploadImages(Map<String, File?> images) async {
    Map<String, String> downloadUrls = {};
    for (String key in images.keys) {
      if (images[key] != null) {
        String downloadUrl = await _uploadImage(images[key]!, 'vehicle_images/${widget.currentUser!.uid}/$key.jpg');
        downloadUrls[key] = downloadUrl;
      }
    }
    return downloadUrls;
  }

  Future<String> _uploadImage(File imageFile, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      print('Upload complete! Image URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      Fluttertoast.showToast(msg: "Error uploading image: $e");
      rethrow;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => ProgressDialog()
        );
        Map<String, String> imageUrls = await _uploadImages(_images);
        Map<String, dynamic> driverCarInfoMap = {
          'car_model': carmodelTextEditingController.text.trim(),
          'car_number': carnumberTextEditingController.text.trim(),
          'type': selectedCarType,
          'images': imageUrls,
        };

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child('drivers');
        await userRef.child(widget.currentUser!.uid).child("car_details").set(driverCarInfoMap);
        Fluttertoast.showToast(msg: "Saved successfully");
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Main_screen()));
      } catch (e) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(

        body:
        Container(
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
                    padding: const EdgeInsets.only(top: 30,bottom: 40),
                    child: Image.asset('assets/logo2.png'),
                  ),
                  GradientText(
                    text: "Add Vehicle Details",
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
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.black87], // Gradient colors
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: carmodelTextEditingController,
                                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                                decoration: InputDecoration(
                                  hintText: 'Vehicle Brand',
                                  hintStyle: TextStyle(color: Colors.grey),
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
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: carnumberTextEditingController,
                                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                                decoration: InputDecoration(
                                  hintText: 'Vehicle Number',
                                  hintStyle: TextStyle(color: Colors.grey),
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
                                    return 'Number can\'t be empty';
                                  }
                                  if (text.length < 2) {
                                    return 'Please enter a valid Number';
                                  }
                                  if (text.length > 50) {
                                    return 'Number can\'t be more than 50';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),

                              DropdownButtonFormField(
                                value: selectedCarType,
                                decoration: InputDecoration(
                                  hintText: "Please choose vehicle type",
                                  prefixIcon: Icon(Icons.car_crash, color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(28, 42, 58, 1),
                                      width: 2.0,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 2.0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                ),
                                items: carTypes.map((car) {
                                  return DropdownMenuItem(
                                    value: car,
                                    child: Text(
                                      car,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedCarType = newValue.toString();
                                  });
                                },
                              ),
                              SizedBox(height: 20),


                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      _buildImagePicker(context, 'Front of vehicle', 'front'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      _buildImagePicker(context, 'Inside of vehicle', 'inside'),

                                    ],
                                  ),

                                ],
                              ),

                              SizedBox(height: 15,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildImagePicker(context, 'Rear of vehicle', 'rear'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 20), // Add spacing between the two columns
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildImagePicker(context, 'Insurance copy ', 'insurance'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 15,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      _buildImagePicker(context, 'License copy of vehicle', 'license'),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 25,),


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

  Widget _buildImagePicker(BuildContext context, String label, String imageType) {
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery, imageType),
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
              _images[imageType] == null ? label : 'Image Selected',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  GradientText({required this.text, required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white), // color is ignored due to shader
      ),
    );
  }
}
