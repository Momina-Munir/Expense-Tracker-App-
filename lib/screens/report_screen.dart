import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'transaction_provider.dart';
import '../screens/app_theme.dart';
import 'formatters.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryMap = ref.watch(categoryExpenseProvider);
    final trend = ref.watch(monthlyTrendProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthlyIncome = ref.watch(monthlyTransactionsProvider)
        .where((t) => !t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);
    final monthlyExpense = ref.watch(monthlyTransactionsProvider)
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly summary chips
            Row(
              children: [
                _MonthlyStat(
                    label: 'Income',
                    amount: monthlyIncome,
                    color: AppTheme.income),
                const SizedBox(width: 12),
                _MonthlyStat(
                    label: 'Expense',
                    amount: monthlyExpense,
                    color: AppTheme.expense),
              ],
            ),
            const SizedBox(height: 24),

            // Pie chart
            Text('Category Breakdown',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            categoryMap.isEmpty
                ? _NoData(label: 'No expenses this month')
                : _PieSection(categoryMap: categoryMap),

            const SizedBox(height: 24),

            // Monthly bar chart
            Text('6-Month Trend',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _BarTrend(trend: trend),
          ],
        ),
      ),
    );
  }
}

class _MonthlyStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _MonthlyStat(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(AppFormat.currency(amount),
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class _PieSection extends StatefulWidget {
  final Map<String, double> categoryMap;
  const _PieSection({required this.categoryMap});

  @override
  State<_PieSection> createState() => _PieSectionState();
}

class _PieSectionState extends State<_PieSection> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.categoryMap.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: entries.asMap().entries.map((e) {
                final isTouched = e.key == touchedIndex;
                final color = AppTheme
                    .catColors[e.key % AppTheme.catColors.length];
                return PieChartSectionData(
                  color: color,
                  value: e.value.value,
                  title: isTouched
                      ? '${(e.value.value / total * 100).toStringAsFixed(1)}%'
                      : '',
                  radius: isTouched ? 75 : 60,
                  titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                );
              }).toList(),
              sectionsSpace: 3,
              centerSpaceRadius: 50,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: entries.asMap().entries.map((e) {
            final color =
            AppTheme.catColors[e.key % AppTheme.catColors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('${e.value.key} (${AppFormat.currency(e.value.value)})',
                    style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BarTrend extends StatelessWidget {
  final List<Map<String, dynamic>> trend;
  const _BarTrend({required this.trend});

  @override
  Widget build(BuildContext context) {
    final maxVal = trend.fold(
        0.0,
            (m, e) =>
            [m, e['income'] as double, e['expense'] as double]
                .reduce((a, b) => a > b ? a : b));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white12
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxVal == 0 ? 100 : maxVal * 1.2,
                barGroups: trend.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value['income'],
                        color: AppTheme.income,
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: e.value['expense'],
                        color: AppTheme.expense,
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final month = trend[v.toInt()]['month'] as DateTime;
                        return Text(AppFormat.shortMonth(month),
                            style: const TextStyle(fontSize: 11));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppTheme.income, label: 'Income'),
              const SizedBox(width: 20),
              _Legend(color: AppTheme.expense, label: 'Expense'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _NoData extends StatelessWidget {
  final String label;
  const _NoData({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 48, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}