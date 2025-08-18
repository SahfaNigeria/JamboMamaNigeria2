import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpectedDeliveryScreen extends StatefulWidget {
  const ExpectedDeliveryScreen({super.key});

  @override
  _ExpectedDeliveryScreenState createState() => _ExpectedDeliveryScreenState();
}

class _ExpectedDeliveryScreenState extends State<ExpectedDeliveryScreen> {
  final TextEditingController _lmpController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    // setState(() {
    //   _lmpController.text = _dateFormat.format(selectedDate!);

    // });

    if (selectedDate != null) {
      setState(() {
        _lmpController.text = _dateFormat.format(selectedDate);
      });
    }
  }

  void _saveAndReturnEDD() {
    if (_lmpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select your last menstrual period date')),
      );
      return;
    }

    try {
      DateTime lmp = _dateFormat.parse(_lmpController.text);

      // Validate that LMP is not in the future
      if (lmp.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Last menstrual period cannot be in the future')),
        );
        return;
      }

      DateTime expectedDeliveryDate = lmp.add(const Duration(days: 280));
      String edd = _dateFormat.format(expectedDeliveryDate);
      Navigator.pop(context, edd);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoText('ERROR_18')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoText('DUE_DATE_CALC'),
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
                  height: 200,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _lmpController,
                  decoration:  InputDecoration(
                    labelText: autoI8lnGen.translate('SELECT_LAST_MENSTRUAL_PERIOD_FLOW'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAndReturnEDD,
              child: const AutoText('SAVE_CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }
}
