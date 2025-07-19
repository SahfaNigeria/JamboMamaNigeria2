import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ReportEventForm extends StatefulWidget {
  final String userName;

  const ReportEventForm({super.key, required this.userName});

  @override
  _ReportEventFormState createState() => _ReportEventFormState();
}

class _ReportEventFormState extends State<ReportEventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  String? _selectedEventType;
  DateTime? _selectedDate;

  // Dummy event types list
  final List<String> _eventTypes = [
    "Bleeding",
    "Pain",
    "Contractions",
    "Swelling",
    "Dizziness",
    "Other"
  ];

  // Function to pick a date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Submit the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process and send data to Firebase or backend
      final eventReport = {
        'patient_name': widget.userName,
        'event_type': _selectedEventType,
        'description': _descriptionController.text,
        'date': _selectedDate != null
            ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
            : null,
        'comments': _commentsController.text.isNotEmpty
            ? _commentsController.text
            : null,
      };

      print(eventReport); // For now, just printing the report data

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Event reported successfully!"),
      ));

      // Clear form after submission
      _formKey.currentState!.reset();
      setState(() {
        _selectedEventType = null;
        _selectedDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('R_E_D'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AutoText('P_NAME ${widget.userName}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                hint: AutoText('S_E_T'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEventType = newValue;
                  });
                },
                items:
                    _eventTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: AutoText(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? autoI8lnGen.translate("P_S_E_T") : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: autoI8lnGen.translate("E_V_D_E"),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return autoI8lnGen.translate("P_E_V_D_E");
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AutoText(
                      _selectedDate != null
                          ? 'E_V_D ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}'
                          : 'N_D_S',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _commentsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: autoI8lnGen.translate("A_C"),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: AutoText('S_R'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
