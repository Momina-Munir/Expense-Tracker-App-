import 'package:flutter/material.dart';

class IncomeCategory {
  final String name;
  final IconData icon;
  const IncomeCategory(this.name, this.icon);
}

const List<IncomeCategory> kIncomeCategories = [
  IncomeCategory('Salary', Icons.work_rounded),
  IncomeCategory('Freelance', Icons.laptop_rounded),
  IncomeCategory('Business', Icons.store_rounded),
  IncomeCategory('Investment', Icons.trending_up_rounded),
  IncomeCategory('Rental', Icons.home_rounded),
  IncomeCategory('Gift', Icons.card_giftcard_rounded),
  IncomeCategory('Bonus', Icons.star_rounded),
  IncomeCategory('Other', Icons.attach_money_rounded),
];

const List<String> kExpenseCategories = [
  'Food',
  'Travel',
  'Bills',
  'Shopping',
  'Fun',
  'Health',
  'Education',
  'Other',
];