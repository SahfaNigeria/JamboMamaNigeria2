import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserFeedbackForm extends StatefulWidget {
  @override
  _UserFeedbackFormState createState() => _UserFeedbackFormState();
}

class _UserFeedbackFormState extends State<UserFeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _feedbackContentController =
      TextEditingController();
  String? _userRole = "Patient";
  String? _feedbackType = "Suggestion";

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      // Prepare data
      Map<String, dynamic> feedbackData = {
        'userId': _userIdController.text,
        'userName': _userNameController.text,
        'userRole': _userRole,
        'feedbackType': _feedbackType,
        'feedbackContent': _feedbackContentController.text,
        'dateSubmitted': Timestamp.now(),
        'status': 'New',
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('user_feedback')
          .add(feedbackData);

      // Show confirmation
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Feedback submitted!')));

      // Clear the form
      _formKey.currentState!.reset();
      _userRole = "Patient";
      _feedbackType = "Suggestion";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: 'User ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your User ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: 'User Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _userRole,
                decoration: InputDecoration(labelText: 'User Role'),
                items: ["Patient", "Provider"].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => setState(() => _userRole = value),
              ),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                decoration: InputDecoration(labelText: 'Feedback Type'),
                items: ["Suggestion", "Bug Report", "General"].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _feedbackType = value),
              ),
              TextFormField(
                controller: _feedbackContentController,
                decoration: InputDecoration(labelText: 'Feedback Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
