import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:planit_mt/models/event_model.dart';
import 'package:planit_mt/models/expense_model.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/expense_provider.dart';
import 'package:planit_mt/widgets/budget/budget_category_tile.dart';
import 'package:provider/provider.dart';

class BudgetBreakdownPage extends StatelessWidget {
  const BudgetBreakdownPage({super.key});

  // Helper to map category names to icons
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'hall':
        return Icons.party_mode;
      case 'dj':
        return Icons.music_note;
      case 'catering':
        return Icons.fastfood;
      case 'photography':
        return Icons.camera_alt;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.receipt_long; // Default icon
    }
  }

  // Helper to get a color for the pie chart based on index
  Color _getColorForIndex(int index) {
    final colors = [
      Colors.amber,
      Colors.redAccent,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final EventModel? activeEvent = eventProvider.activeEvent;

    final currencyFormatter =
        NumberFormat.currency(locale: 'he_IL', symbol: '₪', decimalDigits: 0);

    // Calculate category totals from the expense provider
    final categoryTotals = _getCategoryTotals(expenseProvider.expenses);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Budget Breakdown',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: activeEvent == null
          ? _buildNoEventState(context)
          : _buildBudgetDetails(context, activeEvent, expenseProvider,
              currencyFormatter, categoryTotals),
    );
  }

  Map<String, double> _getCategoryTotals(List<Expense> expenses) {
    final categoryMap = <String, double>{};
    for (var expense in expenses) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return categoryMap;
  }

  Widget _buildNoEventState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.money_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Create an event to manage your budget.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/createEvent'),
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDetails(
      BuildContext context,
      EventModel activeEvent,
      ExpenseProvider expenseProvider,
      NumberFormat currencyFormatter,
      Map<String, double> categoryTotals) {
    final remainingBudget = activeEvent.totalBudget - activeEvent.spentBudget;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Budget: ${currencyFormatter.format(activeEvent.totalBudget)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Spent: ${currencyFormatter.format(activeEvent.spentBudget)}   |   Remaining: ${currencyFormatter.format(remainingBudget)}',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (categoryTotals.isEmpty)
            const Center(child: Text("No expenses recorded yet."))
          else
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                  sections: _getPieChartSections(
                      categoryTotals, activeEvent.totalBudget),
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._getCategoryTiles(categoryTotals),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(
      Map<String, double> categoryTotals, double totalBudget) {
    if (totalBudget == 0) return [];
    int index = 0;
    return categoryTotals.entries.map((entry) {
      final percent = (entry.value / totalBudget * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: _getColorForIndex(index++),
        value: entry.value,
        title: '${entry.key}\n$percent%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }).toList();
  }

  List<Widget> _getCategoryTiles(Map<String, double> categoryTotals) {
    return categoryTotals.entries.map((entry) {
      return BudgetCategoryTile(
        icon: _getIconForCategory(entry.key),
        name: entry.key,
        amount: entry.value.toInt(),
      );
    }).toList();
  }
}
