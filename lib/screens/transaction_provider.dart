import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../screens/models.dart';
import 'currencies.dart';

// ─── Currency Provider ───────────────────────────────────────────────
final selectedCurrencyProvider = StateProvider<AppCurrency>(
      (ref) => kCurrencies.first, // default PKR
);

// ─── Hive Box ────────────────────────────────────────────────────────
final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('transactions');
});

// ─── Transaction Notifier ─────────────────────────────────────────────
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

  /// Returns null on success, error message string on failure
  String? add({
    required double amount,
    required String category,
    required DateTime date,
    required String note,
    required bool isExpense,
    required double currentIncome,
    required double currentExpense,
  }) {
    if (isExpense) {
      if (currentIncome == 0) {
        return 'Please add income first before adding expenses.';
      }
      if (currentExpense + amount > currentIncome) {
        final remaining = currentIncome - currentExpense;
        return 'Expense exceeds remaining balance!\nAvailable: ${remaining.toStringAsFixed(0)}\nYou tried to add: ${amount.toStringAsFixed(0)}';
      }
    }
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
    return null;
  }

  String? update({
    required TransactionModel updated,
    required double currentIncome,
    required double currentExpense,
    required double oldAmount,
    required bool wasExpense,
  }) {
    if (updated.isExpense) {
      final expenseWithoutOld = wasExpense ? currentExpense - oldAmount : currentExpense;
      if (currentIncome == 0) return 'Please add income first.';
      if (expenseWithoutOld + updated.amount > currentIncome) {
        final remaining = currentIncome - expenseWithoutOld;
        return 'Expense exceeds remaining balance!\nAvailable: ${remaining.toStringAsFixed(0)}';
      }
    }
    _box.put(updated.id, updated);
    _load();
    return null;
  }

  void delete(String id) {
    _box.delete(id);
    _load();
  }
}

final totalIncomeProvider = Provider<double>((ref) {
  return ref.watch(transactionsProvider).where((t) => !t.isExpense).fold(0.0, (s, t) => s + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  return ref.watch(transactionsProvider).where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  return ref.watch(totalIncomeProvider) - ref.watch(totalExpenseProvider);
});

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final monthlyTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final txs = ref.watch(transactionsProvider);
  final month = ref.watch(selectedMonthProvider);
  return txs.where((t) => t.date.month == month.month && t.date.year == month.year).toList();
});

final monthlyIncomeProvider = Provider<double>((ref) {
  return ref.watch(monthlyTransactionsProvider).where((t) => !t.isExpense).fold(0.0, (s, t) => s + t.amount);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  return ref.watch(monthlyTransactionsProvider).where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);
});

final categoryExpenseProvider = Provider<Map<String, double>>((ref) {
  final Map<String, double> map = {};
  for (final t in ref.watch(monthlyTransactionsProvider).where((t) => t.isExpense)) {
    map[t.category] = (map[t.category] ?? 0) + t.amount;
  }
  return map;
});

final monthlyTrendProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final txs = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - 5 + i);
    final ms = txs.where((t) => t.date.month == month.month && t.date.year == month.year);
    return {
      'month': month,
      'income': ms.where((t) => !t.isExpense).fold(0.0, (s, t) => s + t.amount),
      'expense': ms.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount),
    };
  });
});