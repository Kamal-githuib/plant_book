import 'package:flutter/material.dart';
import 'package:plant_book/utils/textfield.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:plant_book/utils/resetpassword_function.dart';
import 'package:plant_book/utils/responsiveness.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context); // Screen responsiveness

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.darkGray,
        centerTitle: true,
        title: Text(
          'Forgot Password',
          style: TextStyle(
            color: AppTheme.lightGray,
            fontSize: responsive.fontSize(
              22,
              26,
            ), // font size for mobile is 22, for tablet is 26
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: AppTheme.darkGray,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.isTablet
                    ? 64
                    : 24, // padding for tablet is 64, for mobile is 24
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          color: AppTheme.lightGray,
                          fontSize: responsive.fontSize(22, 26),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Enter your email address and we’ll send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.lightGrayBlue,
                          fontSize: responsive.fontSize(
                            14,
                            16,
                          ), // font size for mobile is 14, for tablet is 16
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Custom Text field for email
                      CustomTextField(
                        controller: emailController,
                        hint: 'Email',
                        obscure: false,
                        icon: Icons.email,
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => sendPasswordReset(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontSize: responsive.fontSize(
                                16,
                                18,
                              ), // font size for mobile is 16, for tablet is 18
                              color: AppTheme.lightGray,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: "Remembered your password? ",
                            style: TextStyle(
                              color: AppTheme.lightGrayBlue,
                              fontSize: responsive.fontSize(
                                14,
                                16,
                              ), // font size for mobile is 14, for tablet is 16
                            ),
                            children: const [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(color: AppTheme.lightGray),
                              ),
                            ],
                          ),
                        ),
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
