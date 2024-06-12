import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuk_tuk_project_driver/assistants/assistants_method.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/widgets/progress_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  late bool isupdating = false;

  DatabaseReference userRef=FirebaseDatabase.instance.ref().child("users");

  void reload(){
    setState(() {
      AssistanntMethods.readCurrentOnlineUserInfo();
    });
  }


  Future<void> showUserNameDialogalert(BuildContext context, String name){

    nameTextEditingController.text = name;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
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
                  child: Text("Cancel",style: TextStyle(color: Colors.red),)
              ),

              TextButton(
                  onPressed: (){
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) => ProgressDialog()
                    );

                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "name": nameTextEditingController.text.trim(),
                    }).then((value){
                      Navigator.pop(context);
                      Navigator.pop(context);
                      reload();
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully.");

                    }).catchError((errorMessage){
                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: "Error Ocured \n $errorMessage");
                    });

                  },
                  child: Text("Ok",style: TextStyle(color: Colors.black),)
              ),
            ],
          );
        }
    );
  }

  Future<void> showUseremailDialogalert(BuildContext context, String email){

    emailTextEditingController.text = email;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: emailTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",style: TextStyle(color: Colors.red),)
              ),

              TextButton(
                  onPressed: (){

                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) =>ProgressDialog()
                    );

                    userRef.child(firebaseAuth.currentUser!.uid).update({
                      "email": emailTextEditingController.text.trim(),
                    }).then((value){
                      reload();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      emailTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully.");
                    }).catchError((errorMessage){
                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: "Error Ocured \n $errorMessage");
                    });
                  },
                  child: Text("Ok",style: TextStyle(color: Colors.black),)
              ),
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
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back
            ),
            color: Colors.black,
          ),
          title: Text("Profile Screen",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.person,
                  color: Colors.white,
                  ),
                ),

                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrrentInfo!.name!}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                      ),
                    ),

                    IconButton(
                        onPressed: (){
                          showUserNameDialogalert(context, userModelCurrrentInfo!.name!);
                        },
                        icon: Icon(Icons.edit),
                    ),
                  ],
                ),

                Divider(
                  thickness: 1,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${userModelCurrrentInfo!.email!}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    IconButton(
                      onPressed: (){
                        showUseremailDialogalert(context, onlineDriverData!.email!);
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),

                Divider(
                  thickness: 1,
                ),

                Text("${onlineDriverData!.phone!}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
