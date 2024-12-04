import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:jambomama_nigeria/midwives/views/screens/task_creation_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/task_details_screen.dart';

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskCreationScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          }

          final tasks = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id, // Store document ID if needed for editing/deletion
              'title': data['title'] ?? '',
              'dueDate': data['dueDate'] ?? '',
              'status': data['status'] ?? 'Pending',
              'description': data['description'] ?? ''
            };
          }).toList();

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Text('Due: ${task['dueDate']}'),
                  trailing: Chip(
                    label: Text(task['status']),
                    backgroundColor: task['status'] == 'Completed'
                        ? Colors.green
                        : task['status'] == 'In Progress'
                            ? Colors.orange
                            : Colors.red,
                  ),
                  onTap: () {
                    // Navigate to Task Details Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsScreen(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
