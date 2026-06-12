import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'transaction_screen.dart';
import 'report_screen.dart';
import 'add_transaction_sheet.dart';
import 'app.dart';

final _navIndexProvider = StateProvider<int>((ref) => 0);

const _titles = ['Expense Tracker', 'Transactions', 'Reports'];

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_navIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[index]),
        actions: [
          // Dark/Light mode toggle
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? const Color(0xFFFFC857) : const Color(0xFF6C63FF),
              ),
            ),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : const Color(0xFFEEEEF5),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) {
            ref.read(_navIndexProvider.notifier).state = i;
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt_rounded),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
          ],
        ),
      ),
      // Single FAB only
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const AddTransactionSheet(),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
