import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../screens/models.dart';

final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('transactions');
});

final transactionsProvider =
StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final box = ref.watch(transactionBoxProvider);
  return TransactionNotifier(box);
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final Box<TransactionModel> _box;
  final _uuid = const Uuid();

  TransactionNotifier(this._box) : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void add({
    required double amount,
    required String category,
    required DateTime date,
    required String note,
    required bool isExpense,
  }) {
    final tx = TransactionModel(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      date: date,
      note: note,
      isExpense: isExpense,
    );
    _box.put(tx.id, tx);
    _load();
  }

  void update(TransactionModel updated) {
    _box.put(updated.id, updated);
    _load();
  }

  void delete(String id) {
    _box.delete(id);
    _load();
  }
}

// Summary providers
final totalIncomeProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionsProvider);
  return txs
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final txs = ref.watch(transactionsProvider);
  return txs
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

// Monthly transactions
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final monthlyTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final txs = ref.watch(transactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  return txs
      .where((t) => t.date.month == month.month && t.date.year == month.year)
      .toList();
});

// Category breakdown for charts
final categoryExpenseProvider = Provider<Map<String, double>>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider);
  final Map<String, double> map = {};
  for (final t in txs.where((t) => t.isExpense)) {
    map[t.category] = (map[t.category] ?? 0) + t.amount;
  }
  return map;
});

// Monthly trend (last 6 months)
final monthlyTrendProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final txs = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - 5 + i);
    final monthTxs = txs.where(
            (t) => t.date.month == month.month && t.date.year == month.year);
    return {
      'month': month,
      'income': monthTxs
          .where((t) => !t.isExpense)
          .fold(0.0, (s, t) => s + t.amount),
      'expense': monthTxs
          .where((t) => t.isExpense)
          .fold(0.0, (s, t) => s + t.amount),
    };
  });
});