import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PregnantFeelingsForm extends StatelessWidget {
  final String requesterId;
  const PregnantFeelingsForm({Key? key, required this.requesterId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Feelings Form'),
      ),
      body: FeelingsForm(requesterId: requesterId),
    );
  }
}

class FeelingsForm extends StatefulWidget {
  final String requesterId;
  const FeelingsForm({super.key, required this.requesterId});

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
  final List<String> _medicalResponses = List.filled(10, '');
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
                      const SizedBox(height: 10),
                      Text(
                        _medicalResponses[i],
                        style: const TextStyle(
                            fontSize: 14, color: Colors.blueAccent),
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
      _medicalResponses[index] = _triggerMedicalResponse(index, response);
    });
  }

  String _triggerMedicalResponse(int index, String response) {
    switch (index) {
      case 0:
        return response == 'Yes'
            ? "It's great that you're feeling well! Continue to monitor any changes."
            : response == 'No'
                ? "Please monitor your symptoms closely. If your condition worsens, seek medical attention."
                : "If you're consistently feeling unwell, please consult your healthcare provider.";
      case 1:
        return response == 'Yes'
            ? "Pregnancy-related discomfort is common, but if it's severe, consider discussing it with your doctor."
            : response == 'No'
                ? "That's good to hear! If you start feeling discomfort, track when and how often."
                : "If the discomfort persists, it’s recommended to seek advice from your healthcare provider.";
      case 2:
        return response == 'Yes'
            ? "Fatigue is common, but ensure you're getting enough rest. If it becomes overwhelming, consult your doctor."
            : response == 'No'
                ? "Staying energized is positive! Maintain your current routine and adjust if needed."
                : "If fatigue continues at the same level, consider adjusting your routine or speaking with a medical professional.";
      case 3:
        return response == 'Yes'
            ? "Hormonal changes can cause mood swings. If they're affecting your well-being, consider counseling or medical advice."
            : response == 'No'
                ? "Maintaining stable moods is great! Continue engaging in activities that support emotional well-being."
                : "If mood swings continue, relaxation techniques or speaking to a professional may help.";
      case 4:
        return response == 'Yes'
            ? "Cravings and aversions are normal. Ensure your diet remains balanced and consult your doctor if you're worried."
            : response == 'No'
                ? "A balanced diet is ideal during pregnancy. Continue focusing on nutrition."
                : "If your cravings or aversions remain the same, keep tracking them and ensure you're eating healthily.";
      case 5:
        return response == 'Yes'
            ? "Morning sickness is common in pregnancy, but if it's severe or persistent, consult your healthcare provider."
            : response == 'No'
                ? "It's good you're not experiencing nausea. Continue monitoring for any changes."
                : "If nausea remains, try small, frequent meals and consult your doctor if necessary.";
      case 6:
        return response == 'Yes'
            ? "Good sleep is essential. Keep maintaining a healthy sleep routine."
            : response == 'No'
                ? "Try improving your sleep environment and routine. If sleep deprivation continues, talk to your healthcare provider."
                : "If sleep issues persist, consider adjusting your routine or seeking medical advice.";
      case 7:
        return response == 'Yes'
            ? "Stress and anxiety are common but should be managed. Consider relaxation techniques or speaking to a therapist."
            : response == 'No'
                ? "Maintaining a calm mindset is excellent! Continue using stress-relief techniques."
                : "If stress or anxiety remains, consider discussing coping strategies with a professional.";
      case 8:
        return response == 'Yes'
            ? "Regular baby movements are a good sign. Keep monitoring and note any changes."
            : response == 'No'
                ? "Lack of movement can be concerning. Please contact your healthcare provider immediately."
                : "If you continue noticing reduced movements, it's important to seek medical advice.";
      case 9:
        return response == 'Yes'
            ? "It's important to address any concerns with your healthcare provider. Early intervention is key."
            : response == 'No'
                ? "It's good that you feel comfortable with your pregnancy progress. Keep monitoring how you feel."
                : "If you continue having the same concerns, don't hesitate to discuss them with a healthcare professional.";
      default:
        return '';
    }
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
          content: Text('Please answer all questions before submitting.'),
        ),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Collection for the mother to store her responses
        CollectionReference motherFeelingsCollection = FirebaseFirestore
            .instance
            .collection('mother_pregnancy_data')
            .doc(userId)
            .collection('mother_periodic_feeling_form');

        // Add a new document in mother's collection
        DocumentReference motherDocRef = await motherFeelingsCollection.add({
          'date':
              '${_formatTwoDigits(now.day)}-${_formatTwoDigits(now.month)}-${now.year}',
          'questions': _questions,
          'responses': _responses,
          'medicalResponses': _medicalResponses,
        });

        // Collection for connected health provider to view patient's responses
        CollectionReference providerFeelingsCollection = FirebaseFirestore
            .instance
            .collection('health_provider_data')
            .doc(widget.requesterId)
            .collection('patience_responses')
            .doc(userId)
            .collection('responses');

        // Add the same data to health provider's collection
        await providerFeelingsCollection.add({
          'date':
              '${_formatTwoDigits(now.day)}-${_formatTwoDigits(now.month)}-${now.year}',
          'questions': _questions,
          'responses': _responses,
          'medicalResponses': _medicalResponses,
          'motherDocId': motherDocRef.id,
        });

        if (!mounted) return;

        // Clear the form by resetting the responses and isAnswered lists
        setState(() {
          _responses.fillRange(0, _responses.length, ''); // Reset all responses
          _isAnswered.fillRange(
              0, _isAnswered.length, true); // Reset all answers to valid
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
        SnackBar(
          content: Text('Failed to submit form: ${e.toString()}'),
        ),
      );
    }
  }

  String _formatTwoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
