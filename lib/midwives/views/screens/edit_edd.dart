import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExpectedDeliveryScreen extends StatefulWidget {
  const EditExpectedDeliveryScreen({super.key});

  @override
  _EditExpectedDeliveryScreenState createState() =>
      _EditExpectedDeliveryScreenState();
}

class _EditExpectedDeliveryScreenState
    extends State<EditExpectedDeliveryScreen> {
  final TextEditingController _lmpController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  User? user = FirebaseAuth.instance.currentUser;

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

  Future<void> _saveAndUpdateEDD() async {
    if (_lmpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: AutoText('V_L_M_P')),
      );
      return;
    }

    try {
      DateTime lmp = _dateFormat.parse(_lmpController.text);

      if (lmp.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: AutoText('LAST_MENSTRUAL_PERIOD')),
        );
        return;
      }

      DateTime expectedDeliveryDate = lmp.add(const Duration(days: 280));
      String edd = _dateFormat.format(expectedDeliveryDate);

      // ✅ Save to Firestore
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'lmp': _lmpController.text,
          'edd': edd,
        });
      }

      Navigator.pop(context, edd); // return the new EDD
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
        title: const AutoText('EDIT_DUE_DATE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            ElevatedButton(
              onPressed: _saveAndUpdateEDD,
              child: const AutoText('SAVE_CHANGES'),
            ),
          ],
        ),
      ),
    );
  }
}
