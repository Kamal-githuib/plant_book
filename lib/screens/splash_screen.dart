// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/auth_check.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthCheck()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final logoHeight = isTablet ? 180.0 : 100.0;
    final fontSize = isTablet ? 30.0 : 24.0;
    final verticalSpacing = isTablet ? 40.0 : 20.0;

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightGray,
                    spreadRadius: 3,
                    blurRadius: 12,
                    offset: const Offset(4, 4), // move shadow down
                  ),
                ],
              ),
              child: Icon(
                Icons.local_florist,
                size: logoHeight,
                color: AppTheme.lightGray,
              ),
            ),
            SizedBox(height: verticalSpacing),
            Text(
              "PlantBook",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),
            SizedBox(height: verticalSpacing),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
