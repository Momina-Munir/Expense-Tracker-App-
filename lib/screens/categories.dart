import 'package:flutter/material.dart';

class AppCategories {
  static const List<String> predefined = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Fun',
    'Health',
    'Education',
    'Other',
  ];

  static const List<IconData> icons = [
    Icons.fastfood_rounded,
    Icons.directions_car_rounded,
    Icons.receipt_long_rounded,
    Icons.shopping_bag_rounded,
    Icons.celebration_rounded,
    Icons.favorite_rounded,
    Icons.school_rounded,
    Icons.category_rounded,
  ];

  static IconData iconFor(String category) {
    final idx = predefined.indexOf(category);
    if (idx == -1) return Icons.label_rounded;
    return icons[idx];
  }
}