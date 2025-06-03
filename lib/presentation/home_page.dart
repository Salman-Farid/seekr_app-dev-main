import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tabIndex = 0;
  List<Widget> screenList = const [
    // CameraPage(),
    // DevicePage(),
    // SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      body: Center(
        child: screenList[tabIndex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor:Colors.lightBlueAccent,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,

        onTap: (index){
          setState(() {
           tabIndex = index;
          });
        },
        currentIndex: tabIndex,
        
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt,), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_rear_rounded),label: 'Device'),
          BottomNavigationBarItem(icon: Icon(Icons.settings),label: 'Settings')

      ]),
    );
  }
}
