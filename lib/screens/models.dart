import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final bool isExpense;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.isExpense,
  });
}