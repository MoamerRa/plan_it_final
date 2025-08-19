// File: widgets/user_header.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserHeader extends StatelessWidget {
  final String username;

  const UserHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/up.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hello, $username!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'DancingScript',
                color: Color(0xFF1E2742),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
