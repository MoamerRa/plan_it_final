import 'package:flutter/material.dart';

class OverviewBox extends StatelessWidget {
  final String title;
  final String main;
  final String sub;
  final IconData icon;

  const OverviewBox({
    super.key,
    required this.title,
    required this.main,
    required this.sub,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 170,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(255, 233, 229, 209),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color.fromARGB(231, 190, 142, 0)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(main,
                style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(231, 190, 142, 0),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
