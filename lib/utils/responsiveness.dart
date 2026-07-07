import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late double screenWidth;
  late double screenHeight;
  late bool isTablet;
  

  Responsive(this.context) {
    final size = MediaQuery.of(context).size;  // Get the size of the screen
    screenWidth = size.width;      // Get screen width
    screenHeight = size.height;   // Get screen height
    isTablet = screenWidth > 600; // if width of screen is greater than 600
  }
  
  double fontSize(double mobile, double tablet) =>
      isTablet ? tablet : mobile;  // Font size for tablet(screenWidth > 600) is larger than mobile

  double iconSize(double mobile, double tablet) =>
      isTablet ? tablet : mobile; // Icon size for tablet(screenWidth > 600) is larger than mobile

  double padding(double mobile, double tablet) =>
      isTablet ? tablet : mobile; // Padding for tablet(screenWidth > 600) is larger than mobile
}
