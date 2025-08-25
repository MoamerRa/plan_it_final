import 'package:flutter/material.dart';
import 'package:planit_mt/models/booking_model.dart';
import 'package:planit_mt/screens/user/plan_event.dart';
import '../models/task_model.dart';
import '../services/sqlite_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  List<Task> get incompleteTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  TaskProvider();

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    final taskMaps = await SQLiteHelper.getAllTasks();
    _tasks = taskMaps.map((map) => Task.fromMap(map)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    final newTask = Task(title: title);
    await SQLiteHelper.insertTask(newTask);
    await fetchTasks();
  }

  Future<void> toggleTaskStatus(Task task) async {
    task.isCompleted = !task.isCompleted;
    await SQLiteHelper.updateTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await SQLiteHelper.deleteTask(id);
    await fetchTasks();
  }

  // ================== FIX FOR ISSUE #2 ==================
  // This new method synchronizes the local SQLite tasks with the confirmed bookings from Firestore.
  Future<void> syncTasksWithBookings(
      List<BookingModel> confirmedBookings) async {
    final existingTasks = await SQLiteHelper.getAllTasks();
    final existingTaskTitles = existingTasks.map((t) => t['title']).toSet();

    // Get the set of completed checklist item titles based on confirmed bookings
    final completedChecklistTitles = PlanEvent.checklistItems.entries
        .where((entry) =>
            confirmedBookings.any((b) => b.vendorCategory == entry.key))
        .map((entry) => entry.value)
        .toSet();

    for (String title in completedChecklistTitles) {
      // If a task for this completed item doesn't exist, create it and mark as complete.
      if (!existingTaskTitles.contains(title)) {
        final newTask = Task(title: title, isCompleted: true);
        await SQLiteHelper.insertTask(newTask);
      }
    }

    // After syncing, refresh the task list in the provider.
    await fetchTasks();
  }
  // ======================================================

  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
}
