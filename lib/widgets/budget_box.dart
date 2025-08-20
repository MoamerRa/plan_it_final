import 'package:flutter/material.dart';
import 'package:planit_mt/widgets/legend_dot.dart';

// MODIFIED: Converted to a StatelessWidget that accepts data
class BudgetBox extends StatelessWidget {
  final double totalBudget;
  final double spentBudget;
  final VoidCallback onTap;

  const BudgetBox({
    super.key,
    required this.totalBudget,
    required this.spentBudget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalBudget - spentBudget;
    final spentPercent = totalBudget > 0 ? spentBudget / totalBudget : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Budget',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E2742))),
              TextButton(
                onPressed: onTap,
                child: const Text('View More >',
                    style: TextStyle(color: Colors.redAccent)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Budget',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${totalBudget.toStringAsFixed(0)} ₪',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD5B04C))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spent',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${spentBudget.toStringAsFixed(0)} ₪',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF941B2E))),
                  Text('Remaining - ${remainingBudget.toStringAsFixed(0)} ₪'),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // Animated progress bar
          Container(
            height: 10,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                // The bar representing the spent amount
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: MediaQuery.of(context).size.width * spentPercent,
                  decoration: BoxDecoration(
                    color: const Color(0xFF941B2E),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              LegendDot(color: Color(0xFF941B2E), text: 'Spent'),
              LegendDot(color: Color(0xFFE0E0E0), text: 'Remaining'),
            ],
          ),
        ],
      ),
    );
  }
}
