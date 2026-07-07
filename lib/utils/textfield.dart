import 'package:flutter/material.dart';
import 'package:plant_book/styles/apptheme.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.icon,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final IconData icon;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      cursorColor: AppTheme.lightGray,
      obscureText:
          widget.obscure, // If true, the text will be obscured (e.g., for passwords) and if false, the text will be visible
      style: const TextStyle(color: AppTheme.lightGray),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: AppTheme.green),
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppTheme.gray),
        filled: true,
        fillColor: AppTheme.darkGray,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.lightGray, width: 2.0),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
