import 'package:flutter/material.dart';

class VendorContact extends StatelessWidget {
  final String phone;
  final String email;

  const VendorContact({super.key, required this.phone, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Vendor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.phone),
          title: Text(phone),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: Text(email),
          onTap: () {},
        ),
      ],
    );
  }
}
