import 'package:flutter/material.dart';
import 'package:plant_book/utils/textfield.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/responsiveness.dart';
import 'package:plant_book/widgets/signup_button.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final responsive = Responsive(context);
    return Scaffold(
      backgroundColor: AppTheme.darkGray,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGray,
        centerTitle: true,
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: AppTheme.lightGray,
            fontSize: responsive.fontSize(22, 28),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600
                ? 500
                : constraints.maxWidth * 0.9;

            return Center(
              child: SingleChildScrollView(
                child: Container(
                  width: maxWidth,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 20),
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

                      const SizedBox(height: 30),

                      CustomTextField(
                        controller: nameController,
                        hint: 'Full Name',
                        obscure: false,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: emailController,
                        hint: 'Email',
                        obscure: false,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: usernameController,
                        hint: 'Username',
                        obscure: false,
                        icon: Icons.account_circle,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: passwordController,
                        hint: 'Password',
                        obscure: true,
                        icon: Icons.lock,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: confirmPasswordController,
                        hint: 'Confirm Password',
                        obscure: true,
                        icon: Icons.lock,
                      ),

                      const SizedBox(height: 30),

                      SignUpButton(
                        nameController: nameController,
                        emailController: emailController,
                        usernameController: usernameController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
