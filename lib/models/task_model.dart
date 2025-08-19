// Represents a single to-do task for an event.
class Task {
  final int? id; // Nullable for new tasks that don't have an ID yet.
  final String title;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.isCompleted = false,
  });

  // Converts a Task object into a Map object for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      // Convert boolean to integer for SQLite compatibility (0 for false, 1 for true).
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Creates a Task object from a Map object retrieved from the database.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      // Convert integer back to boolean.
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
