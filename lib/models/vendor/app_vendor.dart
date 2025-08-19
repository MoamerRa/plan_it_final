import 'package:flutter/material.dart';

class AppVendor extends ChangeNotifier {
  String vendorId;
  String name;
  String namelowercase; // New field
  String email;
  String phone;
  String category;
  String description;
  String imageUrl;
  List<String> galleryUrls;
  double rating;
  double price;
  bool isApproved;

  AppVendor({
    required this.vendorId,
    required this.name,
    required this.email,
    required this.phone,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.galleryUrls,
    required this.rating,
    required this.price,
    required this.isApproved,
  }) : namelowercase = name.toLowerCase();

  factory AppVendor.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return AppVendor(
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      galleryUrls: List<String>.from(json['galleryUrls'] ?? []),
      rating: parseDouble(json['rating']),
      price: parseDouble(json['price']),
      isApproved: json['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'name': name,
      'name_lowercase': namelowercase, // Add to JSON
      'email': email,
      'phone': phone,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'galleryUrls': galleryUrls,
      'rating': rating,
      'price': price,
      'isApproved': isApproved,
    };
  }

  AppVendor copyWith({
    String? vendorId,
    String? name,
    String? email,
    String? phone,
    String? category,
    String? description,
    String? imageUrl,
    List<String>? galleryUrls,
    double? rating,
    double? price,
    bool? isApproved,
  }) {
    return AppVendor(
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryUrls: galleryUrls ?? List.from(this.galleryUrls),
      rating: rating ?? this.rating,
      price: price ?? this.price,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  void updateVendor(AppVendor updated) {
    name = updated.name;
    // ... update other fields
    notifyListeners();
  }
}
