import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';
import 'package:tuk_tuk_project_driver/screens/profile_screen.dart';
import 'package:tuk_tuk_project_driver/screens/profile_screen.dart';

import '../global/global.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(50, 50, 0, 20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle
                    ),
                    child:Icon(Icons.person,
                    color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20,),
                  Text(
                    userModelCurrrentInfo!.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  SizedBox(height: 10,),

                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=>ProfileScreen()));
                    },
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue
                      ),
                    ),
                  ),

                  SizedBox(height:30 ,),

                  Text("Your Trips",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                      )
                  ),
                  SizedBox(height:15 ,),

                  Text("Notifications",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )
                  ),

                  SizedBox(height:15 ,),
                  Text("Promos",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )
                  ),

                  SizedBox(height:15 ,),
                  Text("Helps",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )
                  ),

                  SizedBox(height:15 ,),
                  Text("Free Trips",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )
                  ),

                  SizedBox(height:50 ,)

                ],
              )        ,

              GestureDetector(
                onTap: ()
                {
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
                },
                child: Text("Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.red
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
