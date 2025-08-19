import 'package:flutter/material.dart';
import 'vendor_card.dart';

class VendorList extends StatelessWidget {
  const VendorList({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 4),
          VendorCard(title: 'Hall', imagePath: 'assets/images/hallv.png'),
          SizedBox(width: 16),
          VendorCard(title: 'DJ', imagePath: 'assets/images/djv.png'),
          SizedBox(width: 16),
          VendorCard(title: 'Caterer', imagePath: 'assets/images/cate.png'),
          SizedBox(width: 16),
          VendorCard(title: 'Photography', imagePath: 'assets/images/phot.png'),
          SizedBox(width: 16),
          VendorCard(title: 'Clothing', imagePath: 'assets/images/cloth.png'),
          SizedBox(width: 16),
          VendorCard(title: 'Decor', imagePath: 'assets/images/decor.png'),
          SizedBox(width: 16),
          VendorCard(title: 'Makeup', imagePath: 'assets/images/makeup.png'),
          SizedBox(width: 4),
        ],
      ),
    );
  }
}
