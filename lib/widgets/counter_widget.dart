 import 'package:flutter/material.dart';
import 'package:plant_book/styles/apptheme.dart';

Widget buildCounter(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(
            color: AppTheme.lightGray,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.lightGrayBlue, fontSize: 14),
        ),
      ],
    );
  }
