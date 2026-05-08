import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/models.dart';
import 'screens/app.dart';

void main() async {
  await Hive.initFlutter();

  // Jab .g.dart file ban jayegi, to yeh error khatam ho jayega
  Hive.registerAdapter(TransactionModelAdapter());

  await Hive.openBox<TransactionModel>('transactions');
  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}