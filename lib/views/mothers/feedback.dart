import 'package:auto_i8ln/auto_i8ln.dart';
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
  String? _userRole = autoI8lnGen.translate("PATIENT");
  String? _feedbackType = autoI8lnGen.translate("SUGGESTION");

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
          .showSnackBar(SnackBar(content: AutoText('FEED_BACK_SUBMITTED')));

      // Clear the form
      _formKey.currentState!.reset();
      _userRole = autoI8lnGen.translate("PATIENT");
      _feedbackType = autoI8lnGen.translate("SUGGESTION");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('SUBMIT_FEEDBACK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(labelText: autoI8lnGen.translate("USER_ID")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return autoI8lnGen.translate("VALIDATION_Q_17");
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _userNameController,
                decoration: InputDecoration(labelText: autoI8lnGen.translate("USER_NAME")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return autoI8lnGen.translate("ENTER_NAME");
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _userRole,
                decoration: InputDecoration(labelText: autoI8lnGen.translate('USER_ROLE')),
                items: [autoI8lnGen.translate("PATIENT"), autoI8lnGen.translate('autoI8lnGen.translate')].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) => setState(() => _userRole = value),
              ),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                decoration: InputDecoration(labelText: autoI8lnGen.translate("FEED_BACK_TYPE")),
                items: [autoI8lnGen.translate("SUGGESTION"), autoI8lnGen.translate("BUG_REPORT"), autoI8lnGen.translate("GENERAL")].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _feedbackType = value),
              ),
              TextFormField(
                controller: _feedbackContentController,
                decoration: InputDecoration(labelText: autoI8lnGen.translate("FEEDBACK_CONTENT")),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return autoI8lnGen.translate("VALIDATION_Q_18");
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: AutoText('SUBMIT_FEEDBACK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
