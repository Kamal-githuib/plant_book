import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:plant_book/provider/navigation.dart';
import 'package:plant_book/screens/addingplant_screen.dart';
import 'package:plant_book/screens/addingpost_screen.dart';
import 'package:plant_book/screens/community_screen.dart';
import 'package:plant_book/screens/messageboard_screen.dart';
import 'package:plant_book/screens/plantadoption_screen.dart';
import 'package:plant_book/screens/plant_detection_screen.dart';
import 'package:plant_book/screens/profile_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:provider/provider.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({super.key});

  final List<Widget> _tabs = [
    const CommunityPage(),
    const PlantAdoptionPage(),
    const MessageBoardPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.green,
      body: SafeArea(
        child: IndexedStack(index: navProvider.selectedIndex, children: _tabs),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        shape: CircleBorder(
          side: BorderSide(color: AppTheme.green, width: 2),
          //borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppTheme.green,
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: AppTheme.darkGray,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.camera_alt, color: AppTheme.green),
                    title: Text(
                      'Plant Detection',
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlantDetectionScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.upload, color: AppTheme.green),
                    title: Text(
                      'Upload Post',
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddingPostScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_florist, color: AppTheme.green),
                    title: Text(
                      'Donate your plant',
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPlantPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.lightGray),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
          color: AppTheme.darkGray,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  responsive.screenWidth * 0.01, // adaptive horizontal padding
              vertical:
                  responsive.screenHeight * 0.008, // adaptive vertical padding
            ),
            child: GNav(
              gap: responsive.screenWidth * 0.01, // adaptive gap
              activeColor: AppTheme.lightGray,
              iconSize: responsive.fontSize(24, 26),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.screenWidth * 0.03,
                vertical: responsive.screenHeight * 0.015,
              ),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppTheme.green,
              color: AppTheme.lightGray,
              tabs: [
                GButton(
                  icon: Icons.home,
                  // text: 'Home',
                  haptic: true,
                  textSize: responsive.fontSize(14, 18),
                ),
                GButton(
                  icon: Icons.local_florist,
                  // text: 'Adopt',
                  haptic: true,

                  textSize: responsive.fontSize(14, 18),
                ),
                GButton(
                  icon: Icons.message_rounded,
                  haptic: true,

                  textSize: responsive.fontSize(14, 18),
                ),
                GButton(
                  icon: Icons.person,
                  haptic: true,

                  textSize: responsive.fontSize(14, 18),
                ),
              ],
              selectedIndex: navProvider.selectedIndex,
              onTabChange: (index) {
                navProvider.changeIndex(index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
