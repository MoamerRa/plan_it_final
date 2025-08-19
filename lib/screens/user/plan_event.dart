import 'package:flutter/material.dart';
import 'package:planit_mt/providers/task_provider.dart';
import 'package:planit_mt/widgets/budget_box.dart';
import 'package:planit_mt/widgets/guest_pie_chart.dart';
import 'package:provider/provider.dart';

class PlanEvent extends StatelessWidget {
  const PlanEvent({super.key});

  @override
  Widget build(BuildContext context) {
    // Connect to the TaskProvider to get task data
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Event Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== התיקון כאן ==================
            // This section now displays real task data
            _buildTasksSection(context, taskProvider),
            // ===============================================
            const SizedBox(height: 16),
            BudgetBox(onTap: () => Navigator.pushNamed(context, '/budget')),
            const SizedBox(height: 24),
            const Card(
              color: Color(0xFFFFF9E6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: GuestPieChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, TaskProvider taskProvider) {
    final progress = taskProvider.totalTasks > 0
        ? taskProvider.completedTasks / taskProvider.totalTasks
        : 0.0;

    return Card(
      color: const Color(0xFFFFF9E6),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Tasks',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/tasks'),
                  child: const Text('View All >'),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
                '${taskProvider.completedTasks} of ${taskProvider.totalTasks} completed'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 16),
            taskProvider.tasks.isEmpty
                ? const Text("No tasks yet. Tap 'View All' to add one.")
                : Text(
                    'Next up: ${taskProvider.incompleteTasks.first.title}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
          ],
        ),
      ),
    );
  }
}
