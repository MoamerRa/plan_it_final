import 'package:flutter/material.dart';
import 'package:planit_mt/widgets/task_card.dart';

class TasksSection extends StatelessWidget {
  const TasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/task'),
              child: const Text('Add Task'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const SizedBox(
          height: 190,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TaskCard(
                  title: 'Food Menu',
                  status: 'Pending',
                  color: Colors.orange,
                  imagePath: 'assets/images/food.png',
                ),
                TaskCard(
                  title: 'Guest List',
                  status: 'Completed',
                  color: Colors.green,
                  imagePath: 'assets/images/guest.png',
                ),
                TaskCard(
                  title: 'Vendor',
                  status: 'Completed',
                  color: Colors.green,
                  imagePath: 'assets/images/vendor.png',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
