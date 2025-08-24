import 'package:flutter/material.dart';
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

  /// Fetches all tasks from the local SQLite database.
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    final taskMaps = await SQLiteHelper.getAllTasks();
    _tasks = taskMaps.map((map) => Task.fromMap(map)).toList();
    _isLoading = false;
    notifyListeners();
  }

  /// Adds a new task to the database and refreshes the list.
  Future<void> addTask(String title) async {
    final newTask = Task(title: title);
    await SQLiteHelper.insertTask(newTask);
    await fetchTasks(); // Refresh the list from the database
  }

  /// Updates the completion status of a task.
  Future<void> toggleTaskStatus(Task task) async {
    task.isCompleted = !task.isCompleted;
    await SQLiteHelper.updateTask(task);
    await fetchTasks(); // Refresh the list
  }

  /// Deletes a task from the database.
  Future<void> deleteTask(int id) async {
    await SQLiteHelper.deleteTask(id);
    await fetchTasks(); // Refresh the list
  }

  // ================== FIX FOR ISSUE #2 (Part 3) ==================
  /// Clears the tasks from the provider's state.
  /// This should be called along with clearing the database on logout.
  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
  // ================================================================
}
