import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
    };
  }

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      category: data['category'] ?? 'Uncategorized',
      description: data['description'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
