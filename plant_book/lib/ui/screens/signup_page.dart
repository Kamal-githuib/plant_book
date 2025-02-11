import 'dart:convert'; // Import for Base64 Encoding
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:plant_book/constants.dart';
import 'package:plant_book/firebase/firebase_auth.dart';
import 'package:plant_book/firebase/utils/dialog.dart';
import 'package:plant_book/firebase/utils/exceptions.dart';
import 'package:plant_book/firebase/utils/imagepicker.dart';
import 'package:plant_book/ui/screens/signin_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  FocusNode fullname_F = FocusNode();
  FocusNode email_F = FocusNode();
  FocusNode password_F = FocusNode();
  FocusNode passwordConfirm_F = FocusNode();
  FocusNode username_F = FocusNode();
  FocusNode bio_F = FocusNode();

  File? _imageFile; // For mobile
  Uint8List? _webImage; // For web

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }
Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // 🌐 Web: Convert image to Uint8List
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        // 📱 Mobile: Use File
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
        });
      }
    }
  }

  Future<String?> encodeBase64() async {
    try {
      if (kIsWeb && _webImage != null) {
        return base64Encode(_webImage!);
      } else if (_imageFile != null) {
        return base64Encode(_imageFile!.readAsBytesSync());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to encode image: $e')));
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/signup.png'),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),

              // Profile Image Upload
              InkWell(
                onTap: () async {
                  File imageFile = await ImagePickerr().uploadImage('gallery');
                  setState(() {
                    _imageFile = imageFile;
                  });
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey,
                  child: _imageFile == null
                      ? CircleAvatar(
                          radius: 34,
                          backgroundImage: const AssetImage('assets/images/person.png'),
                          backgroundColor: Colors.grey.shade200,
                        )
                      : CircleAvatar(
                          radius: 34,
                          backgroundImage: FileImage(_imageFile!),
                          backgroundColor: Colors.grey.shade200,
                        ),
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  icon: Icon(Icons.alternate_email),
                ),
              ),
              TextField(
                controller: fullnameController,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  icon: Icon(Icons.perm_identity_outlined),
                ),
              ),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  icon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  hintText: 'Bio',
                  icon: Icon(Icons.info),
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  icon: Icon(Icons.lock),
                ),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm Password',
                  icon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 10),

              // Sign Up Button
              GestureDetector(
                onTap: () async {
                  try {
                    String? base64Image;

                    // Convert image to Base64
                    if (_imageFile != null) {
                      List<int> imageBytes = await _imageFile!.readAsBytes();
                      base64Image = base64Encode(imageBytes);
                    }

                    await Authentication().Signup(
                      email: emailController.text.trim(),
                      fullname: fullnameController.text.trim(),
                      username: usernameController.text.trim(),
                      bio: bioController.text.trim(),
                      password: passwordController.text.trim(),
                      passwordConfirm: confirmPasswordController.text.trim(),
                      profile: base64Image ,  // Save as Base64 string
                    );

                    dialogBuilder(context, 'Account created successfully!');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignIn()),
                    );
                  } on exceptions catch (e) {
                    dialogBuilder(context, e.message);
                  }
                },
                child: Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
             
              const SizedBox(height: 20),

              // Navigate to Sign In
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: const SignIn(),
                      type: PageTransitionType.bottomToTop,
                    ),
                  );
                },
                child: Center(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: 'Have an Account? ',
                        style: TextStyle(
                          color: Constants.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Constants.primaryColor,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
