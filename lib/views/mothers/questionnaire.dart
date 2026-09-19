import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';

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
  bool isPastDue = false;

  /// null = not yet answered, true = yes delivered, false = not yet delivered
  bool? hasDelivered;

  // ── Parity ────────────────────────────────────────────────────────────────
  // Fetched from Firestore: 'mother_profile' doc field 'isFirstPregnancy' (bool)
  // null = still loading, true = primigravida, false = multigravida
  bool? isFirstPregnancy;
  bool _parityLoading = true;

  // ── Lists expanded to 13 (index 12 = IPT question) ────────────────────────
  final List<String> responses = List.filled(13, '');
  final List<String> medicalResponses = List.filled(13, '');
  final List<bool> isAnswered = List.filled(13, false);

  final TextEditingController worryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ── Calculate pregnancy week ───────────────────────────────────────────
    final edd = DateFormat('dd-MM-yyyy').parse(widget.expectedDeliveryDate);
    final daysFromEdd = now.difference(edd).inDays;

    if (daysFromEdd >= 0) {
      isPastDue = true;
      pregnancyWeek = 40;
    } else {
      isPastDue = false;
      final weeksRemaining = edd.difference(now).inDays ~/ 7;
      final calculated = 40 - weeksRemaining;
      pregnancyWeek = calculated.clamp(1, 40);
    }

    // ── Fetch parity from Firestore ────────────────────────────────────────
    // Reads the 'isFirstPregnancy' boolean field from the mother's profile doc.
    // If the field does not exist we default to null (unknown) and the IPT
    // messaging falls back to a neutral tone that suits both groups.
    _fetchParity();
  }

  Future<void> _fetchParity() async {
    try {
      final userId = widget.requesterId;
      final doc = await FirebaseFirestore.instance
          .collection('mother_profile')
          .doc(userId)
          .get();

      if (doc.exists && doc.data()!.containsKey('isFirstPregnancy')) {
        setState(() {
          isFirstPregnancy = doc.data()!['isFirstPregnancy'] as bool;
          _parityLoading = false;
        });
      } else {
        // Field absent — treat as unknown; neutral messaging will be used
        setState(() {
          isFirstPregnancy = null;
          _parityLoading = false;
        });
      }
    } catch (_) {
      // Network/permission error — degrade gracefully
      setState(() {
        isFirstPregnancy = null;
        _parityLoading = false;
      });
    }
  }

  @override
  void dispose() {
    worryController.dispose();
    super.dispose();
  }

  void _navToBirthPlan() {
    Navigator.pushNamed(
      context,
      '/BirthPlanScreen',
      arguments: {'patientId': FirebaseAuth.instance.currentUser!.uid},
    );
  }

  // ─── Delivery Confirmation Card ──────────────────────────────────────────────
  Widget _buildDeliveryConfirmationCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.pink[300]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.child_friendly, color: Colors.pink[600], size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: AutoText(
                    'HAVE_YOU_DELIVERED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AutoText(
              'PAST_DUE_PROMPT',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              children: [
                // YES — delivered
                ChoiceChip(
                  label: AutoText(
                    'YES_MESSAGE',
                    style: TextStyle(
                      color: hasDelivered == true
                          ? Colors.white
                          : Colors.grey[700],
                      fontWeight: hasDelivered == true
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: hasDelivered == true,
                  selectedColor: Colors.green[600],
                  backgroundColor: Colors.green[50],
                  side: BorderSide(
                    color: hasDelivered == true
                        ? Colors.green[600]!
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  onSelected: (_) => setState(() => hasDelivered = true),
                  elevation: hasDelivered == true ? 2 : 0,
                ),
                // NOT YET
                ChoiceChip(
                  label: AutoText(
                    'NOT_YET_MESSAGE',
                    style: TextStyle(
                      color: hasDelivered == false
                          ? Colors.white
                          : Colors.grey[700],
                      fontWeight: hasDelivered == false
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: hasDelivered == false,
                  selectedColor: Colors.orange[700],
                  backgroundColor: Colors.orange[50],
                  side: BorderSide(
                    color: hasDelivered == false
                        ? Colors.orange[700]!
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  onSelected: (_) => setState(() => hasDelivered = false),
                  elevation: hasDelivered == false ? 2 : 0,
                ),
              ],
            ),
            if (hasDelivered == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AutoText(
                        'CONGRATULATIONS_DELIVERED',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (hasDelivered == false) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AutoText(
                        'PAST_DUE_NO_DELIVERY_WARNING',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
        const Color textColor = Colors.white;

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
    if (response.isEmpty) return const SizedBox.shrink();

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
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: responseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: responseColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(responseIcon, color: responseColor, size: 20),
          const SizedBox(width: 8),
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
      case 12:
        return Icons.medication; // IPT / Fansidar
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
      case 12:
        return Colors.teal[700]!; // IPT / Fansidar
      default:
        return Colors.grey[600]!;
    }
  }

  // ── IPT description key: parity-aware ─────────────────────────────────────
  // First-time mothers (primigravida) have no prior pregnancy-acquired malaria
  // immunity, making them higher risk. The description surfaces this context
  // so the question feels relevant to their specific situation.
  // Multigravida mothers have partial immunity from prior pregnancies but still
  // need all doses — their description uses a lighter reinforcement tone.
  // If parity is unknown (field missing in Firestore) we show the neutral key.
  String get _iptDescriptionKey {
    if (isFirstPregnancy == true) {
      return 'HEALTH_QUESTION_IPT_DESC_FIRST';
      // e.g. "Because this is your first pregnancy, your body has not yet built
      //  protection against malaria during pregnancy. Fansidar (SP) given at
      //  each ANC visit from 13 weeks helps protect you and your baby."
    } else if (isFirstPregnancy == false) {
      return 'HEALTH_QUESTION_IPT_DESC_MULTI';
      // e.g. "Fansidar (SP) is given at each ANC visit from 13 weeks. Even
      //  with experience from previous pregnancies, all doses are still
      //  recommended to keep you and your baby safe."
    } else {
      return 'HEALTH_QUESTION_IPT_DESC';
      // Neutral fallback:
      // "Fansidar (Sulfadoxine-Pyrimethamine) is given at each ANC visit from
      //  13 weeks to protect you and your baby from malaria."
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pregnancyWeek == null || _parityLoading) {
      // Wait for both week calculation and parity fetch before rendering
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool hidePregnancyQuestions = isPastDue && hasDelivered == true;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // ── Compact header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: AutoText(
                    'F_T_M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                     child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoText(
                      'TODAY_2 ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    AutoText(
                      'DUEDATE ${widget.expectedDeliveryDate}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    AutoText(
                      isPastDue ? 'W_PAST_DUE' : 'Y_A_A ${pregnancyWeek!} W_P',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                )
             
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),

                // ── Delivery confirmation (shown when EDD passed) ────────────
                if (isPastDue) _buildDeliveryConfirmationCard(),

                if (!hidePregnancyQuestions) ...[
                  // Late-term warning banner
                  if (isPastDue && hasDelivered == false)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: AutoText(
                        'PAST_DUE_CONTINUE_INSTRUCTIONS',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[800],
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // ── Q0: General feeling ────────────────────────────────────
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
                          onSelected: (value) => setState(() {
                            responses[0] = value;
                            isAnswered[0] = true;
                            medicalResponses[0] = _generateResponse(0, value);
                          }),
                        ),
                        _buildResponseText(medicalResponses[0]),
                      ],
                    ),
                  ),

                  // ── Q1: Breathing ──────────────────────────────────────────
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
                          onSelected: (value) => setState(() {
                            responses[1] = value;
                            isAnswered[1] = true;
                            medicalResponses[1] = _generateResponse(1, value);
                          }),
                        ),
                        _buildResponseText(medicalResponses[1]),
                      ],
                    ),
                  ),

                  // ── Q2: Headaches ──────────────────────────────────────────
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
                          onSelected: (value) => setState(() {
                            responses[2] = value;
                            isAnswered[2] = true;
                            medicalResponses[2] = _generateResponse(2, value);
                          }),
                        ),
                        _buildResponseText(medicalResponses[2]),
                      ],
                    ),
                  ),

                  // ── Q3: Follow-up headache (only if Q2 = Yes) ─────────────
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
                            onSelected: (value) => setState(() {
                              responses[3] = value;
                              isAnswered[3] = true;
                              medicalResponses[3] = _generateResponse(3, value);
                            }),
                          ),
                          _buildResponseText(medicalResponses[3]),
                        ],
                      ),
                    ),

                  // ── Q4: Fever ──────────────────────────────────────────────
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
                            autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
                          ],
                          selectedValue: responses[4],
                          onSelected: (value) => setState(() {
                            responses[4] = value;
                            isAnswered[4] = true;
                            medicalResponses[4] = _generateResponse(4, value);
                          }),
                        ),
                        _buildResponseText(medicalResponses[4]),
                      ],
                    ),
                  ),

                  // ── Q5: Nausea ─────────────────────────────────────────────
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
                          onSelected: (value) => setState(() {
                            responses[5] = value;
                            isAnswered[5] = true;
                            medicalResponses[5] = _generateResponse(5, value);
                          }),
                        ),
                        _buildResponseText(medicalResponses[5]),
                      ],
                    ),
                  ),

                  // ── Q6: Sleep ──────────────────────────────────────────────
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
                          onSelected: (value) => setState(() {
                            responses[6] = value;
                            isAnswered[6] = true;
                            medicalResponses[6] = _generateResponse(6, value);
                          }),
                        ),
                        _buildResponseText(medicalResponses[6]),
                      ],
                    ),
                  ),

                  // ── Q7: Baby kicks (≥20 weeks) ─────────────────────────────
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
                              autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
                            ],
                            selectedValue: responses[7],
                            onSelected: (value) => setState(() {
                              responses[7] = value;
                              isAnswered[7] = true;
                              medicalResponses[7] = _generateResponse(7, value);
                            }),
                          ),
                          _buildResponseText(medicalResponses[7]),
                        ],
                      ),
                    ),

                  // ── Q8: Birth plan ─────────────────────────────────────────
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
                          onSelected: (value) => setState(() {
                            responses[8] = value;
                            isAnswered[8] = true;
                            medicalResponses[8] = _generateResponse(8, value);
                          }),
                        ),
                        if (responses[8] == autoI8lnGen.translate("NO_MESSAGE"))
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.orange[700], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _navToBirthPlan,
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange[700]),
                                        children: [
                                          TextSpan(
                                              text: autoI8lnGen.translate(
                                                      "START_N_B_P_S") +
                                                  ' '),
                                          TextSpan(
                                            text: autoI8lnGen
                                                .translate("GO_TO_BIRTH_PLAN"),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = _navToBirthPlan,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          _buildResponseText(medicalResponses[8]),
                      ],
                    ),
                  ),

                  // ── Q9: Swelling (≥28 weeks) ───────────────────────────────
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
                              autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
                            ],
                            selectedValue: responses[9],
                            onSelected: (value) => setState(() {
                              responses[9] = value;
                              isAnswered[9] = true;
                              medicalResponses[9] = _generateResponse(9, value);
                            }),
                          ),
                          _buildResponseText(medicalResponses[9]),
                        ],
                      ),
                    ),

                  // ── Q10: Contractions (≥24 weeks) ─────────────────────────
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
                              autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
                            ],
                            selectedValue: responses[10],
                            onSelected: (value) => setState(() {
                              responses[10] = value;
                              isAnswered[10] = true;
                              medicalResponses[10] =
                                  _generateResponse(10, value);
                            }),
                          ),
                          _buildResponseText(medicalResponses[10]),
                        ],
                      ),
                    ),

                  // ── Q11: Hospital bag (≥36 weeks) ──────────────────────────
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
                            onSelected: (value) => setState(() {
                              responses[11] = value;
                              isAnswered[11] = true;
                              medicalResponses[11] =
                                  _generateResponse(11, value);
                            }),
                          ),
                          _buildResponseText(medicalResponses[11]),
                        ],
                      ),
                    ),

                  // ── Q12: IPT / Fansidar (≥13 weeks) ───────────────────────
                  // Shown from 13 weeks (start of 2nd trimester) through to
                  // delivery. The description and "No" response message are
                  // parity-aware: first-time mothers receive stronger urgency
                  // framing because they have no prior pregnancy-acquired
                  // malaria immunity. Multigravida mothers see a softer
                  // reminder tone. Both groups are directed back to their ANC /
                  // CHW for the dose — never to self-medicate — because
                  // Nigeria's IPT protocol requires directly observed therapy.
                  if (pregnancyWeek! >= 13)
                    _buildQuestionCard(
                      title: 'HEALTH_QUESTION_IPT_TITLE',
                      description: _iptDescriptionKey,
                      icon: _getQuestionIcon(12),
                      iconColor: _getQuestionColor(12),
                      isAnswered: isAnswered[12],
                      content: Column(
                        children: [
                          _buildChoiceChips(
                            options: [
                              autoI8lnGen.translate("YES_MESSAGE"),
                              autoI8lnGen.translate("NO_MESSAGE"),
                              autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
                            ],
                            selectedValue: responses[12],
                            onSelected: (value) => setState(() {
                              responses[12] = value;
                              isAnswered[12] = true;
                              medicalResponses[12] =
                                  _generateResponse(12, value);
                            }),
                          ),
                          _buildResponseText(medicalResponses[12]),
                        ],
                      ),
                    ),

                  // ── Other concerns ─────────────────────────────────────────
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
                ], // end !hidePregnancyQuestions

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitForm,
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

      // ── Case 12: IPT / Fansidar ──────────────────────────────────────────
      // YES  → affirm + remind about next dose timing
      // NO   → parity-aware urgency:
      //         primigravida   → urgent, first-pregnancy risk framing
      //         multigravida   → firm but lighter reminder
      //         unknown parity → neutral reminder
      // UNSURE → direct to CHW to check dose schedule
      case 12:
        if (answer == autoI8lnGen.translate("YES_MESSAGE")) {
          return autoI8lnGen.translate("IPT_TAKEN_GOOD");
          // "Great! Keep attending your ANC visits for each dose.
          //  At least 3 doses are recommended throughout your pregnancy."
        } else if (answer == autoI8lnGen.translate("NO_MESSAGE")) {
          if (isFirstPregnancy == true) {
            // Primigravida — higher risk, stronger language
            if (pregnancyWeek! >= 28) {
              return autoI8lnGen.translate("IPT_NOT_TAKEN_FIRST_URGENT");
              // "Because this is your first pregnancy you have less protection
              //  against malaria. You are now in your third trimester — please
              //  contact your CHW or visit your ANC clinic for your Fansidar
              //  dose as soon as possible."
            } else {
              return autoI8lnGen.translate("IPT_NOT_TAKEN_FIRST_WARN");
              // "First-time mothers need extra protection from malaria in
              //  pregnancy. Please ask your health worker for your Fansidar
              //  dose at your next ANC visit."
            }
          } else if (isFirstPregnancy == false) {
            // Multigravida — still needs dose, lighter tone
            if (pregnancyWeek! >= 28) {
              return autoI8lnGen.translate("IPT_NOT_TAKEN_MULTI_URGENT");
              // "You are in your third trimester — please ask your CHW or
              //  midwife for your Fansidar dose at your next visit."
            } else {
              return autoI8lnGen.translate("IPT_NOT_TAKEN_MULTI_WARN");
              // "Please remember to collect your Fansidar dose at your
              //  next ANC visit to keep you and your baby protected."
            }
          } else {
            // Parity unknown — neutral fallback
            return autoI8lnGen.translate("IPT_NOT_TAKEN_WARN");
            // "Please ask your health worker for your Fansidar dose at your
            //  next ANC visit. Do not take it on your own — it should be
            //  given under observation at the clinic."
          }
        } else {
          // DONT_KNOW_REMEMBER
          return autoI8lnGen.translate("IPT_UNSURE_ASK_CHW");
          // "Ask your midwife or CHW whether you are due for your next
          //  Fansidar dose at your next visit."
        }

      default:
        return '';
    }
  }

  void _submitForm() async {
    if (isPastDue && hasDelivered == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText('PLEASE_ANSWER_DELIVERY_Q'),
          backgroundColor: Colors.red[600],
        ),
      );
      return;
    }

    if (!(isPastDue && hasDelivered == true)) {
      List<int> unansweredQuestions = [];
      for (int i = 0; i < responses.length; i++) {
        bool shouldAnswer = true;
        if (i == 3 && responses[2] != autoI8lnGen.translate("YES_MESSAGE"))
          shouldAnswer = false;
        if (i == 7 && pregnancyWeek! < 20) shouldAnswer = false;
        if (i == 9 && pregnancyWeek! < 28) shouldAnswer = false;
        if (i == 10 && pregnancyWeek! < 24) shouldAnswer = false;
        if (i == 11 && pregnancyWeek! < 36) shouldAnswer = false;
        if (i == 12 && pregnancyWeek! < 13) shouldAnswer = false; // IPT gate

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
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || pregnancyWeek == null) return;

      final userId = user.uid;
      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      final providerQuery = await FirebaseFirestore.instance
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: userId)
          .get();

      final providerIds = providerQuery.docs
          .map((doc) => doc['recipientId'] as String)
          .toList();

      final data = {
        'date': date,
        'expectedDeliveryDate': widget.expectedDeliveryDate,
        'pregnancyWeek': pregnancyWeek,
        'isPastDue': isPastDue,
        'hasDelivered': hasDelivered,
        'isFirstPregnancy': isFirstPregnancy, // saved for provider context
        'questions': responses,
        'medicalResponses': medicalResponses,
        'otherWorries': worryController.text,
        'motherId': userId,
        'providerIds': providerIds,
      };

      final motherRef = FirebaseFirestore.instance
          .collection('mother_pregnancy_data')
          .doc(userId)
          .collection('mother_periodic_feeling_form');
      final docRef = await motherRef.add(data);

      await FirebaseFirestore.instance
          .collection('mother_pregnancy_data')
          .doc(userId)
          .set({
        'expectedDeliveryDate': widget.expectedDeliveryDate,
        'userId': userId,
        'hasDelivered': hasDelivered ?? false,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final globalRef = await FirebaseFirestore.instance
          .collection('mother_pregnancy_data')
          .doc(userId)
          .collection('mother_feeling_responses')
          .add({
        ...data,
        'motherDocId': docRef.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      for (final providerId in providerIds) {
        await FirebaseFirestore.instance
            .collection('health_provider_data')
            .doc(providerId)
            .collection('patience_responses')
            .doc(userId)
            .collection('responses')
            .add({
          ...data,
          'motherDocId': docRef.id,
          'globalDocId': globalRef.id,
          'providerId': providerId,
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                AutoText('R_S_U', style: const TextStyle(color: Colors.green)),
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

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/gestures.dart';

// class PregnantFeelingsForm extends StatelessWidget {
//   final String requesterId;
//   final String expectedDeliveryDate;
//   const PregnantFeelingsForm(
//       {Key? key, required this.requesterId, required this.expectedDeliveryDate})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('FEELING_CHECK'),
//         backgroundColor: Colors.red[800],
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: FeelingsForm(
//           requesterId: requesterId, expectedDeliveryDate: expectedDeliveryDate),
//     );
//   }
// }

// Future<String?> fetchProviderId(String userId) async {
//   final result = await FirebaseFirestore.instance
//       .collection('allowed_to_chat')
//       .where('requesterId', isEqualTo: userId)
//       .limit(1)
//       .get();

//   if (result.docs.isNotEmpty) {
//     return result.docs.first['recipientId'];
//   }
//   return null;
// }

// class FeelingsForm extends StatefulWidget {
//   final String requesterId;
//   final String expectedDeliveryDate;
//   const FeelingsForm(
//       {Key? key, required this.requesterId, required this.expectedDeliveryDate})
//       : super(key: key);

//   @override
//   State<FeelingsForm> createState() => _FeelingsFormState();
// }

// class _FeelingsFormState extends State<FeelingsForm> {
//   final DateTime now = DateTime.now();
//   int? pregnancyWeek;
//   bool isPastDue = false;

//   /// null = not yet answered, true = yes delivered, false = not yet delivered
//   bool? hasDelivered;

//   final List<String> responses = List.filled(12, '');
//   final List<String> medicalResponses = List.filled(12, '');
//   final List<bool> isAnswered = List.filled(12, false);

//   final TextEditingController worryController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final edd = DateFormat('dd-MM-yyyy').parse(widget.expectedDeliveryDate);

//     // How many days past EDD (positive = overdue, negative = still pregnant)
//     final daysFromEdd = now.difference(edd).inDays;

//     if (daysFromEdd >= 0) {
//       // EDD has been reached or passed
//       isPastDue = true;
//       pregnancyWeek = 40; // clamp display at 40
//     } else {
//       isPastDue = false;
//       // Normal calculation: weeks remaining subtracted from 40
//       final weeksRemaining = edd.difference(now).inDays ~/ 7;
//       final calculated = 40 - weeksRemaining;
//       // Clamp between 1 and 40 defensively
//       pregnancyWeek = calculated.clamp(1, 40);
//     }
//   }

//   @override
//   void dispose() {
//     worryController.dispose();
//     super.dispose();
//   }

//   void _navToBirthPlan() {
//     Navigator.pushNamed(
//       context,
//       '/BirthPlanScreen',
//       arguments: {'patientId': FirebaseAuth.instance.currentUser!.uid},
//     );
//   }

//   // ─── Delivery Confirmation Card ──────────────────────────────────────────────
//   Widget _buildDeliveryConfirmationCard() {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.pink[300]!, width: 2),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.child_friendly, color: Colors.pink[600], size: 26),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: AutoText(
//                     // "Have You Had Your Baby?" — add this key to your i8ln
//                     'HAVE_YOU_DELIVERED',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.pink[700],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             AutoText(
//               // "Your due date has arrived. Have you given birth to your baby?"
//               'PAST_DUE_PROMPT',
//               style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//             ),
//             const SizedBox(height: 14),
//             Wrap(
//               spacing: 10,
//               children: [
//                 // YES — delivered
//                 ChoiceChip(
//                   label: AutoText(
//                     'YES_MESSAGE',
//                     style: TextStyle(
//                       color: hasDelivered == true
//                           ? Colors.white
//                           : Colors.grey[700],
//                       fontWeight: hasDelivered == true
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                   selected: hasDelivered == true,
//                   selectedColor: Colors.green[600],
//                   backgroundColor: Colors.green[50],
//                   side: BorderSide(
//                     color: hasDelivered == true
//                         ? Colors.green[600]!
//                         : Colors.grey[300]!,
//                     width: 1.5,
//                   ),
//                   onSelected: (_) => setState(() => hasDelivered = true),
//                   elevation: hasDelivered == true ? 2 : 0,
//                 ),
//                 // NOT YET
//                 ChoiceChip(
//                   label: AutoText(
//                     // "Not Yet" — add this key to your i8ln
//                     'NOT_YET_MESSAGE',
//                     style: TextStyle(
//                       color: hasDelivered == false
//                           ? Colors.white
//                           : Colors.grey[700],
//                       fontWeight: hasDelivered == false
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                   selected: hasDelivered == false,
//                   selectedColor: Colors.orange[700],
//                   backgroundColor: Colors.orange[50],
//                   side: BorderSide(
//                     color: hasDelivered == false
//                         ? Colors.orange[700]!
//                         : Colors.grey[300]!,
//                     width: 1.5,
//                   ),
//                   onSelected: (_) => setState(() => hasDelivered = false),
//                   elevation: hasDelivered == false ? 2 : 0,
//                 ),
//               ],
//             ),

//             // Response after selection
//             if (hasDelivered == true) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.favorite, color: Colors.green[700], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: AutoText(
//                         // "Congratulations on your new baby! 🎉
//                         //  Please visit your health provider for postnatal care."
//                         'CONGRATULATIONS_DELIVERED',
//                         style: TextStyle(
//                           color: Colors.green[800],
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ] else if (hasDelivered == false) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.warning_amber_rounded,
//                         color: Colors.orange[700], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: AutoText(
//                         // "You are past your due date.
//                         //  Please contact your midwife or health provider today."
//                         'PAST_DUE_NO_DELIVERY_WARNING',
//                         style: TextStyle(
//                           color: Colors.orange[900],
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuestionCard({
//     required String title,
//     required String description,
//     required Widget content,
//     Color? iconColor,
//     IconData? icon,
//     bool isAnswered = true,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(
//           color: isAnswered ? Colors.transparent : Colors.red[300]!,
//           width: 2,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 if (icon != null)
//                   Icon(icon, color: iconColor ?? Colors.red[800], size: 24),
//                 if (icon != null) const SizedBox(width: 8),
//                 Expanded(
//                   child: AutoText(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red[800],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (description.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               AutoText(
//                 description,
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               ),
//             ],
//             const SizedBox(height: 12),
//             content,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildChoiceChips({
//     required List<String> options,
//     required String selectedValue,
//     required Function(String) onSelected,
//   }) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: options.map((option) {
//         Color chipColor;
//         const Color textColor = Colors.white;

//         if (option.toLowerCase().contains(autoI8lnGen.translate("YES_2")) ||
//             option.toLowerCase().contains(autoI8lnGen.translate("NOT_WELL"))) {
//           chipColor = Colors.red[600]!;
//         } else if (option.toLowerCase().contains(autoI8lnGen.translate("NO")) ||
//             option.toLowerCase().contains(autoI8lnGen.translate("FINE"))) {
//           chipColor = Colors.green[600]!;
//         } else {
//           chipColor = Colors.blue[600]!;
//         }

//         return ChoiceChip(
//           label: AutoText(
//             option,
//             style: TextStyle(
//               color: selectedValue == option ? textColor : Colors.grey[700],
//               fontWeight:
//                   selectedValue == option ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           selected: selectedValue == option,
//           selectedColor: chipColor,
//           backgroundColor: chipColor.withOpacity(0.1),
//           side: BorderSide(
//             color: selectedValue == option ? chipColor : Colors.grey[300]!,
//             width: 1.5,
//           ),
//           onSelected: (_) => onSelected(option),
//           elevation: selectedValue == option ? 2 : 0,
//           pressElevation: 4,
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildResponseText(String response) {
//     if (response.isEmpty) return const SizedBox.shrink();

//     Color responseColor;
//     IconData responseIcon;

//     if (response.contains(autoI8lnGen.translate("GREAT")) ||
//         response.contains('👍')) {
//       responseColor = Colors.green[700]!;
//       responseIcon = Icons.check_circle;
//     } else if (response.contains(autoI8lnGen.translate("CONTACT")) ||
//         response.contains(autoI8lnGen.translate("CALL"))) {
//       responseColor = Colors.red[700]!;
//       responseIcon = Icons.warning;
//     } else {
//       responseColor = Colors.blue[700]!;
//       responseIcon = Icons.info;
//     }

//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: responseColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: responseColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(responseIcon, color: responseColor, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: AutoText(
//               response,
//               style: TextStyle(
//                 color: responseColor,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getQuestionIcon(int index) {
//     switch (index) {
//       case 0:
//         return Icons.mood;
//       case 1:
//         return Icons.air;
//       case 2:
//         return Icons.psychology;
//       case 3:
//         return Icons.psychology;
//       case 4:
//         return Icons.thermostat;
//       case 5:
//         return Icons.sick;
//       case 6:
//         return Icons.bedtime;
//       case 7:
//         return Icons.child_care;
//       case 8:
//         return Icons.assignment;
//       case 9:
//         return Icons.healing;
//       case 10:
//         return Icons.pregnant_woman;
//       case 11:
//         return Icons.luggage;
//       default:
//         return Icons.help;
//     }
//   }

//   Color _getQuestionColor(int index) {
//     switch (index) {
//       case 0:
//         return Colors.green[600]!;
//       case 1:
//         return Colors.blue[600]!;
//       case 2:
//       case 3:
//         return Colors.purple[600]!;
//       case 4:
//         return Colors.red[600]!;
//       case 5:
//         return Colors.orange[600]!;
//       case 6:
//         return Colors.indigo[600]!;
//       case 7:
//         return Colors.pink[600]!;
//       case 8:
//         return Colors.teal[600]!;
//       case 9:
//         return Colors.amber[700]!;
//       case 10:
//         return Colors.purple[600]!;
//       case 11:
//         return Colors.brown[600]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (pregnancyWeek == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // If past due AND mother confirmed delivery → only show the delivery card
//     final bool hidePregnancyQuestions = isPastDue && hasDelivered == true;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Column(
//         children: [
//           // ── Compact header ──────────────────────────────────────────────────
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.red[800],
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(12),
//                 bottomRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.favorite, color: Colors.white, size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: AutoText(
//                     'F_T_M',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     AutoText(
//                       'TODAY_2 ${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}',
//                       style:
//                           const TextStyle(color: Colors.white70, fontSize: 11),
//                     ),
//                     AutoText(
//                       'DUEDATE ${widget.expectedDeliveryDate}',
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500),
//                     ),
//                     AutoText(
//                       // Show "Week 40+" if past due, otherwise normal week
//                       isPastDue
//                           ? 'W_PAST_DUE' // e.g. "Past Due Date"
//                           : 'Y_A_A ${pregnancyWeek!} W_P',
//                       style:
//                           const TextStyle(color: Colors.white70, fontSize: 11),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ── Body ────────────────────────────────────────────────────────────
//           Expanded(
//             child: ListView(
//               children: [
//                 const SizedBox(height: 16),

//                 // ── Delivery confirmation (shown when EDD passed) ────────────
//                 if (isPastDue) _buildDeliveryConfirmationCard(),

//                 // ── All pregnancy questions hidden if delivered ──────────────
//                 if (!hidePregnancyQuestions) ...[
//                   // Late-term warning banner (past due, not yet delivered)
//                   if (isPastDue && hasDelivered == false)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 4),
//                       child: AutoText(
//                         // "Please answer the questions below and contact
//                         //  your midwife as soon as possible."
//                         'PAST_DUE_CONTINUE_INSTRUCTIONS',
//                         style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.orange[800],
//                             fontStyle: FontStyle.italic),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),

//                   // ── Q0: General feeling ────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_7',
//                     description: 'YOUR_OVER_ALL_WELL',
//                     icon: _getQuestionIcon(0),
//                     iconColor: _getQuestionColor(0),
//                     isAnswered: isAnswered[0],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("FINE_2"),
//                             autoI8lnGen.translate("SO_SO"),
//                             autoI8lnGen.translate("N_T_W"),
//                           ],
//                           selectedValue: responses[0],
//                           onSelected: (value) => setState(() {
//                             responses[0] = value;
//                             isAnswered[0] = true;
//                             medicalResponses[0] = _generateResponse(0, value);
//                           }),
//                         ),
//                         _buildResponseText(medicalResponses[0]),
//                       ],
//                     ),
//                   ),

//                   // ── Q1: Breathing ──────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_8',
//                     description: 'S_O_B_N',
//                     icon: _getQuestionIcon(1),
//                     iconColor: _getQuestionColor(1),
//                     isAnswered: isAnswered[1],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("SAB"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                           ],
//                           selectedValue: responses[1],
//                           onSelected: (value) => setState(() {
//                             responses[1] = value;
//                             isAnswered[1] = true;
//                             medicalResponses[1] = _generateResponse(1, value);
//                           }),
//                         ),
//                         _buildResponseText(medicalResponses[1]),
//                       ],
//                     ),
//                   ),

//                   // ── Q2: Headaches ──────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_9',
//                     description: 'F_D_P_E',
//                     icon: _getQuestionIcon(2),
//                     iconColor: _getQuestionColor(2),
//                     isAnswered: isAnswered[2],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("SAB"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                           ],
//                           selectedValue: responses[2],
//                           onSelected: (value) => setState(() {
//                             responses[2] = value;
//                             isAnswered[2] = true;
//                             medicalResponses[2] = _generateResponse(2, value);
//                           }),
//                         ),
//                         _buildResponseText(medicalResponses[2]),
//                       ],
//                     ),
//                   ),

//                   // ── Q3: Follow-up headache (only if Q2 = Yes) ─────────────
//                   if (responses[2] == autoI8lnGen.translate("YES_MESSAGE"))
//                     _buildQuestionCard(
//                       title: 'HEALTH_QUESTION_10',
//                       description: 'C_H_S_U',
//                       icon: _getQuestionIcon(3),
//                       iconColor: _getQuestionColor(3),
//                       isAnswered: isAnswered[3],
//                       content: Column(
//                         children: [
//                           _buildChoiceChips(
//                             options: [
//                               autoI8lnGen.translate("YES_MESSAGE"),
//                               autoI8lnGen.translate("NO_MESSAGE"),
//                             ],
//                             selectedValue: responses[3],
//                             onSelected: (value) => setState(() {
//                               responses[3] = value;
//                               isAnswered[3] = true;
//                               medicalResponses[3] = _generateResponse(3, value);
//                             }),
//                           ),
//                           _buildResponseText(medicalResponses[3]),
//                         ],
//                       ),
//                     ),

//                   // ── Q4: Fever ──────────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_11',
//                     description: 'F_DP_B',
//                     icon: _getQuestionIcon(4),
//                     iconColor: _getQuestionColor(4),
//                     isAnswered: isAnswered[4],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
//                           ],
//                           selectedValue: responses[4],
//                           onSelected: (value) => setState(() {
//                             responses[4] = value;
//                             isAnswered[4] = true;
//                             medicalResponses[4] = _generateResponse(4, value);
//                           }),
//                         ),
//                         _buildResponseText(medicalResponses[4]),
//                       ],
//                     ),
//                   ),

//                   // ── Q5: Nausea ─────────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_12',
//                     description: 'M_SICKNESS_C',
//                     icon: _getQuestionIcon(5),
//                     iconColor: _getQuestionColor(5),
//                     isAnswered: isAnswered[5],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                           ],
//                           selectedValue: responses[5],
//                           onSelected: (value) => setState(() {
//                             responses[5] = value;
//                             isAnswered[5] = true;
//                             medicalResponses[5] = _generateResponse(5, value);
//                           }),
//                         ),
//                         _buildResponseText(medicalResponses[5]),
//                       ],
//                     ),
//                   ),

//                   // ── Q6: Sleep ──────────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_13',
//                     description: 'G_B_H',
//                     icon: _getQuestionIcon(6),
//                     iconColor: _getQuestionColor(6),
//                     isAnswered: isAnswered[6],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("SAME_BEFORE"),
//                           ],
//                           selectedValue: responses[6],
//                           onSelected: (value) => setState(() {
//                             responses[6] = value;
//                             isAnswered[6] = true;
//                             medicalResponses[6] = _generateResponse(6, value);
//                           }),
//                         ),
//                         _buildResponseText(medicalResponses[6]),
//                       ],
//                     ),
//                   ),

//                   // ── Q7: Baby kicks (≥20 weeks) ─────────────────────────────
//                   if (pregnancyWeek! >= 20)
//                     _buildQuestionCard(
//                       title: 'HEALTH_QUESTION_14',
//                       description: 'B_M_G',
//                       icon: _getQuestionIcon(7),
//                       iconColor: _getQuestionColor(7),
//                       isAnswered: isAnswered[7],
//                       content: Column(
//                         children: [
//                           _buildChoiceChips(
//                             options: [
//                               autoI8lnGen.translate("YES_MESSAGE"),
//                               autoI8lnGen.translate("NO_MESSAGE"),
//                               autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
//                             ],
//                             selectedValue: responses[7],
//                             onSelected: (value) => setState(() {
//                               responses[7] = value;
//                               isAnswered[7] = true;
//                               medicalResponses[7] = _generateResponse(7, value);
//                             }),
//                           ),
//                           _buildResponseText(medicalResponses[7]),
//                         ],
//                       ),
//                     ),

//                   // ── Q8: Birth plan ─────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'HEALTH_QUESTION_15',
//                     description: 'P_AHEAD',
//                     icon: _getQuestionIcon(8),
//                     iconColor: _getQuestionColor(8),
//                     isAnswered: isAnswered[8],
//                     content: Column(
//                       children: [
//                         _buildChoiceChips(
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                           ],
//                           selectedValue: responses[8],
//                           onSelected: (value) => setState(() {
//                             responses[8] = value;
//                             isAnswered[8] = true;
//                             medicalResponses[8] = _generateResponse(8, value);
//                           }),
//                         ),
//                         if (responses[8] == autoI8lnGen.translate("NO_MESSAGE"))
//                           Container(
//                             margin: const EdgeInsets.only(top: 12),
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                   color: Colors.orange.withOpacity(0.3)),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.info_outline,
//                                     color: Colors.orange[700], size: 20),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: _navToBirthPlan,
//                                     child: RichText(
//                                       text: TextSpan(
//                                         style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.orange[700]),
//                                         children: [
//                                           TextSpan(
//                                               text: autoI8lnGen.translate(
//                                                       "START_N_B_P_S") +
//                                                   ' '),
//                                           TextSpan(
//                                             text: autoI8lnGen
//                                                 .translate("GO_TO_BIRTH_PLAN"),
//                                             style: const TextStyle(
//                                               color: Colors.blue,
//                                               fontWeight: FontWeight.bold,
//                                               decoration:
//                                                   TextDecoration.underline,
//                                             ),
//                                             recognizer: TapGestureRecognizer()
//                                               ..onTap = _navToBirthPlan,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         else
//                           _buildResponseText(medicalResponses[8]),
//                       ],
//                     ),
//                   ),

//                   // ── Q9: Swelling (≥28 weeks) ───────────────────────────────
//                   if (pregnancyWeek! >= 28)
//                     _buildQuestionCard(
//                       title: 'HEALTH_QUESTION_16',
//                       description: 'SWELLING_NORMAL',
//                       icon: _getQuestionIcon(9),
//                       iconColor: _getQuestionColor(9),
//                       isAnswered: isAnswered[9],
//                       content: Column(
//                         children: [
//                           _buildChoiceChips(
//                             options: [
//                               autoI8lnGen.translate("YES_MESSAGE"),
//                               autoI8lnGen.translate("NO_MESSAGE"),
//                               autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
//                             ],
//                             selectedValue: responses[9],
//                             onSelected: (value) => setState(() {
//                               responses[9] = value;
//                               isAnswered[9] = true;
//                               medicalResponses[9] = _generateResponse(9, value);
//                             }),
//                           ),
//                           _buildResponseText(medicalResponses[9]),
//                         ],
//                       ),
//                     ),

//                   // ── Q10: Contractions (≥24 weeks) ─────────────────────────
//                   if (pregnancyWeek! >= 24)
//                     _buildQuestionCard(
//                       title: 'HEALTH_QUESTION_17',
//                       description: 'C_37',
//                       icon: _getQuestionIcon(10),
//                       iconColor: _getQuestionColor(10),
//                       isAnswered: isAnswered[10],
//                       content: Column(
//                         children: [
//                           _buildChoiceChips(
//                             options: [
//                               autoI8lnGen.translate("YES_MESSAGE"),
//                               autoI8lnGen.translate("NO_MESSAGE"),
//                               autoI8lnGen.translate("DONT_KNOW_REMEMBER"),
//                             ],
//                             selectedValue: responses[10],
//                             onSelected: (value) => setState(() {
//                               responses[10] = value;
//                               isAnswered[10] = true;
//                               medicalResponses[10] =
//                                   _generateResponse(10, value);
//                             }),
//                           ),
//                           _buildResponseText(medicalResponses[10]),
//                         ],
//                       ),
//                     ),

//                   // ── Q11: Hospital bag (≥36 weeks) ──────────────────────────
//                   if (pregnancyWeek! >= 36)
//                     _buildQuestionCard(
//                       title: 'HEALTH_QUESTION_18',
//                       description: 'B_P_DE',
//                       icon: _getQuestionIcon(11),
//                       iconColor: _getQuestionColor(11),
//                       isAnswered: isAnswered[11],
//                       content: Column(
//                         children: [
//                           _buildChoiceChips(
//                             options: [
//                               autoI8lnGen.translate("YES_MESSAGE"),
//                               autoI8lnGen.translate("NO_MESSAGE"),
//                             ],
//                             selectedValue: responses[11],
//                             onSelected: (value) => setState(() {
//                               responses[11] = value;
//                               isAnswered[11] = true;
//                               medicalResponses[11] =
//                                   _generateResponse(11, value);
//                             }),
//                           ),
//                           _buildResponseText(medicalResponses[11]),
//                         ],
//                       ),
//                     ),

//                   // ── Other concerns ─────────────────────────────────────────
//                   _buildQuestionCard(
//                     title: 'A_O_Q',
//                     description: 'F_F_C_H',
//                     icon: Icons.message,
//                     iconColor: Colors.blue[600],
//                     content: TextField(
//                       controller: worryController,
//                       maxLines: 3,
//                       decoration: InputDecoration(
//                         hintText: autoI8lnGen.translate("T_U_C"),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide:
//                               BorderSide(color: Colors.red[800]!, width: 2),
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ], // end !hidePregnancyQuestions

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: _submitForm,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red[800],
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 2,
//           ),
//           child: AutoText(
//             'S_F_R',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   String _generateResponse(int index, String answer) {
//     switch (index) {
//       case 0:
//         return answer == autoI8lnGen.translate("FINE_2")
//             ? autoI8lnGen.translate("G_K_U")
//             : answer == autoI8lnGen.translate("SO_SO")
//                 ? autoI8lnGen.translate("CALL_CHW")
//                 : autoI8lnGen.translate("P_C_H");
//       case 1:
//         return answer == autoI8lnGen.translate("NO_MESSAGE")
//             ? autoI8lnGen.translate("G_T_H")
//             : autoI8lnGen.translate("D_P_NEXT");
//       case 2:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("HEALTH_QUESTION_10")
//             : answer == autoI8lnGen.translate("NO_MESSAGE")
//                 ? '👍'
//                 : autoI8lnGen.translate("M_CHW_P");
//       case 3:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("C_Y_P_M")
//             : autoI8lnGen.translate("M_T_V");
//       case 4:
//         return answer == autoI8lnGen.translate("NO_MESSAGE")
//             ? '👍'
//             : answer == autoI8lnGen.translate("YES_MESSAGE")
//                 ? autoI8lnGen.translate("C_H_P")
//                 : autoI8lnGen.translate("A_S_T");
//       case 5:
//         return answer == autoI8lnGen.translate("NO_MESSAGE")
//             ? '👍'
//             : (pregnancyWeek! < 14
//                 ? autoI8lnGen.translate("IT_WILL_PASS")
//                 : autoI8lnGen.translate("P_C_P"));
//       case 6:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? '👍'
//             : autoI8lnGen.translate("ASK_CHW");
//       case 7:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("👍 THAT_GOOD_SIGN")
//             : answer == autoI8lnGen.translate("NO_MESSAGE")
//                 ? autoI8lnGen.translate("C_H_P")
//                 : autoI8lnGen.translate("T_A_C");
//       case 8:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("👍 G_K_P")
//             : autoI8lnGen.translate("START_N_B_P_S");
//       case 9:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("C_CHW_S")
//             : '👍';
//       case 10:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("T_T_F_P")
//             : '👍';
//       case 11:
//         return answer == autoI8lnGen.translate("YES_MESSAGE")
//             ? autoI8lnGen.translate("G_J_READY")
//             : autoI8lnGen.translate("P_P_H_B");
//       default:
//         return '';
//     }
//   }

//   void _submitForm() async {
//     // If past due and delivered → submit delivery confirmation only
//     if (isPastDue && hasDelivered == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: AutoText('PLEASE_ANSWER_DELIVERY_Q'),
//           backgroundColor: Colors.red[600],
//         ),
//       );
//       return;
//     }

//     // If delivered, skip pregnancy question validation entirely
//     if (!(isPastDue && hasDelivered == true)) {
//       List<int> unansweredQuestions = [];
//       for (int i = 0; i < responses.length; i++) {
//         bool shouldAnswer = true;
//         if (i == 3 && responses[2] != autoI8lnGen.translate("YES_MESSAGE"))
//           shouldAnswer = false;
//         if (i == 7 && pregnancyWeek! < 20) shouldAnswer = false;
//         if (i == 9 && pregnancyWeek! < 28) shouldAnswer = false;
//         if (i == 10 && pregnancyWeek! < 24) shouldAnswer = false;
//         if (i == 11 && pregnancyWeek! < 36) shouldAnswer = false;

//         if (shouldAnswer && responses[i].isEmpty) {
//           unansweredQuestions.add(i);
//           isAnswered[i] = false;
//         }
//       }
//       if (unansweredQuestions.isNotEmpty) {
//         setState(() {});
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: AutoText('P_A_Q_S'),
//             backgroundColor: Colors.red[600],
//           ),
//         );
//         return;
//       }
//     }

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null || pregnancyWeek == null) return;

//       final userId = user.uid;
//       final date =
//           '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

//       final providerQuery = await FirebaseFirestore.instance
//           .collection('allowed_to_chat')
//           .where('requesterId', isEqualTo: userId)
//           .get();

//       final providerIds = providerQuery.docs
//           .map((doc) => doc['recipientId'] as String)
//           .toList();

//       final data = {
//         'date': date,
//         'expectedDeliveryDate': widget.expectedDeliveryDate,
//         'pregnancyWeek': pregnancyWeek,
//         'isPastDue': isPastDue,
//         'hasDelivered': hasDelivered, // NEW field
//         'questions': responses,
//         'medicalResponses': medicalResponses,
//         'otherWorries': worryController.text,
//         'motherId': userId,
//         'providerIds': providerIds,
//       };

//       final motherRef = FirebaseFirestore.instance
//           .collection('mother_pregnancy_data')
//           .doc(userId)
//           .collection('mother_periodic_feeling_form');
//       final docRef = await motherRef.add(data);

//       await FirebaseFirestore.instance
//           .collection('mother_pregnancy_data')
//           .doc(userId)
//           .set({
//         'expectedDeliveryDate': widget.expectedDeliveryDate,
//         'userId': userId,
//         'hasDelivered': hasDelivered ?? false, // NEW field on parent doc
//         'lastUpdated': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       final globalRef = await FirebaseFirestore.instance
//           .collection('mother_pregnancy_data')
//           .doc(userId)
//           .collection('mother_feeling_responses')
//           .add({
//         ...data,
//         'motherDocId': docRef.id,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       for (final providerId in providerIds) {
//         await FirebaseFirestore.instance
//             .collection('health_provider_data')
//             .doc(providerId)
//             .collection('patience_responses')
//             .doc(userId)
//             .collection('responses')
//             .add({
//           ...data,
//           'motherDocId': docRef.id,
//           'globalDocId': globalRef.id,
//           'providerId': providerId,
//         });
//       }

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.green, size: 24),
//                 const SizedBox(width: 8),
//                 AutoText('R_S_U', style: const TextStyle(color: Colors.green)),
//               ],
//             ),
//             content: AutoText('T_M_I'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: AutoText('OK'),
//               ),
//             ],
//           );
//         },
//       );

//       setState(() {
//         responses.fillRange(0, responses.length, '');
//         medicalResponses.fillRange(0, medicalResponses.length, '');
//         isAnswered.fillRange(0, isAnswered.length, true);
//         worryController.clear();
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: AutoText('F_T_S: $e'),
//           backgroundColor: Colors.red[600],
//         ),
//       );
//     }
//   }
// }
