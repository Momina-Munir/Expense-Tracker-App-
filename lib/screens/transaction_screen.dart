import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'transaction_tile.dart';
import 'formatters.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    // Group by date
    final Map<String, List<dynamic>> grouped = {};
    for (final tx in transactions) {
      final key = AppFormat.date(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final groupedEntries = grouped.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              final cur = ref.read(selectedMonthProvider);
              ref.read(selectedMonthProvider.notifier).state =
                  DateTime(cur.year, cur.month - 1);
            },
          ),
          Center(
            child: Text(
              AppFormat.monthYear(selectedMonth),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              final cur = ref.read(selectedMonthProvider);
              final next = DateTime(cur.year, cur.month + 1);
              if (!next.isAfter(DateTime.now())) {
                ref.read(selectedMonthProvider.notifier).state = next;
              }
            },
          ),
        ],
      ),
      body: transactions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text('No transactions',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: groupedEntries.length,
        itemBuilder: (_, i) {
          final entry = groupedEntries[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...entry.value
                  .map((tx) => TransactionTile(tx: tx))
                  .toList(),
            ],
          );
        },
      ),
    );
  }
}