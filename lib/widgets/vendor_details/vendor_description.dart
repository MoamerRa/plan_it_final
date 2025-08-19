import 'package:flutter/material.dart';

class VendorDescription extends StatelessWidget {
  final String description;

  const VendorDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
