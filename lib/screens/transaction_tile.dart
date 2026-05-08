import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/models.dart';
import '../screens/app_theme.dart';
import 'transaction_provider.dart';
import 'categories.dart';
import 'formatters.dart';
import 'add_transaction_sheet.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel tx;
  const TransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = tx.isExpense ? AppTheme.expense : AppTheme.income;
    final bgColor = tx.isExpense ? AppTheme.expenseLight : AppTheme.incomeLight;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.2) : bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(AppCategories.iconFor(tx.category), color: color, size: 22),
        ),
        title: Text(
          tx.category,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          tx.note.isNotEmpty
              ? '${tx.note}  •  ${AppFormat.date(tx.date)}'
              : AppFormat.date(tx.date),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${tx.isExpense ? '-' : '+'}${AppFormat.currency(tx.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (v) {
                if (v == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => AddTransactionSheet(existing: tx),
                  );
                } else {
                  ref.read(transactionsProvider.notifier).delete(tx.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}