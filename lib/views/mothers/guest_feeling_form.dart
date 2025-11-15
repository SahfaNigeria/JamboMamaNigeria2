import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestFeelingsForm extends StatelessWidget {
  const GuestFeelingsForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('FEELING_CHECK'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const _GuestFeelingsFormBody(),
    );
  }
}

class _GuestFeelingsFormBody extends StatefulWidget {
  const _GuestFeelingsFormBody({Key? key}) : super(key: key);

  @override
  State<_GuestFeelingsFormBody> createState() => _GuestFeelingsFormBodyState();
}

class _GuestFeelingsFormBodyState extends State<_GuestFeelingsFormBody> {
  final DateTime now = DateTime.now();
  int pregnancyWeek = 20; // fixed demo value for guests

  final List<String> responses = List.filled(12, '');
  final List<String> medicalResponses = List.filled(12, '');
  final List<bool> isAnswered = List.filled(12, true);

  final TextEditingController worryController = TextEditingController();

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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAnswered ? Colors.transparent : Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(icon, color: iconColor ?? Colors.red[800], size: 24),
                if (icon != null) const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              AutoText(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
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
    final questions = [
      {'title': 'HEALTH_QUESTION_7', 'desc': 'YOUR_OVER_ALL_WELL'},
      {'title': 'HEALTH_QUESTION_8', 'desc': 'S_O_B_N'},
      {'title': 'HEALTH_QUESTION_9', 'desc': 'F_D_P_E'},
      {'title': 'HEALTH_QUESTION_10', 'desc': 'C_H_S_U'},
      {'title': 'HEALTH_QUESTION_11', 'desc': 'F_DP_B'},
      {'title': 'HEALTH_QUESTION_12', 'desc': 'M_SICKNESS_C'},
      {'title': 'HEALTH_QUESTION_13', 'desc': 'G_B_H'},
      {'title': 'HEALTH_QUESTION_14', 'desc': 'B_M_G'},
      {'title': 'HEALTH_QUESTION_15', 'desc': 'P_AHEAD'},
      {'title': 'HEALTH_QUESTION_16', 'desc': 'SWELLING_NORMAL'},
      {'title': 'HEALTH_QUESTION_17', 'desc': 'C_37'},
      {'title': 'HEALTH_QUESTION_18', 'desc': 'B_P_DE'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                AutoText(
                  'F_T_M',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AutoText(
                  'TODAY_2 ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                AutoText(
                  'Y_A_A $pregnancyWeek W_P',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),

                // All 12 questions
                for (int i = 0; i < questions.length; i++)
                  _buildQuestionCard(
                    title: questions[i]['title']!,
                    description: questions[i]['desc']!,
                    icon: _getQuestionIcon(i),
                    iconColor: _getQuestionColor(i),
                    isAnswered: isAnswered[i],
                    content: _buildChoiceChips(
                      options: [
                        autoI8lnGen.translate("YES_MESSAGE"),
                        autoI8lnGen.translate("NO_MESSAGE"),
                        autoI8lnGen.translate("SAB"),
                      ],
                      selectedValue: responses[i],
                      onSelected: (value) {
                        setState(() {
                          responses[i] = value;
                          isAnswered[i] = true;
                          medicalResponses[i] = "Sample response";
                        });
                      },
                    ),
                  ),

                // Extra text field (concerns)
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Instead of saving → tell user to create account
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AutoText("PLEASE_CREATE_ACCOUNT"),
                backgroundColor: Colors.red[600],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: AutoText(
            'S_F_R',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
