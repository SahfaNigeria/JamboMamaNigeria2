import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class ExpectedDeliveryScreen extends StatefulWidget {
  const ExpectedDeliveryScreen({super.key});

  @override
  _ExpectedDeliveryScreenState createState() {
    return _ExpectedDeliveryScreenState();
  }
}

class _ExpectedDeliveryScreenState extends State<ExpectedDeliveryScreen> {
  final TextEditingController _lmpController = TextEditingController();
  String _expectedDeliveryDate = '';
  final DateFormat _dateFormat =
      DateFormat('dd-MM-yyyy'); // Define the date format

  void _calculateExpectedDeliveryDate() {
    try {
      DateTime lmp = _dateFormat.parse(_lmpController.text); // Parse the date
      DateTime expectedDeliveryDate =
          lmp.add(const Duration(days: 280)); // 280 days is roughly 40 weeks
      setState(() {
        _expectedDeliveryDate = _dateFormat.format(expectedDeliveryDate);
        _lmpController.clear(); // Clear the input field// Format the result
      });
    } catch (e) {
      // Handle the error if the date format is incorrect
      setState(() {
        _expectedDeliveryDate = 'Invalid date format';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && selectedDate != currentDate) {
      setState(() {
        _lmpController.text = _dateFormat.format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Due Date Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Newborn baby image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/newborn.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context), // Open date picker on tap
              child: AbsorbPointer(
                child: TextField(
                  controller: _lmpController,
                  decoration: const InputDecoration(
                    labelText: 'Select Last Menstrual Period (DD-MM-YYYY)',
                  ),
                  keyboardType: TextInputType.none, // Disable keyboard
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateExpectedDeliveryDate,
              child: Text('Calculate'),
            ),
            SizedBox(height: 20),
            Text(
              _expectedDeliveryDate.isNotEmpty
                  ? 'Your baby is expected on: $_expectedDeliveryDate. He/She may come much earlier or a bit later, be ready'
                  : '',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
