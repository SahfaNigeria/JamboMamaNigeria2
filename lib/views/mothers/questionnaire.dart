// Updated Feelings Form with JamboMama theme UI
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PregnantFeelingsForm extends StatelessWidget {
  final String requesterId;
  final String expectedDeliveryDate;
  const PregnantFeelingsForm(
      {Key? key, required this.requesterId, required this.expectedDeliveryDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JamboMama! Feelings Check'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FeelingsForm(
          requesterId: requesterId, expectedDeliveryDate: expectedDeliveryDate),
    );
  }
}

Future<String?> fetchProviderId(String userId) async {
  final result = await FirebaseFirestore.instance
      .collection('allowed_to_chat')
      .where('requesterId', isEqualTo: userId)
      .limit(1)
      .get();

  if (result.docs.isNotEmpty) {
    return result.docs.first['recipientId'];
  }
  return null;
}

class FeelingsForm extends StatefulWidget {
  final String requesterId;
  final String expectedDeliveryDate;
  const FeelingsForm(
      {Key? key, required this.requesterId, required this.expectedDeliveryDate})
      : super(key: key);

  @override
  State<FeelingsForm> createState() => _FeelingsFormState();
}

class _FeelingsFormState extends State<FeelingsForm> {
  final DateTime now = DateTime.now();
  int? pregnancyWeek;

  final List<String> responses = List.filled(12, '');
  final List<String> medicalResponses = List.filled(12, '');
  final List<bool> isAnswered = List.filled(12, true);

  final TextEditingController worryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final edd = DateFormat('dd-MM-yyyy').parse(widget.expectedDeliveryDate);
    pregnancyWeek = 40 - edd.difference(now).inDays ~/ 7;
  }

  @override
  void dispose() {
    worryController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard({
    required String title,
    required String description,
    required Widget content,
    Color? iconColor,
    IconData? icon,
    bool isAnswered = true,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAnswered ? Colors.transparent : Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(icon, color: iconColor ?? Colors.red[800], size: 24),
                if (icon != null) SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChips({
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        Color chipColor;
        Color textColor = Colors.white;

        if (option.toLowerCase().contains('yes') ||
            option.toLowerCase().contains('not well')) {
          chipColor = Colors.red[600]!;
        } else if (option.toLowerCase().contains('no') ||
            option.toLowerCase().contains('fine')) {
          chipColor = Colors.green[600]!;
        } else {
          chipColor = Colors.blue[600]!;
        }

        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              color: selectedValue == option ? textColor : Colors.grey[700],
              fontWeight:
                  selectedValue == option ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: selectedValue == option,
          selectedColor: chipColor,
          backgroundColor: chipColor.withOpacity(0.1),
          side: BorderSide(
            color: selectedValue == option ? chipColor : Colors.grey[300]!,
            width: 1.5,
          ),
          onSelected: (_) => onSelected(option),
          elevation: selectedValue == option ? 2 : 0,
          pressElevation: 4,
        );
      }).toList(),
    );
  }

  Widget _buildResponseText(String response) {
    if (response.isEmpty) return SizedBox.shrink();

    Color responseColor;
    IconData responseIcon;

    if (response.contains('Great!') || response.contains('👍')) {
      responseColor = Colors.green[700]!;
      responseIcon = Icons.check_circle;
    } else if (response.contains('Contact') || response.contains('Call')) {
      responseColor = Colors.red[700]!;
      responseIcon = Icons.warning;
    } else {
      responseColor = Colors.blue[700]!;
      responseIcon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: responseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: responseColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(responseIcon, color: responseColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              response,
              style: TextStyle(
                color: responseColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getQuestionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.mood;
      case 1:
        return Icons.air;
      case 2:
        return Icons.psychology;
      case 3:
        return Icons.psychology;
      case 4:
        return Icons.thermostat;
      case 5:
        return Icons.sick;
      case 6:
        return Icons.bedtime;
      case 7:
        return Icons.child_care;
      case 8:
        return Icons.assignment;
      case 9:
        return Icons.healing;
      case 10:
        return Icons.pregnant_woman;
      case 11:
        return Icons.luggage;
      default:
        return Icons.help;
    }
  }

  Color _getQuestionColor(int index) {
    switch (index) {
      case 0:
        return Colors.green[600]!;
      case 1:
        return Colors.blue[600]!;
      case 2:
      case 3:
        return Colors.purple[600]!;
      case 4:
        return Colors.red[600]!;
      case 5:
        return Colors.orange[600]!;
      case 6:
        return Colors.indigo[600]!;
      case 7:
        return Colors.pink[600]!;
      case 8:
        return Colors.teal[600]!;
      case 9:
        return Colors.amber[700]!;
      case 10:
        return Colors.purple[600]!;
      case 11:
        return Colors.brown[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pregnancyWeek == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 32),
                SizedBox(height: 8),
                Text(
                  'How are you feeling today, Mom?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Today: ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  'Due date: ${widget.expectedDeliveryDate}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  'You are about ${pregnancyWeek!} weeks pregnant',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 16),

                // General feeling
                _buildQuestionCard(
                  title: 'How are you feeling today?',
                  description:
                      'Your overall well-being matters for you and your baby.',
                  icon: _getQuestionIcon(0),
                  iconColor: _getQuestionColor(0),
                  isAnswered: isAnswered[0],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Fine', 'So-so', 'Not well'],
                        selectedValue: responses[0],
                        onSelected: (value) {
                          setState(() {
                            responses[0] = value;
                            isAnswered[0] = true;
                            medicalResponses[0] = _generateResponse(0, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[0]),
                    ],
                  ),
                ),

                // Breathing
                _buildQuestionCard(
                  title: 'Are you quickly out of breath doing normal work?',
                  description:
                      'Shortness of breath can be normal in pregnancy but should be monitored.',
                  icon: _getQuestionIcon(1),
                  iconColor: _getQuestionColor(1),
                  isAnswered: isAnswered[1],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Yes', 'Same as before', 'No'],
                        selectedValue: responses[1],
                        onSelected: (value) {
                          setState(() {
                            responses[1] = value;
                            isAnswered[1] = true;
                            medicalResponses[1] = _generateResponse(1, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[1]),
                    ],
                  ),
                ),

                // Headaches
                _buildQuestionCard(
                  title:
                      'Have you had headaches often since you became pregnant?',
                  description:
                      'Frequent headaches during pregnancy should be evaluated.',
                  icon: _getQuestionIcon(2),
                  iconColor: _getQuestionColor(2),
                  isAnswered: isAnswered[2],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Yes', 'Same as before', 'No'],
                        selectedValue: responses[2],
                        onSelected: (value) {
                          setState(() {
                            responses[2] = value;
                            isAnswered[2] = true;
                            medicalResponses[2] = _generateResponse(2, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[2]),
                    ],
                  ),
                ),

                // Follow-up headache question
                if (responses[2] == 'Yes')
                  _buildQuestionCard(
                    title: 'Do you have a headache today?',
                    description:
                        'Current headache status helps determine urgency.',
                    icon: _getQuestionIcon(3),
                    iconColor: _getQuestionColor(3),
                    isAnswered: isAnswered[3],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: ['Yes', 'No'],
                          selectedValue: responses[3],
                          onSelected: (value) {
                            setState(() {
                              responses[3] = value;
                              isAnswered[3] = true;
                              medicalResponses[3] = _generateResponse(3, value);
                            });
                          },
                        ),
                        _buildResponseText(medicalResponses[3]),
                      ],
                    ),
                  ),

                // Fever
                _buildQuestionCard(
                  title: 'Have you had any fever since you became pregnant?',
                  description:
                      'Fever during pregnancy needs medical attention to protect your baby.',
                  icon: _getQuestionIcon(4),
                  iconColor: _getQuestionColor(4),
                  isAnswered: isAnswered[4],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Yes', 'No', "Don't know"],
                        selectedValue: responses[4],
                        onSelected: (value) {
                          setState(() {
                            responses[4] = value;
                            isAnswered[4] = true;
                            medicalResponses[4] = _generateResponse(4, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[4]),
                    ],
                  ),
                ),

                // Nausea
                _buildQuestionCard(
                  title: 'Do you feel nauseous?',
                  description:
                      'Morning sickness is common early in pregnancy but can occur anytime.',
                  icon: _getQuestionIcon(5),
                  iconColor: _getQuestionColor(5),
                  isAnswered: isAnswered[5],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Yes', 'No'],
                        selectedValue: responses[5],
                        onSelected: (value) {
                          setState(() {
                            responses[5] = value;
                            isAnswered[5] = true;
                            medicalResponses[5] = _generateResponse(5, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[5]),
                    ],
                  ),
                ),

                // Sleep
                _buildQuestionCard(
                  title: 'Do you sleep well?',
                  description:
                      'Good sleep is important for your health and baby\'s development.',
                  icon: _getQuestionIcon(6),
                  iconColor: _getQuestionColor(6),
                  isAnswered: isAnswered[6],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Yes', 'No', 'Same as before'],
                        selectedValue: responses[6],
                        onSelected: (value) {
                          setState(() {
                            responses[6] = value;
                            isAnswered[6] = true;
                            medicalResponses[6] = _generateResponse(6, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[6]),
                    ],
                  ),
                ),

                // Baby kicks (after 20 weeks)
                if (pregnancyWeek! >= 20)
                  _buildQuestionCard(
                    title: 'Can you feel the baby kick?',
                    description:
                        'Baby movements are a good sign of your baby\'s health.',
                    icon: _getQuestionIcon(7),
                    iconColor: _getQuestionColor(7),
                    isAnswered: isAnswered[7],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: ['Yes', 'No', "Don't know"],
                          selectedValue: responses[7],
                          onSelected: (value) {
                            setState(() {
                              responses[7] = value;
                              isAnswered[7] = true;
                              medicalResponses[7] = _generateResponse(7, value);
                            });
                          },
                        ),
                        _buildResponseText(medicalResponses[7]),
                      ],
                    ),
                  ),

                // Birth plan
                _buildQuestionCard(
                  title: 'Have you made a birth and emergency plan yet?',
                  description:
                      'Planning ahead helps ensure a safe delivery for you and your baby.',
                  icon: _getQuestionIcon(8),
                  iconColor: _getQuestionColor(8),
                  isAnswered: isAnswered[8],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: ['Yes', 'No'],
                        selectedValue: responses[8],
                        onSelected: (value) {
                          setState(() {
                            responses[8] = value;
                            isAnswered[8] = true;
                            medicalResponses[8] = _generateResponse(8, value);
                          });
                        },
                      ),
                      _buildResponseText(medicalResponses[8]),
                    ],
                  ),
                ),

                // Swelling (after 28 weeks)
                if (pregnancyWeek! >= 28)
                  _buildQuestionCard(
                    title:
                        'Are you experiencing any swelling in your legs, hands, or face?',
                    description:
                        'Swelling can be normal but may indicate complications like pre-eclampsia.',
                    icon: _getQuestionIcon(9),
                    iconColor: _getQuestionColor(9),
                    isAnswered: isAnswered[9],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: ['Yes', 'No'],
                          selectedValue: responses[9],
                          onSelected: (value) {
                            setState(() {
                              responses[9] = value;
                              isAnswered[9] = true;
                              medicalResponses[9] = _generateResponse(9, value);
                            });
                          },
                        ),
                        _buildResponseText(medicalResponses[9]),
                      ],
                    ),
                  ),

                // Contractions (after 24 weeks)
                if (pregnancyWeek! >= 24)
                  _buildQuestionCard(
                    title:
                        'Do you notice any contractions or belly tightening?',
                    description:
                        'Contractions before 37 weeks may indicate preterm labor.',
                    icon: _getQuestionIcon(10),
                    iconColor: _getQuestionColor(10),
                    isAnswered: isAnswered[10],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: ['Yes', 'No', "Not sure"],
                          selectedValue: responses[10],
                          onSelected: (value) {
                            setState(() {
                              responses[10] = value;
                              isAnswered[10] = true;
                              medicalResponses[10] =
                                  _generateResponse(10, value);
                            });
                          },
                        ),
                        _buildResponseText(medicalResponses[10]),
                      ],
                    ),
                  ),

                // Hospital bag (after 36 weeks)
                if (pregnancyWeek! >= 36)
                  _buildQuestionCard(
                    title: 'Have you packed your hospital bag?',
                    description:
                        'Being prepared for delivery helps reduce stress when labor begins.',
                    icon: _getQuestionIcon(11),
                    iconColor: _getQuestionColor(11),
                    isAnswered: isAnswered[11],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: ['Yes', 'No'],
                          selectedValue: responses[11],
                          onSelected: (value) {
                            setState(() {
                              responses[11] = value;
                              isAnswered[11] = true;
                              medicalResponses[11] =
                                  _generateResponse(11, value);
                            });
                          },
                        ),
                        _buildResponseText(medicalResponses[11]),
                      ],
                    ),
                  ),

                // Other concerns
                _buildQuestionCard(
                  title: 'Any other question or worry you have?',
                  description:
                      'Feel free to share any concerns - your health provider is here to help.',
                  icon: Icons.message,
                  iconColor: Colors.blue[600],
                  content: TextField(
                    controller: worryController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tell us about any other concerns...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.red[800]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            'SUBMIT FEELINGS REPORT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _generateResponse(int index, String answer) {
    switch (index) {
      case 0:
        return answer == 'Fine'
            ? 'Great! Keep it up.'
            : answer == 'So-so'
                ? 'Let your CHW know how you\'re feeling.'
                : 'Please contact your healthcare provider.';
      case 1:
        return answer == 'No'
            ? 'Good to hear!'
            : 'Discuss this with your provider at your next visit.';
      case 2:
        return answer == 'Yes'
            ? 'Do you have a headache today?'
            : answer == 'No'
                ? '👍'
                : 'Mention to your CHW or provider.';
      case 3:
        return answer == 'Yes'
            ? 'Contact your provider now.'
            : 'Mention this at your next visit.';
      case 4:
        return answer == 'No'
            ? '👍'
            : answer == 'Yes'
                ? 'Contact your healthcare provider.'
                : 'Ask someone to check your temperature.';
      case 5:
        return answer == 'No'
            ? '👍'
            : (pregnancyWeek! < 14
                ? 'It will pass. Ask your CHW for advice.'
                : 'Please contact your provider.');
      case 6:
        return answer == 'Yes'
            ? '👍'
            : 'Ask your CHW or check the Follow Pregnancy section.';
      case 7:
        return answer == 'Yes'
            ? '👍 That\'s a good sign. Keep monitoring.'
            : answer == 'No'
                ? 'Call your health provider today.'
                : 'Try again calmly later.';
      case 8:
        return answer == 'Yes'
            ? '👍 Great! Keep your plan handy.'
            : 'Start now! Go to the Birth Plan section.';
      case 9:
        return answer == 'Yes'
            ? 'Contact your CHW to check for signs of pre-eclampsia.'
            : '👍';
      case 10:
        return answer == 'Yes'
            ? 'Track the frequency. If they\'re regular, contact your provider.'
            : '👍';
      case 11:
        return answer == 'Yes'
            ? 'Good job! You\'re ready.'
            : 'Please prepare your hospital bag this week.';
      default:
        return '';
    }
  }

  void _submitForm() async {
    print('DEBUG - Initial widget.requesterId: ${widget.requesterId}');
    List<int> unansweredQuestions = [];

    for (int i = 0; i < responses.length; i++) {
      bool shouldAnswer = true;

      if (i == 3 && responses[2] != 'Yes') shouldAnswer = false;
      if (i == 7 && pregnancyWeek! < 20) shouldAnswer = false;
      if (i == 9 && pregnancyWeek! < 28) shouldAnswer = false;
      if (i == 10 && pregnancyWeek! < 24) shouldAnswer = false;
      if (i == 11 && pregnancyWeek! < 36) shouldAnswer = false;

      if (shouldAnswer && responses[i].isEmpty) {
        unansweredQuestions.add(i);
        isAnswered[i] = false;
      }
    }

    if (unansweredQuestions.isNotEmpty) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions before submitting.'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || pregnancyWeek == null) return;

      final userId = user.uid;

      // Fallback: get providerId if not passed properly
      String? providerId = widget.requesterId;
      if (providerId == null || providerId.isEmpty) {
        final fallback = await FirebaseFirestore.instance
            .collection('allowed_to_chat')
            .where('requesterId', isEqualTo: userId)
            .limit(1)
            .get();

        if (fallback.docs.isNotEmpty) {
          providerId = fallback.docs.first['recipientId'];
          print('✅ Fetched providerId fallback: $providerId');
        } else {
          print('⚠️ No provider connected (even in fallback).');
        }
      }

      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      final data = {
        'date': date,
        'expectedDeliveryDate': widget.expectedDeliveryDate,
        'pregnancyWeek': pregnancyWeek,
        'questions': responses,
        'medicalResponses': medicalResponses,
        'otherWorries': worryController.text,
        'motherId': userId,
        'providerId': providerId ?? '',
      };

      // Save to mother's record
      final motherRef = FirebaseFirestore.instance
          .collection('mother_pregnancy_data')
          .doc(userId)
          .collection('mother_periodic_feeling_form');
      final docRef = await motherRef.add(data);

      // Save/update EDD
      await FirebaseFirestore.instance
          .collection('mother_pregnancy_data')
          .doc(userId)
          .set({
        'expectedDeliveryDate': widget.expectedDeliveryDate,
        'userId': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to provider if available
      if (providerId != null && providerId.isNotEmpty) {
        final providerRef = FirebaseFirestore.instance
            .collection('health_provider_data')
            .doc(providerId)
            .collection('patience_responses')
            .doc(userId)
            .collection('responses');

        await providerRef.add({...data, 'motherDocId': docRef.id});
        print('✅ Saved to provider path');
      } else {
        print('⚠️ Skipped provider save — no valid providerId.');
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text('Report Submitted', style: TextStyle(color: Colors.green)),
              ],
            ),
            content: Text(
                'Thank you Mom! Your health provider will read this information and contact you if necessary.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      setState(() {
        responses.fillRange(0, responses.length, '');
        medicalResponses.fillRange(0, medicalResponses.length, '');
        isAnswered.fillRange(0, isAnswered.length, true);
        worryController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
