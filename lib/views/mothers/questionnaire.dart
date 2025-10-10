// Updated Feelings Form with JamboMama theme UI
import 'package:auto_i8ln/auto_i8ln.dart';
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
        title: AutoText('FEELING_CHECK'),
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
                  child: AutoText(
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
              AutoText(
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

        if (option.toLowerCase().contains(autoI8lnGen.translate("YES_2")) ||
            option.toLowerCase().contains(autoI8lnGen.translate("NOT_WELL"))) {
          chipColor = Colors.red[600]!;
        } else if (option.toLowerCase().contains(autoI8lnGen.translate("NO")) ||
            option.toLowerCase().contains(autoI8lnGen.translate("FINE"))) {
          chipColor = Colors.green[600]!;
        } else {
          chipColor = Colors.blue[600]!;
        }

        return ChoiceChip(
          label: AutoText(
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

    if (response.contains(autoI8lnGen.translate("GREAT")) ||
        response.contains('👍')) {
      responseColor = Colors.green[700]!;
      responseIcon = Icons.check_circle;
    } else if (response.contains(autoI8lnGen.translate("CONTACT")) ||
        response.contains(autoI8lnGen.translate("CALL"))) {
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
            child: AutoText(
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
                AutoText(
                  'F_T_M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                AutoText(
                  'TODAY_2 ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                AutoText(
                  'DUEDATE ${widget.expectedDeliveryDate}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                AutoText(
                  'Y_A_A ${pregnancyWeek!} W_P',
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
                  title: 'HEALTH_QUESTION_7',
                  description: 'YOUR_OVER_ALL_WELL',
                  icon: _getQuestionIcon(0),
                  iconColor: _getQuestionColor(0),
                  isAnswered: isAnswered[0],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("FINE_2"),
                          autoI8lnGen.translate("SO_SO"),
                          autoI8lnGen.translate("N_T_W"),
                        ],
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
                  title: 'HEALTH_QUESTION_8',
                  description: 'S_O_B_N',
                  icon: _getQuestionIcon(1),
                  iconColor: _getQuestionColor(1),
                  isAnswered: isAnswered[1],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("YES_MESSAGE"),
                          autoI8lnGen.translate("SAB"),
                          autoI8lnGen.translate("NO_MESSAGE"),
                        ],
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
                  title: 'HEALTH_QUESTION_9',
                  description: 'F_D_P_E',
                  icon: _getQuestionIcon(2),
                  iconColor: _getQuestionColor(2),
                  isAnswered: isAnswered[2],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("YES_MESSAGE"),
                          autoI8lnGen.translate("SAB"),
                          autoI8lnGen.translate("NO_MESSAGE"),
                        ],
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
                if (responses[2] == autoI8lnGen.translate("YES_MESSAGE"))
                  _buildQuestionCard(
                    title: 'HEALTH_QUESTION_10',
                    description: 'C_H_S_U',
                    icon: _getQuestionIcon(3),
                    iconColor: _getQuestionColor(3),
                    isAnswered: isAnswered[3],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                          ],
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
                  title: 'HEALTH_QUESTION_11',
                  description: 'F_DP_B',
                  icon: _getQuestionIcon(4),
                  iconColor: _getQuestionColor(4),
                  isAnswered: isAnswered[4],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("YES_MESSAGE"),
                          autoI8lnGen.translate("NO_MESSAGE"),
                          autoI8lnGen.translate("DONT_KNOW"),
                        ],
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
                  title: 'HEALTH_QUESTION_12',
                  description: 'M_SICKNESS_C',
                  icon: _getQuestionIcon(5),
                  iconColor: _getQuestionColor(5),
                  isAnswered: isAnswered[5],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("YES_MESSAGE"),
                          autoI8lnGen.translate("NO_MESSAGE"),
                        ],
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
                  title: 'HEALTH_QUESTION_13',
                  description: 'G_B_H',
                  icon: _getQuestionIcon(6),
                  iconColor: _getQuestionColor(6),
                  isAnswered: isAnswered[6],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("YES_MESSAGE"),
                          autoI8lnGen.translate("NO_MESSAGE"),
                          autoI8lnGen.translate("SAME_BEFORE"),
                        ],
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
                    title: 'HEALTH_QUESTION_14',
                    description: 'B_M_G',
                    icon: _getQuestionIcon(7),
                    iconColor: _getQuestionColor(7),
                    isAnswered: isAnswered[7],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("DONT_KNOW"),
                          ],
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
                  title: 'HEALTH_QUESTION_15',
                  description: 'P_AHEAD',
                  icon: _getQuestionIcon(8),
                  iconColor: _getQuestionColor(8),
                  isAnswered: isAnswered[8],
                  content: Column(
                    children: [
                      _buildChoiceChips(
                        options: [
                          autoI8lnGen.translate("YES_MESSAGE"),
                          autoI8lnGen.translate("NO_MESSAGE"),
                        ],
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
                    title: 'HEALTH_QUESTION_16',
                    description: 'SWELLING_NORMAL',
                    icon: _getQuestionIcon(9),
                    iconColor: _getQuestionColor(9),
                    isAnswered: isAnswered[9],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                          ],
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
                    title: 'HEALTH_QUESTION_17',
                    description: 'C_37',
                    icon: _getQuestionIcon(10),
                    iconColor: _getQuestionColor(10),
                    isAnswered: isAnswered[10],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("N_S_U"),
                          ],
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
                    title: 'HEALTH_QUESTION_18',
                    description: 'B_P_DE',
                    icon: _getQuestionIcon(11),
                    iconColor: _getQuestionColor(11),
                    isAnswered: isAnswered[11],
                    content: Column(
                      children: [
                        _buildChoiceChips(
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                          ],
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
                  title: 'A_O_Q',
                  description: 'F_F_C_H',
                  icon: Icons.message,
                  iconColor: Colors.blue[600],
                  content: TextField(
                    controller: worryController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: autoI8lnGen.translate("T_U_C"),
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
          child: AutoText(
            'S_F_R',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _generateResponse(int index, String answer) {
    switch (index) {
      case 0:
        return answer == autoI8lnGen.translate("FINE_2")
            ? autoI8lnGen.translate("G_K_U")
            : answer == autoI8lnGen.translate("SO_SO")
                ? autoI8lnGen.translate("CALL_CHW")
                : autoI8lnGen.translate("P_C_H");
      case 1:
        return answer == autoI8lnGen.translate("NO_MESSAGE")
            ? autoI8lnGen.translate("G_T_H")
            : autoI8lnGen.translate("D_P_NEXT");
      case 2:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("HEALTH_QUESTION_10")
            : answer == autoI8lnGen.translate("NO_MESSAGE")
                ? '👍'
                : autoI8lnGen.translate("M_CHW_P");
      case 3:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("C_Y_P_M")
            : autoI8lnGen.translate("M_T_V");
      case 4:
        return answer == autoI8lnGen.translate("NO_MESSAGE")
            ? '👍'
            : answer == autoI8lnGen.translate("YES_MESSAGE")
                ? autoI8lnGen.translate("C_H_P")
                : autoI8lnGen.translate("A_S_T");
      case 5:
        return answer == autoI8lnGen.translate("NO_MESSAGE")
            ? '👍'
            : (pregnancyWeek! < 14
                ? autoI8lnGen.translate("IT_WILL_PASS")
                : autoI8lnGen.translate("P_C_P"));
      case 6:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? '👍'
            : autoI8lnGen.translate("ASK_CHW");
      case 7:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("👍 THAT_GOOD_SIGN")
            : answer == autoI8lnGen.translate("NO_MESSAGE")
                ? autoI8lnGen.translate("C_H_P")
                : autoI8lnGen.translate("T_A_C");
      case 8:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("👍 G_K_P")
            : autoI8lnGen.translate("START_N_B_P_S");
      case 9:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("C_CHW_S")
            : '👍';
      case 10:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("T_T_F_P")
            : '👍';
      case 11:
        return answer == autoI8lnGen.translate("YES_MESSAGE")
            ? autoI8lnGen.translate("G_J_READY")
            : autoI8lnGen.translate("P_P_H_B");
      default:
        return '';
    }
  }

  void _submitForm() async {
    print('DEBUG - Initial widget.requesterId: ${widget.requesterId}');
    List<int> unansweredQuestions = [];

    for (int i = 0; i < responses.length; i++) {
      bool shouldAnswer = true;

      if (i == 3 && responses[2] != autoI8lnGen.translate("YES_MESSAGE"))
        shouldAnswer = false;
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
          content: AutoText('P_A_Q_S'),
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
      if (providerId.isEmpty) {
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
                AutoText('R_S_U', style: TextStyle(color: Colors.green)),
              ],
            ),
            content: AutoText('T_M_I'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: AutoText('OK'),
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
          content: AutoText('F_T_S: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
