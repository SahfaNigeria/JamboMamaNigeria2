import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailsScreen({Key? key, required this.task}) : super(key: key);

  Future<void> _markAsCompleted(BuildContext context) async {
    try {
      final taskId = task['id']; // Ensure the task contains an 'id' field

      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update({'status': 'Completed'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoText('TASKED_MARKED_COMPLETE')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('FAILED_TASK_UPDATE $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText(task['title'] ?? 'NO_TITLE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoText(
              'DUE_DATE ${task['dueDate'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            AutoText(
              'Description ${task['description'] ?? 'No description provided.'}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _markAsCompleted(context);
                Navigator.pop(context);
              },
              child: const AutoText('Mark_AS_COMPLETED'),
            ),
          ],
        ),
      ),
    );
  }
}
