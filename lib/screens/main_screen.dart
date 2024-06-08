import 'package:flutter/material.dart';
import 'package:tuk_tuk_project_driver/global/global.dart';
import 'package:tuk_tuk_project_driver/screens/login_screen.dart';
import 'package:tuk_tuk_project_driver/tabages/home_tab.dart';


class Main_screen  extends StatefulWidget {
  const Main_screen ({super.key});

  @override
  State<Main_screen> createState() => _MainScreenState();
}

class _MainScreenState extends State<Main_screen> with SingleTickerProviderStateMixin{

  TabController? tabController;
  int selectedIndex=0;

  onItemClicked(int index){
    setState(() {
      selectedIndex=index;
      tabController!.index=selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController=TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HometabPage(),
          // EarningsTabPage(),
          // RatingsTabPage(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card),label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.star),label: "Ratings"),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: "Account")
        ],

        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
