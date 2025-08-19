import 'package:flutter/material.dart';

class BudgetCategoryTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final int amount;

  const BudgetCategoryTile({
    super.key,
    required this.icon,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3CD), // רקע זהוב בהיר
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.orange[800], // גוון כהה יותר לאייקון
                ),
              ),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(
            '$amount ₪',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
