import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plant_book/firebase_options.dart';
import 'package:plant_book/provider/aichatbot_provider.dart';
import 'package:plant_book/provider/auth_provider.dart';
import 'package:plant_book/provider/chat_provider.dart';
import 'package:plant_book/provider/comment&report_provider.dart';
import 'package:plant_book/provider/like_provider.dart';
import 'package:plant_book/provider/navigation.dart';
import 'package:plant_book/provider/plant_detection_provider.dart';
import 'package:plant_book/provider/plantdata_provider.dart';
import 'package:plant_book/provider/postdata_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(
    // Initialize Firebase with default options
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => PostsDataProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PlantDetectionProvider()),
        ChangeNotifierProvider(create: (_) => ChatBotProvider()),

      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
