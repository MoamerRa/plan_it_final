import 'package:flutter/material.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
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
    );
  }
}
