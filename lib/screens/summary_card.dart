import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import '../screens/app_theme.dart';
import 'currencies.dart';

class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final remaining = income - expense;
    final currency = ref.watch(selectedCurrencyProvider);

    final isOverspent = remaining < 0;
    final isWarning = !isOverspent && income > 0 && remaining < income * 0.1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverspent
              ? [const Color(0xFFD85A30), const Color(0xFFE8825E)]
              : isWarning
              ? [const Color(0xFFE8A020), const Color(0xFFF0BC4E)]
              : [const Color(0xFF534AB7), const Color(0xFF7B72D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOverspent ? AppTheme.expense : AppTheme.primary).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning banner
          if (isOverspent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Overspent! You have exceeded your income.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else if (isWarning) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Less than 10% balance remaining!',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          const Text('Remaining Balance',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            currency.format(remaining),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),

          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: income == 0 ? 0 : (expense / income).clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            color: isOverspent ? Colors.red.shade200 : isWarning ? Colors.orange.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(4),
            minHeight: 5,
          ),

          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _StatChip(
              icon: Icons.arrow_downward_rounded,
              label: 'Total Income',
              amount: currency.format(income),
              color: const Color(0xFF4ECCA3),
            )),
            const SizedBox(width: 12),
            Expanded(child: _StatChip(
              icon: Icons.arrow_upward_rounded,
              label: 'Total Expense',
              amount: currency.format(expense),
              color: const Color(0xFFFF7B6E),
            )),
          ]),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
          Text(amount,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}