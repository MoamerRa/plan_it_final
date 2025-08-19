import 'package:flutter/material.dart';
import 'package:planit_mt/widgets/legend_dot.dart';

// 1. הפכנו ל-StatefulWidget
class BudgetBox extends StatefulWidget {
  final VoidCallback onTap;

  const BudgetBox({super.key, required this.onTap});

  @override
  State<BudgetBox> createState() => _BudgetBoxState();
}

class _BudgetBoxState extends State<BudgetBox> {
  // משתני מצב לניהול התקציב
  double _estimatedCost = 170000;
  final double _finalCost = 210000;
  final double _paidAmount = 65000;

  void _showEditBudgetDialog() {
    final controller =
        TextEditingController(text: _estimatedCost.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Estimated Budget"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Amount (₪)",
              prefixText: "₪",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = double.tryParse(controller.text);
                if (newAmount != null) {
                  setState(() {
                    _estimatedCost = newAmount;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // חישוב האחוזים
    final paidPercent = _paidAmount / _finalCost;
    final estimatedPercent = _estimatedCost / _finalCost;

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
                onPressed: widget.onTap,
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
                  const Text('Estimated Cost',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${_estimatedCost.toStringAsFixed(0)} ₪',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD5B04C))),
                  // 2. כפתור העריכה
                  GestureDetector(
                    onTap: _showEditBudgetDialog,
                    child: const Text('Edit',
                        style: TextStyle(
                            color: Colors.purple,
                            decoration: TextDecoration.underline)),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Final Cost',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${_finalCost.toStringAsFixed(0)} ₪',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD5B04C))),
                  Text('Paid - ${_paidAmount.toStringAsFixed(0)} ₪'),
                  Text(
                      'Pending - ${(_finalCost - _paidAmount).toStringAsFixed(0)} ₪')
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // 3. הבר האנימטיבי
          Container(
            height: 10,
            clipBehavior: Clip.hardEdge, // חשוב לפינות מעוגלות
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                // בר התקציב המוערך
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: MediaQuery.of(context).size.width * estimatedPercent,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5B04C),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // בר התשלום
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: MediaQuery.of(context).size.width * paidPercent,
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
              LegendDot(color: Color(0xFF941B2E), text: 'Paid'),
              LegendDot(color: Color(0xFFD5B04C), text: 'Estimated'),
              LegendDot(color: Color(0xFFE0E0E0), text: 'Remaining'),
            ],
          ),
        ],
      ),
    );
  }
}
