import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart'; // Step 1: Import Firebase package
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';
import 'package:tuk_tuk_project_driver/screens/main_screen.dart';
import '../widgets/progress_dialog.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  get currentUser => null;

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final TextEditingController carmodelTextEditingController = TextEditingController();
  final TextEditingController carnumberTextEditingController = TextEditingController();
  final TextEditingController carcolorTextEditingController = TextEditingController();
  List<String> carTypes = ["Car", "Threewheeler", "Motorbike"];
  String? selectedCarType;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    carmodelTextEditingController.dispose();
    carnumberTextEditingController.dispose();
    carcolorTextEditingController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) { // Check if the form is valid
      // Form data is valid, submit to Firebase
      _saveToFirebase();
      // Navigate to the login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Main_screen()),
      );
    }
  }

  void _saveToFirebase() {
    // Get the form data
    String carModel = carmodelTextEditingController.text;
    String carNumber = carnumberTextEditingController.text;
    String carColor = carcolorTextEditingController.text;
    // You can add Firebase logic here to save the data
    // For example:
    DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('car_info');
    dbRef.push().set({
      'car_model': carModel,
      'car_number': carNumber,
      'car_color': carColor,
      'car_type': selectedCarType,
    }).then((_) {
      // Data added successfully
      Fluttertoast.showToast(msg: 'Data added to Firebase');
    }).catchError((error) {
      // Handle errors here
      Fluttertoast.showToast(msg: 'Failed to add data to Firebase: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset('assets/van.png'),
                SizedBox(height: 20),
                Text(
                  "Add Vehicle Details",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
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
                                hintText: 'Vehicle Model',
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
                            SizedBox(height: 10),
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
                            SizedBox(height: 10),
                            DropdownButtonFormField(
                              value: selectedCarType,
                              decoration: InputDecoration(
                                hintText: "Please choose vehicle type",
                                prefixIcon: Icon(Icons.car_crash, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey.shade200,
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
                            SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(28, 42, 58, 1),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: _submit,
                              child: Text(
                                'Submit',
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
    );
  }
}
