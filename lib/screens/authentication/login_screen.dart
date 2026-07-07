import 'package:flutter/material.dart';
import 'package:plant_book/utils/textfield.dart';
import 'package:plant_book/screens/authentication/forgetpassword_screen.dart';
import 'package:plant_book/screens/authentication/signup_screen.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:plant_book/widgets/login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGray,
        centerTitle: true,
        title: Text(
          'Login',
          style: TextStyle(
            color: AppTheme.lightGray,
            fontSize: responsive.fontSize(
              22,
              28,
            ), // font size for mobile is 22, for tablet is 28
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.padding(
                    24,
                    80,
                  ), // padding for mobile is 24, for tablet is 80
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
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
                        size: responsive.isTablet
                            ? 200
                            : 150, // size for tablet is 200, for mobile is 150
                        color: AppTheme.lightGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Plant Book',
                      style: TextStyle(
                        color: AppTheme.lightGray,
                        fontSize:
                            responsive.fontSize(18, 24) +
                            2, // font size for mobile is 18, for tablet is 24
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Custom Text field for email
                    CustomTextField(
                      controller: emailController,
                      hint: 'Email',
                      obscure: false,
                      icon: Icons.email,
                    ),

                    const SizedBox(height: 20),

                    // Custom Text field for password
                    CustomTextField(
                      controller: passwordController,
                      hint: 'Password',
                      obscure: true,
                      icon: Icons.lock,
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ForgotPasswordPage(), // Navigate to Forgot Password Page
                            ),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppTheme.lightGray,
                            fontSize: responsive.fontSize(
                              14,
                              18,
                            ), // font size for mobile is 14, for tablet is 18
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Login Button
                    LoginButton(
                      emailController: emailController,
                      passwordController: passwordController,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SignUpPage(), // Navigate to Sign Up Page
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Don’t have an account? ",
                            style: TextStyle(color: AppTheme.lightGrayBlue),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(color: AppTheme.lightGray),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
