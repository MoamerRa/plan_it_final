class VendorInfo {
  final String name;
  final String category;

  VendorInfo({
    required this.name,
    required this.category,
  });
}

class RecommendedPackage {
  final String name;
  final DateTime date;
  final double totalPrice;
  final List<VendorInfo> vendors;

  RecommendedPackage({
    required this.name,
    required this.date,
    required this.totalPrice,
    required this.vendors,
  });
}
