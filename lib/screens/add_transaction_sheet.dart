import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/models.dart';
import 'transaction_provider.dart';
import 'currencies.dart';
import 'income_categories.dart';
import '../screens/app_theme.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? existing;
  const AddTransactionSheet({super.key, this.existing});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _customCategoryCtrl = TextEditingController();

  bool _isExpense = false;
  String _expenseCategory = kExpenseCategories.first;
  String _incomeCategory = kIncomeCategories.first.name;
  bool _isCustomIncomeCategory = false;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _noteCtrl.text = e.note;
      _isExpense = e.isExpense;
      _date = e.date;
      if (e.isExpense) {
        _expenseCategory = e.category;
      } else {
        final isKnown = kIncomeCategories.any((c) => c.name == e.category);
        if (isKnown) {
          _incomeCategory = e.category;
        } else {
          _isCustomIncomeCategory = true;
          _customCategoryCtrl.text = e.category;
        }
      }
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  String get _resolvedCategory {
    if (!_isExpense) {
      return _isCustomIncomeCategory ? _customCategoryCtrl.text.trim() : _incomeCategory;
    }
    return _expenseCategory;
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) { _showError('Please enter a valid amount.'); return; }
    if (_resolvedCategory.isEmpty) { _showError('Please enter a category name.'); return; }

    final income = ref.read(totalIncomeProvider);
    final expense = ref.read(totalExpenseProvider);
    final notifier = ref.read(transactionsProvider.notifier);

    String? error;
    if (widget.existing != null) {
      error = notifier.update(
        updated: TransactionModel(
          id: widget.existing!.id,
          amount: amount,
          category: _resolvedCategory,
          date: _date,
          note: _noteCtrl.text.trim(),
          isExpense: _isExpense,
        ),
        currentIncome: income,
        currentExpense: expense,
        oldAmount: widget.existing!.amount,
        wasExpense: widget.existing!.isExpense,
      );
    } else {
      error = notifier.add(
        amount: amount,
        category: _resolvedCategory,
        date: _date,
        note: _noteCtrl.text.trim(),
        isExpense: _isExpense,
        currentIncome: income,
        currentExpense: expense,
      );
    }

    if (error != null) { _showError(error); } else { Navigator.pop(context); }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = ref.watch(selectedCurrencyProvider);

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Add Transaction' : 'Edit Transaction',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // STEP 1: Currency
            _StepLabel(step: '1', label: 'Select Currency'),
            const SizedBox(height: 8),
            DropdownButtonFormField<AppCurrency>(
              value: currency,
              isExpanded: true,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.public_rounded), labelText: 'Currency'),
              items: kCurrencies.map((c) => DropdownMenuItem<AppCurrency>(
                value: c,
                child: Text('${c.flag}  ${c.code} (${c.symbol}) — ${c.country}'),
              )).toList(),
              onChanged: (v) { if (v != null) ref.read(selectedCurrencyProvider.notifier).state = v; },
            ),
            const SizedBox(height: 20),

            // STEP 2: Type toggle
            _StepLabel(step: '2', label: 'Transaction Type'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF4F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                _TypeBtn(label: '💰 Income', selected: !_isExpense, color: AppTheme.income, onTap: () => setState(() => _isExpense = false)),
                _TypeBtn(label: '💸 Expense', selected: _isExpense, color: AppTheme.expense, onTap: () => setState(() => _isExpense = true)),
              ]),
            ),
            const SizedBox(height: 20),

            // STEP 3: Category
            _StepLabel(step: '3', label: _isExpense ? 'Expense Category' : 'Income Category'),
            const SizedBox(height: 8),
            if (!_isExpense) ...[
              DropdownButtonFormField<String>(
                value: _isCustomIncomeCategory ? 'custom' : _incomeCategory,
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_rounded), labelText: 'Income Source'),
                items: [
                  ...kIncomeCategories.map((c) => DropdownMenuItem(
                    value: c.name,
                    child: Row(children: [Icon(c.icon, size: 18, color: AppTheme.income), const SizedBox(width: 8), Text(c.name)]),
                  )),
                  const DropdownMenuItem(value: 'custom', child: Row(children: [
                    Icon(Icons.edit_rounded, size: 18, color: Colors.grey), SizedBox(width: 8), Text('Custom...'),
                  ])),
                ],
                onChanged: (v) => setState(() {
                  if (v == 'custom') { _isCustomIncomeCategory = true; }
                  else { _isCustomIncomeCategory = false; _incomeCategory = v!; }
                }),
              ),
              if (_isCustomIncomeCategory) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customCategoryCtrl,
                  decoration: const InputDecoration(labelText: 'Type your income category', prefixIcon: Icon(Icons.edit_rounded)),
                ),
              ],
            ] else
              DropdownButtonFormField<String>(
                value: _expenseCategory,
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.label_outline_rounded), labelText: 'Expense Category'),
                items: kExpenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _expenseCategory = v!),
              ),
            const SizedBox(height: 20),

            // STEP 4: Amount
            _StepLabel(step: '4', label: 'Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Text(currency.symbol,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                          color: _isExpense ? AppTheme.expense : AppTheme.income)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today_rounded)),
                child: Text('${_date.day}/${_date.month}/${_date.year}', style: theme.textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.edit_note_rounded)),
            ),
            const SizedBox(height: 20),

            _BalancePreview(isExpense: _isExpense, amountText: _amountCtrl.text),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: _isExpense ? AppTheme.expense : AppTheme.income),
              child: Text(widget.existing == null ? (_isExpense ? 'Add Expense' : 'Save Income') : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final String step;
  final String label;
  const _StepLabel({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 22, height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
        child: Text(step, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    ]);
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeBtn({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: selected ? color : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: selected ? Colors.white : Colors.grey)),
        ),
      ),
    );
  }
}

class _BalancePreview extends ConsumerWidget {
  final bool isExpense;
  final String amountText;
  const _BalancePreview({required this.isExpense, required this.amountText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final remaining = income - expense;
    final tryAmount = double.tryParse(amountText) ?? 0;
    final afterThis = isExpense ? remaining - tryAmount : remaining + tryAmount;
    final willOverflow = isExpense && afterThis < 0;

    if (income == 0 && !isExpense) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: willOverflow ? AppTheme.expense.withValues(alpha: 0.1) : AppTheme.income.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: willOverflow ? AppTheme.expense.withValues(alpha: 0.4) : AppTheme.income.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(willOverflow ? Icons.warning_amber_rounded : Icons.account_balance_wallet_rounded,
            color: willOverflow ? AppTheme.expense : AppTheme.income, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Current Balance: ${currency.format(remaining)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (tryAmount > 0)
            Text('After this: ${currency.format(afterThis)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: willOverflow ? AppTheme.expense : AppTheme.income)),
          if (willOverflow)
            const Text('⚠️ Exceeds your available balance!',
                style: TextStyle(fontSize: 11, color: AppTheme.expense, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}