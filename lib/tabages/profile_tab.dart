import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';

import '../global/global.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {

  final nameTextEditingController=TextEditingController();
  final phoneTextEditingController=TextEditingController();
  final addressTextEditingController=TextEditingController();

  DatabaseReference userRef=FirebaseDatabase.instance.ref().child("drivers");

  Future <void> showDriverNameDialogAlert(BuildContext context,String name){
    nameTextEditingController.text=name;
    
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child:Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update(
                      {
                        "name":nameTextEditingController.text.trim(),
                      }).then((value){
                        nameTextEditingController.clear();
                        Fluttertoast.showToast(msg: "Updated Successully.\n reload the app to see changes.");
                    }).catchError((errorMessage){
                      Fluttertoast.showToast(msg: "Error Occurred. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK",style: TextStyle(color: Colors.black),)
              )
            ],
          );
        }
    );
  }

  Future <void> showDriverPhoneDialogAlert(BuildContext context,String name){
    phoneTextEditingController.text=name;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: phoneTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child:Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.red
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update(
                        {
                          "name":phoneTextEditingController.text.trim(),
                        }).then((value){
                      phoneTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successully.\n reload the app to see changes.");
                    }).catchError((errorMessage){
                      Fluttertoast.showToast(msg: "Error Occurred. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK",style: TextStyle(color: Colors.black),)
              )
            ],
          );
        }
    );
  }

  Future <void> showDriverAddressDialogAlert(BuildContext context,String name){
    addressTextEditingController.text=name;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: addressTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child:Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.red
                    ),
                  )
              ),
              TextButton(
                  onPressed: (){
                    userRef.child(firebaseAuth.currentUser!.uid).update(
                        {
                          "name":addressTextEditingController.text.trim(),
                        }).then((value){
                      addressTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successully.\n reload the app to see changes.");
                    }).catchError((errorMessage){
                      Fluttertoast.showToast(msg: "Error Occurred. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK",style: TextStyle(color: Colors.black),)
              )
            ],
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Profile Screen",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person,color: Colors.white,size: 70,),
                    ),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "${onlineDriverData.name!}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),

                        IconButton(
                            onPressed: (){
                              showDriverNameDialogAlert(context,onlineDriverData.name!);
                            },
                            icon:Icon(
                              Icons.edit,
                              color: Colors.black,
                            )
                        )
                      ],
                    ),

                    Divider(thickness: 1,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.phone!}",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),

                        IconButton(
                            onPressed: (){
                              showDriverNameDialogAlert(context,onlineDriverData.phone!);
                            },
                            icon:Icon(
                              Icons.edit,
                              color: Colors.black,
                            )
                        )
                      ],
                    ),

                    Divider(thickness: 1,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.name!}",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),

                        IconButton(
                            onPressed: (){
                              showDriverNameDialogAlert(context,onlineDriverData.name!);
                            },
                            icon:Icon(
                              Icons.edit,
                              color: Colors.black,
                            )
                        )
                      ],
                    ),

                    Divider(thickness: 1,),


                    Text(
                      "${onlineDriverData.email!}",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),


                    SizedBox(height: 20,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${onlineDriverData.car_model!} \n ${onlineDriverData.car_type!} (${onlineDriverData.car_number!})",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                        ),

                        Image.asset(
                          onlineDriverData.car_type=="car"?"assets/car.png"
                              :onlineDriverData.car_type=="bike"?"assets/lorry.png"
                              :onlineDriverData.car_type=="van"?"assets/van.png"
                              :"assets/tuk.png",
                          scale:10
                        ),
                      ],
                    ),
                    Divider(thickness: 2,),
                    SizedBox(height: 40,),
                    SizedBox(width: 150,
                        height: 50,
                        child:    ElevatedButton(
                          onPressed: (){
                            firebaseAuth.signOut();
                            Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,

                          ),
                          child: Text("Log Out",style: TextStyle(color: Colors.black,fontSize: 20),),
                        )
                      ,)


                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
