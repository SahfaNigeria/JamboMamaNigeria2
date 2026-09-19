import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestExpectedDeliveryScreen extends StatefulWidget {
  const GuestExpectedDeliveryScreen({super.key});

  @override
  _GuestExpectedDeliveryScreenState createState() =>
      _GuestExpectedDeliveryScreenState();
}

class _GuestExpectedDeliveryScreenState
    extends State<GuestExpectedDeliveryScreen> {
  final TextEditingController _lmpController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  String? _calculatedEDD;

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _lmpController.text = _dateFormat.format(selectedDate);
      });
    }
  }

  void _calculateEDD() {
    if (_lmpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('SELECT_LAST_MENSTRUAL_PERIOD_FLOW')),
      );
      return;
    }

    try {
      DateTime lmp = _dateFormat.parse(_lmpController.text);

      // Validate that LMP is not in the future
      if (lmp.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  AutoText('LAST_MENSTRUAL_PERIOD_CANNOT_BE_IN_THE_FUTURE')),
        );
        return;
      }

      DateTime expectedDeliveryDate = lmp.add(const Duration(days: 280));
      setState(() {
        _calculatedEDD = _dateFormat.format(expectedDeliveryDate);
      });

      // Show info message about creating account
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText("PLEASE_CREATE_ACCOUNT_2"),
          backgroundColor: Colors.red[600],
        ),
      );
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

            // Select date field
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _lmpController,
                  decoration: InputDecoration(
                    labelText: autoI8lnGen
                        .translate('SELECT_LAST_MENSTRUAL_PERIOD_FLOW'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Calculate button
            ElevatedButton(
              onPressed: _calculateEDD,
              child: const AutoText('CALCULATE'),
            ),
            const SizedBox(height: 20),

            // Show calculated EDD result
            if (_calculatedEDD != null)
              Column(
                children: [
                  AutoText(
                    'EXPECTED_DELIVERY_DATE',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _calculatedEDD!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
