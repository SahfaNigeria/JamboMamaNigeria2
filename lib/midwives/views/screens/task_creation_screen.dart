import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _dueDate = '';
  String _status = 'Pending';

  Future<void> _saveTaskToFirestore() async {
    try {
      // Retrieve the current user's ID
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _title,
        'description': _description,
        'dueDate': _dueDate,
        'status': _status,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('TASK_CREATED')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('FAILED_CREATE_TASK $e')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  AutoText('CREATE_NEW_TASK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added for scrolling
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align widgets to the start
              children: [
                TextFormField(
                  decoration:  InputDecoration(labelText: autoI8lnGen.translate("TITLE_2")),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return autoI8lnGen.translate("LOGIN_VALIDATION_6");
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:  InputDecoration(
                    labelText: autoI8lnGen.translate("Description"),
                    border: OutlineInputBorder(), // Adds a border
                  ),
                  maxLines: 5, // Allows more space for description
                  keyboardType:
                      TextInputType.multiline, // Supports multiline input
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration:  InputDecoration(labelText: autoI8lnGen.translate("DUE_DATE")),
                  onSaved: (value) => _dueDate = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: [autoI8lnGen.translate("Pending"), autoI8lnGen.translate("Progress"), autoI8lnGen.translate("Completed")]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _status = value!),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _saveTaskToFirestore();
                    }
                  },
                  child: const AutoText('SaveTask'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
