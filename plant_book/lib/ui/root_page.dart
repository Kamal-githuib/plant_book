import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/models/plants.dart';
import 'package:plant_book/ui/scan_page.dart';
import 'package:plant_book/ui/screens/community_page.dart';
import 'package:plant_book/ui/screens/plant_adoption_page.dart';
import 'package:plant_book/ui/screens/map.dart';
import 'package:plant_book/ui/screens/profile_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Plant> favorites = [];
  List<Plant> myCart = [];

  int _bottomNavIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //List of the pages
  List<Widget> _widgetOptions() {
    return [
      CommunityPage(),
      const PlantAdoptionPage(),
      const MapPage(),
      ProfilePage(
        userId: _auth.currentUser!.uid,
      ),
    ];
  }

  //List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.eco,
    Icons.pin_drop,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Icon(
      //         Icons.notifications,
      //         color: Constants.blackColor,
      //         size: 30.0,
      //       )
      //     ],
      //   ),
      //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //   elevation: 0.0,
      // ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  child: const ScanPage(),
                  type: PageTransitionType.bottomToTop));
        },
        backgroundColor: Constants.primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
          splashColor: Constants.primaryColor,
          activeColor: Constants.primaryColor,
          inactiveColor: Colors.black.withOpacity(.5),
          icons: iconList,
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
              final List<Plant> favoritedPlants = Plant.getFavoritedPlants();
              final List<Plant> addedToCartPlants = Plant.addedToCartPlants();

              favorites = favoritedPlants;
              myCart = addedToCartPlants.toSet().toList();
            });
          }),
    );
  }
}
