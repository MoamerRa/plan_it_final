import 'package:flutter/material.dart';

class VendorInfoSection extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final double rating;

  const VendorInfoSection({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$category   •   $price ₪',
            style: const TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(rating.toString(), style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: Colors.amber),
          ],
        ),
      ],
    );
  }
}
