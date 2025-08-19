import 'package:flutter/material.dart';

class VendorImageHeader extends StatelessWidget {
  final String image;
  const VendorImageHeader({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
