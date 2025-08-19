import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalSpent =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  Future<void> fetchExpenses(String userId, String eventId) async {
    _isLoading = true;
    notifyListeners();
    _expenses = await _firestoreService.getExpenses(userId, eventId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(
      String userId, String eventId, Expense expense) async {
    _isLoading = true;
    notifyListeners();
    await _firestoreService.addExpense(userId, eventId, expense);
    await fetchExpenses(userId, eventId); // Refresh list
    // Update the total spent on the main event document
    await _firestoreService.updateEventSpentBudget(
        userId, eventId, totalSpent);
  }

  Future<void> deleteExpense(
      String userId, String eventId, String expenseId) async {
    _isLoading = true;
    notifyListeners();
    await _firestoreService.deleteExpense(userId, eventId, expenseId);
    await fetchExpenses(userId, eventId); // Refresh list
    // Update the total spent on the main event document
    await _firestoreService.updateEventSpentBudget(
        userId, eventId, totalSpent);
  }
}
