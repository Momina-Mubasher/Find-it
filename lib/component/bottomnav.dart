import 'package:flutter/material.dart';
import 'package:flutter_application_vs/screens/home.dart';
import 'package:flutter_application_vs/screens/my_post.dart';
import 'package:flutter_application_vs/screens/profile.dart';
import 'package:flutter_application_vs/screens/upload_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const UploadItem(),
    const PostScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C5CE7), // Matching your purple theme
        unselectedItemColor: Colors.grey,

        // Change these to true to show the labels
        showSelectedLabels: true,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: "Upload",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: "My Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}