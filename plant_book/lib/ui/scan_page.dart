import 'package:flutter/material.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/ui/screens/add_post_page.dart';
import 'package:plant_book/ui/screens/widgets/add_images.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    // Get device size
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(
        children: [
          // Top navigation row
          Positioned(
            top: size.height * 0.05, // Dynamic vertical position
            left: size.width * 0.05, // Dynamic horizontal padding
            right: size.width * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: size.width * 0.1, // Proportional sizing
                    width: size.width * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * 0.05),
                      color: Constants.primaryColor.withOpacity(.15),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Constants.primaryColor,
                      size: size.width * 0.06, // Proportional icon size
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Positioned(
            top: size.height * 0.15,
            left: size.width * 0.1,
            right: size.width * 0.1,
            child: Column(
              children: [
                // Tap to Scan Button
                Container(
                  width: size.width * 0.8,
                  height: size.height * 0.4,
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddPhotoPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/code-scan.png',
                          height: size.height * 0.2, // Responsive image height
                        ),
                        SizedBox(height: size.height * 0.02), // Dynamic spacing
                        Text(
                          'Tap to Scan',
                          style: TextStyle(
                            color: Constants.primaryColor.withOpacity(.80),
                            fontWeight: FontWeight.w500,
                            fontSize: size.width * 0.05, // Responsive font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03), // Dynamic spacing

                // Add Post Button
                Container(
                  width: size.width * 0.8,
                  height: size.height * 0.4,
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddPostPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.25,
                        vertical: size.height * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/upload_post.png',
                          height: size.height * 0.2, // Responsive image height
                        ),
                        SizedBox(height: size.height * 0.02), // Dynamic spacing
                        Text(
                          'Add Post',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                size.width * 0.045, // Responsive font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
