import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'summary_card.dart';
import 'transaction_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      body: transactions.isEmpty
          ? const _EmptyState()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: const SummaryCard()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Recent Transactions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => TransactionTile(tx: transactions[i]),
                    childCount: transactions.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SummaryCard(),
          const SizedBox(height: 40),
          Icon(Icons.receipt_long_rounded,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to get started',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
