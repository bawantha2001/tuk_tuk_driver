import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';

import '../global/global.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController phoneTextEditingController = TextEditingController();
  final TextEditingController addressTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  void loadUserProfile() async {
    final userId = firebaseAuth.currentUser!.uid;
    userRef.child(userId).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        setState(() {
          onlineDriverData.name = data['name'];
          onlineDriverData.phone = data['phone'];
          onlineDriverData.email = data['email'];
          onlineDriverData.profilePhotoUrl = data['profile_photo_url'];
          onlineDriverData.car_model = data['car_model'];
          onlineDriverData.car_type = data['car_type'];
          onlineDriverData.car_number = data['car_number'];
        });
      }
    });
  }

  Future<void> showUpdateDialog(BuildContext context, TextEditingController controller, String field, String currentValue) {
    controller.text = currentValue;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update $field"),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  userRef.child(firebaseAuth.currentUser!.uid).update({field: controller.text.trim()}).then((_) {
                    Fluttertoast.showToast(msg: "$field updated successfully. Please reload the app to see changes.");
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    Fluttertoast.showToast(msg: "Error Occurred: $error");
                    Navigator.of(context).pop();
                  });
                },
                child: Text("OK", style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: Text("Profile Screen", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.yellow, Colors.white],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: onlineDriverData.profilePhotoUrl != null
                            ? NetworkImage(onlineDriverData.profilePhotoUrl!)
                            : AssetImage("assets/default_profile.png") as ImageProvider,
                        backgroundColor: Colors.black38,
                      ),
                      SizedBox(height: 10),
                      buildProfileField("Name", onlineDriverData.name!, () => showUpdateDialog(context, nameTextEditingController, "name", onlineDriverData.name!)),
                      Divider(thickness: 1),
                      buildProfileField("Phone", onlineDriverData.phone!, () => showUpdateDialog(context, phoneTextEditingController, "phone", onlineDriverData.phone!)),
                      Divider(thickness: 1),
                      buildProfileField("Email", onlineDriverData.email!, () => showUpdateDialog(context, emailTextEditingController, "email", onlineDriverData.email!)),
                      Divider(thickness: 1),
                     Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${onlineDriverData.car_model!} \n${onlineDriverData.car_type!} (${onlineDriverData.car_number!})",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),

                          Image.asset(
                              onlineDriverData.car_type=="car"?"assets/car.png"
                                  :onlineDriverData.car_type=="lorry"?"assets/lorry.png"
                                  :onlineDriverData.car_type=="van"?"assets/van.png"
                                  :"assets/tuk.png",
                              scale:10
                          ),
                        ],
                      ),

                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          firebaseAuth.signOut();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: Text("Log Out", style: TextStyle(color: Colors.black, fontSize: 20)),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, String value, Function? onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(value, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        if (onEdit != null)
          IconButton(
            onPressed: () => onEdit(),
            icon: Icon(Icons.edit, color: Colors.black),
          ),
      ],
    );
  }
}
