import 'package:flutter/material.dart';

class VendorBookingButton extends StatelessWidget {
  const VendorBookingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 241, 205, 114),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          foregroundColor: Colors.black,
        ),
        onPressed: () {},
        label: const Text('Confirm Booking'),
      ),
    );
  }
}
