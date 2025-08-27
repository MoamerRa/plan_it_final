import 'package:flutter/material.dart';

class VendorImageHeader extends StatelessWidget {
  final String image;
  final String vendorName; // <-- ADDED
  const VendorImageHeader(
      {super.key, required this.image, required this.vendorName}); // <-- ADDED

  @override
  Widget build(BuildContext context) {
    // If the image URL is empty, show a nice placeholder with the vendor's name.
    if (image.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            vendorName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    // If the image URL exists, try to load it from the network.
    return Image.network(
      image,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 250,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
          ),
        );
      },
    );
  }
}
