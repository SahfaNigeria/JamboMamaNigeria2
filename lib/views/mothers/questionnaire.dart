import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PregnantFeelingsForm extends StatelessWidget {
  const PregnantFeelingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Feelings Form'),
      ),
      body: const FeelingsForm(),
    );
  }
}

class FeelingsForm extends StatefulWidget {
  const FeelingsForm({super.key});

  @override
  _FeelingsFormState createState() => _FeelingsFormState();
}

class _FeelingsFormState extends State<FeelingsForm> {
  final List<String> _questions = [
    "Are you feeling well today?",
    "Are you experiencing any discomfort?",
    "Do you feel tired or fatigued?",
    "Are you experiencing any mood swings?",
    "Do you have any cravings or aversions?",
    "Are you experiencing any nausea or morning sickness?",
    "Are you getting enough restful sleep?",
    "Do you feel stressed or anxious?",
    "Are you feeling baby movements regularly?",
    "Do you have any concerns about your pregnancy?"
  ];

  final List<String> _responses = List.filled(10, '');
  final List<bool> _isAnswered = List.filled(10, true);

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'Today is: ',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Center(
                  child: Text(
                      '${now.year}-${_formatTwoDigits(now.month)}-${_formatTwoDigits(now.day)}',
                      style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < 10; i++) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isAnswered[i]
                          ? Colors.grey
                          : Colors.red, // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius:
                        BorderRadius.circular(10.0), // Optional: Border radius
                  ),
                  child: Column(
                    children: [
                      Text(
                        ' ${_questions[i]}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green.shade600, // background
                            ),
                            onPressed: () {
                              _updateResponse(i, 'Yes');
                            },
                            child: const Text(
                              'Yes',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // background
                            ),
                            onPressed: () {
                              _updateResponse(i, 'No');
                            },
                            child: const Text('No',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // background
                              ),
                              onPressed: () {
                                _updateResponse(i, 'Same as before');
                              },
                              child: const Text(
                                'Same as before',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_responses[i]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ],
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _updateResponse(int index, String response) {
    setState(() {
      _responses[index] = response;
      _isAnswered[index] = true;
    });
  }

  void _submitForm() async {
    bool isValid = true;
    for (int i = 0; i < _responses.length; i++) {
      if (_responses[i].isEmpty) {
        setState(() {
          _isAnswered[i] = false;
        });
        isValid = false;
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please answer all questions before submitting.')),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        CollectionReference feelings = FirebaseFirestore.instance
            .collection('Mother Pregnancy Data')
            .doc(userId)
            .collection('Mother Periodic Feelings Form');

        await feelings.add({
          'date':
              '${now.year}-${_formatTwoDigits(now.month)}-${_formatTwoDigits(now.day)}',
          'responses': _responses,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit form: $e')),
      );
    }
  }

//   void _submitForm() async {
//     bool isValid = true;
//     for (int i = 0; i < _responses.length; i++) {
//       if (_responses[i].isEmpty) {
//         setState(() {
//           _isAnswered[i] = false;
//         });
//         isValid = false;
//       }
//     }

//     if (!isValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please answer all questions before submitting.')),
//       );
//       return;
//     }

//     CollectionReference feelings =
//         FirebaseFirestore.instance.collection('Mother feelings form');

//     await feelings.add({
//       'date':
//           '${now.year}-${_formatTwoDigits(now.month)}-${_formatTwoDigits(now.day)}',
//       'responses': _responses,
//     }).then((value) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Form submitted successfully!')),
//       );
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to submit form: $error')),
//       );
//     });
//   }
// }

  String _formatTwoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

// Helper function to format single digit values with leading zero
}
