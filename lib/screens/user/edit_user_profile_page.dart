import 'package:flutter/material.dart';

class EditUserProfilePage extends StatelessWidget {
  const EditUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: const Center(
        child: Text(
          'Edit Profile Page - Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
