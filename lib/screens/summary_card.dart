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

    // Beautiful gradient colors
    List<Color> gradientColors;
    if (isOverspent) {
      gradientColors = [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)];
    } else if (isWarning) {
      gradientColors = [const Color(0xFFFFB347), const Color(0xFFFFCC7A)];
    } else {
      gradientColors = [const Color(0xFF6C63FF), const Color(0xFF9B94FF)];
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning banner
          if (isOverspent) ...[
            _warningBanner(Icons.warning_amber_rounded, 'Overspent! You have exceeded your income.'),
            const SizedBox(height: 12),
          ] else if (isWarning) ...[
            _warningBanner(Icons.info_outline_rounded, 'Less than 10% balance remaining!'),
            const SizedBox(height: 12),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('This Month',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            currency.format(remaining),
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: income == 0 ? 0 : (expense / income).clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            color: isOverspent
                ? Colors.red.shade200
                : isWarning
                    ? Colors.orange.shade200
                    : Colors.white,
            borderRadius: BorderRadius.circular(4),
            minHeight: 5,
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: _StatChip(
              icon: Icons.arrow_downward_rounded,
              label: 'Total Income',
              amount: currency.format(income),
              color: const Color(0xFF7EFFD4),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _StatChip(
              icon: Icons.arrow_upward_rounded,
              label: 'Total Expense',
              amount: currency.format(expense),
              color: const Color(0xFFFFB3B3),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _warningBanner(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(message,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
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

  const _StatChip(
      {required this.icon,
      required this.label,
      required this.amount,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
              Text(amount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ])),
      ]),
    );
  }
}
