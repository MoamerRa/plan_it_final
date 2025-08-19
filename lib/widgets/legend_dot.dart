import 'package:flutter/material.dart';

class LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const LegendDot({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
