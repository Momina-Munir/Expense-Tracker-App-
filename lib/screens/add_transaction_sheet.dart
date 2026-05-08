import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/models.dart';
import 'transaction_provider.dart';
import 'categories.dart';
import '../screens/app_theme.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? existing;
  const AddTransactionSheet({super.key, this.existing});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isExpense = true;
  String _category = AppCategories.predefined.first;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _noteCtrl.text = e.note;
      _isExpense = e.isExpense;
      _category = e.category;
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    final notifier = ref.read(transactionsProvider.notifier);

    if (widget.existing != null) {
      final updated = TransactionModel(
        id: widget.existing!.id,
        amount: amount,
        category: _category,
        date: _date,
        note: _noteCtrl.text.trim(),
        isExpense: _isExpense,
      );
      notifier.update(updated);
    } else {
      notifier.add(
        amount: amount,
        category: _category,
        date: _date,
        note: _noteCtrl.text.trim(),
        isExpense: _isExpense,
      );
    }
    Navigator.pop(context);
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

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.existing == null ? 'Add Transaction' : 'Edit Transaction',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Income / Expense toggle
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF4F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TypeBtn(
                    label: 'Expense',
                    selected: _isExpense,
                    color: AppTheme.expense,
                    onTap: () => setState(() => _isExpense = true)),
                _TypeBtn(
                    label: 'Income',
                    selected: !_isExpense,
                    color: AppTheme.income,
                    onTap: () => setState(() => _isExpense = false)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (Rs)',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),
          const SizedBox(height: 12),

          // Category
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
            items: AppCategories.predefined
                .map((c) => DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  Icon(AppCategories.iconFor(c), size: 18),
                  const SizedBox(width: 8),
                  Text(c),
                ],
              ),
            ))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 12),

          // Date
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Note
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _save,
            child: Text(widget.existing == null ? 'Add Transaction' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}