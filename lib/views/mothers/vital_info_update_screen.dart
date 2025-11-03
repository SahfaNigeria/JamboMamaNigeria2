// Vital Info Update Screen - with JamboMama UI theme + guidance logic

import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VitalInfoUpdateScreen extends StatefulWidget {
  final String userId;
  final int currentWeek;
  final double? initialWeight;
  final double? initialBmi;

  const VitalInfoUpdateScreen({
    Key? key,
    required this.userId,
    required this.currentWeek,
    this.initialWeight,
    this.initialBmi,
  }) : super(key: key);

  @override
  _VitalInfoUpdateScreenState createState() => _VitalInfoUpdateScreenState();
}

class  _VitalInfoUpdateScreenState extends State<VitalInfoUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _haemoglobinController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _albuminController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _fundaHeightController = TextEditingController();
  final TextEditingController _babyHeartbeatController =
      TextEditingController();

  String _urineAnalysis = autoI8lnGen.translate("NORMAL");
  bool _isLoading = false;

  String _weightGuidance = '';
  String _hbGuidance = '';
  String _bpGuidance = '';
  String _albuminGuidance = '';
  String _glucoseGuidance = '';
  String _pulseGuidance = '';

  // Function to save vital info to Firestore

  Future<void> _submitVitalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Fallback — find connected provider
      String? providerId;
      final query = await _firestore
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        providerId = query.docs.first['recipientId'];
        print('✅ Connected provider found: $providerId');
      } else {
        print('⚠️ No connected provider found for user: ${widget.userId}');
      }

      // Step 2: Prepare data
      final vitalInfoData = {
        'userId': widget.userId,
        'providerId': providerId ?? '',
        'currentWeek': widget.currentWeek,
        'weight': _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        'haemoglobin': _haemoglobinController.text.isNotEmpty
            ? double.tryParse(_haemoglobinController.text)
            : null,
        'systolicPressure': _systolicController.text.isNotEmpty
            ? int.tryParse(_systolicController.text)
            : null,
        'diastolicPressure': _diastolicController.text.isNotEmpty
            ? int.tryParse(_diastolicController.text)
            : null,
        'albumin': _albuminController.text.isNotEmpty
            ? double.tryParse(_albuminController.text)
            : null,
        'glucose': _glucoseController.text.isNotEmpty
            ? double.tryParse(_glucoseController.text)
            : null,
        'urineAnalysis': _urineAnalysis,
        'pulseRate': _pulseController.text.isNotEmpty
            ? int.tryParse(_pulseController.text)
            : null,
        'fundalHeight': _fundaHeightController.text.isNotEmpty
            ? double.tryParse(_fundaHeightController.text)
            : null,
        'babyHeartbeat': _babyHeartbeatController.text.isNotEmpty
            ? int.tryParse(_babyHeartbeatController.text)
            : null,
        'timestamp': FieldValue.serverTimestamp(),
        'dateRecorded': DateTime.now().toIso8601String(),
      };

      // Step 3: Save to main vital_info collection
      await _firestore.collection('vital_info').add(vitalInfoData);

      // Step 4: Save a copy to the connected provider (if any)
      if (providerId != null && providerId.isNotEmpty) {
        final providerRef = _firestore
            .collection('health_provider_data')
            .doc(providerId)
            .collection('vital_info_from_patients')
            .doc(widget.userId)
            .collection('records');

        await providerRef.add(vitalInfoData);
        print('✅ Vital info also saved to provider’s view.');
      }

      // Step 5: Update latest info for patient
      await _firestore.collection('users').doc(widget.userId).update({
        'latestVitalInfo': vitalInfoData,
        'lastVitalInfoUpdate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoText('V_I_SAVED'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText('E_S_V_I ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getWeightGuidance(double? currentWeight) {
    if (currentWeight == null || widget.initialWeight == null) return '';
    double weightGain = currentWeight - widget.initialWeight!;
    double? bmi = widget.initialBmi;
    String guidance = '';
    if (widget.currentWeek <= 18 && weightGain > 3) {
      guidance = autoI8lnGen.translate("R_W_G_1");
    } else if (widget.currentWeek >= 19 &&
        widget.currentWeek <= 28 &&
        (weightGain < 2 || weightGain > 4)) {
      guidance = autoI8lnGen.translate("R_W_G_2");
    } else if (widget.currentWeek >= 29 && (weightGain < 3 || weightGain > 5)) {
      guidance = autoI8lnGen.translate("R_W_G_3");
    }
    if (bmi != null) {
      if (bmi < 18.5) {
        guidance += autoI8lnGen.translate("R_W_G_4");
      } else if (bmi <= 24.9) {
        guidance += autoI8lnGen.translate("R_W_G_5");
      } else if (bmi < 30) {
        guidance += autoI8lnGen.translate("R_W_G_6");
      } else {
        guidance += autoI8lnGen.translate("R_W_G_7");
      }
    }
    return guidance;
  }

  String _getHaemoglobinGuidance(double? hb) {
    if (hb == null) return autoI8lnGen.translate("R_W_G_8");
    if (hb < 10.5) return autoI8lnGen.translate("R_W_G_9");
    if (hb <= 12) return autoI8lnGen.translate("R_W_G_10");
    if (hb > 14) return autoI8lnGen.translate("R_W_G_11");
    return '';
  }

  String _getBloodPressureGuidance(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return '';
    if (systolic >= 90 &&
        systolic <= 120 &&
        diastolic >= 60 &&
        diastolic <= 80) {
      return autoI8lnGen.translate("👍 R_W_G_11");
    } else if (systolic <= 129 && diastolic <= 89) {
      return autoI8lnGen.translate("R_W_G_12");
    } else if (systolic <= 139 && diastolic < 90) {
      return autoI8lnGen.translate("R_W_G_13");
    } else if (systolic > 140 && diastolic > 90) {
      return autoI8lnGen.translate("R_W_G_14");
    } else if (systolic > 160 && diastolic > 100) {
      return autoI8lnGen.translate("R_W_G_15");
    }
    return autoI8lnGen.translate("R_W_G_16");
  }

  String _getAlbuminGuidance(double? albumin) {
    if (albumin == null) return '';
    if (albumin <= 150) return autoI8lnGen.translate("👍 NORMAL");
    return autoI8lnGen.translate("R_W_G_17");
  }

  String _getGlucoseGuidance(double? glucose) {
    if (glucose == null) return '';
    if (glucose < 7.8) return autoI8lnGen.translate("👍 NORMAL");
    if (glucose < 11.0) return autoI8lnGen.translate("R_W_G_18");
    ;
    return autoI8lnGen.translate("R_W_G_19");
  }

  String _getPulseGuidance(int? pulse) {
    if (pulse == null) return '';
    if (pulse <= 90) return autoI8lnGen.translate("👍 R_W_G_20");
    if (pulse <= 100) return autoI8lnGen.translate("R_W_G_21");
    ;
    return autoI8lnGen.translate("R_W_G_22");
  }

  Widget _buildGuidance(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red[800], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: AutoText(
              message,
              style: TextStyle(color: Colors.red[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Improved header section widget
  Widget _buildHeaderSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red[50]!,
              Colors.red[100]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AutoText(
                    'R_W_G_23',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(autoI8lnGen.translate('🩺 R_W_G_24')),
                      _buildInfoChip(autoI8lnGen.translate('💓 R_W_G_25')),
                      _buildInfoChip(autoI8lnGen.translate('⚖️ WEIGHT')),
                      _buildInfoChip(autoI8lnGen.translate('💧 URINE')),
                      _buildInfoChip(autoI8lnGen.translate('🩸 HAEMOGLO')),
                      _buildInfoChip(autoI8lnGen.translate('🤰 B_H')),
                      _buildInfoChip(autoI8lnGen.translate('👶 B_H_B')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[800], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AutoText(
                      'NHCAC',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: AutoText(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.red[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _weightController.addListener(() {
      final val = double.tryParse(_weightController.text);
      setState(() => _weightGuidance = _getWeightGuidance(val));
    });
    _haemoglobinController.addListener(() {
      final val = double.tryParse(_haemoglobinController.text);
      setState(() => _hbGuidance = _getHaemoglobinGuidance(val));
    });
    _systolicController.addListener(() {
      final s = int.tryParse(_systolicController.text);
      final d = int.tryParse(_diastolicController.text);
      setState(() => _bpGuidance = _getBloodPressureGuidance(s, d));
    });
    _diastolicController.addListener(() {
      final s = int.tryParse(_systolicController.text);
      final d = int.tryParse(_diastolicController.text);
      setState(() => _bpGuidance = _getBloodPressureGuidance(s, d));
    });
    _albuminController.addListener(() {
      final val = double.tryParse(_albuminController.text);
      setState(() => _albuminGuidance = _getAlbuminGuidance(val));
    });
    _glucoseController.addListener(() {
      final val = double.tryParse(_glucoseController.text);
      setState(() => _glucoseGuidance = _getGlucoseGuidance(val));
    });
    _pulseController.addListener(() {
      final val = int.tryParse(_pulseController.text);
      setState(() => _pulseGuidance = _getPulseGuidance(val));
    });
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    required Widget child,
    String? guidance,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: Colors.red[800], size: 20),
                if (icon != null) const SizedBox(width: 8),
                Expanded(
                  child: AutoText(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
            (guidance != null && guidance.isNotEmpty)
                ? _buildGuidance(guidance)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoText('VITAL_INFO_UPDATE_2'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(), // Updated header section

              _buildCard(
                title: 'WEIGHT_KG',
                icon: Icons.monitor_weight,
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: autoI8lnGen.translate("E_C_W")),
                ),
                guidance: _weightGuidance,
              ),
              _buildCard(
                title: 'HEAMOGOBLIN_T',
                icon: Icons.opacity,
                child: TextFormField(
                  controller: _haemoglobinController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(hintText: autoI8lnGen.translate("EN_H")),
                ),
                guidance: _hbGuidance,
              ),
              _buildCard(
                title: 'BLOOD_PRESSURE',
                icon: Icons.bloodtype,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _systolicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("SYSTOLIC")),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("DIASTOLIC")),
                      ),
                    ),
                  ],
                ),
                guidance: _bpGuidance,
              ),
              _buildCard(
                title: 'ALBUMIN_URINE',
                icon: Icons.science,
                child: TextFormField(
                  controller: _albuminController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: autoI8lnGen.translate("ENTER_ALBUMIN")),
                ),
                guidance: _albuminGuidance,
              ),
              _buildCard(
                title: 'GLUCOSE_URINE',
                icon: Icons.bubble_chart,
                child: TextFormField(
                  controller: _glucoseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: autoI8lnGen.translate("ENTER_GLUCOSE")),
                ),
                guidance: _glucoseGuidance,
              ),
              _buildCard(
                title: 'URINE_ANALYSIS',
                icon: Icons.analytics,
                child: DropdownButtonFormField<String>(
                  value: _urineAnalysis,
                  items: [
                    autoI8lnGen.translate("NORMAL"),
                    autoI8lnGen.translate("SO_SO"),
                    autoI8lnGen.translate("DANGER")
                  ].map((val) {
                    return DropdownMenuItem(value: val, child: AutoText(val));
                  }).toList(),
                  onChanged: (val) => setState(() => _urineAnalysis = val!),
                ),
              ),
              _buildCard(
                title: 'PULSE_RATE_2',
                icon: Icons.favorite,
                child: TextFormField(
                  controller: _pulseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: autoI8lnGen.translate("ENTER_PULSE_RATE")),
                ),
                guidance: _pulseGuidance,
              ),
              if (widget.currentWeek >= 20)
                _buildCard(
                  title: 'F_HEIGHT',
                  icon: Icons.height,
                  child: TextFormField(
                    controller: _fundaHeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: autoI8lnGen.translate("ENTER_F_HEIGHT")),
                  ),
                ),
              if (widget.currentWeek >= 20)
                _buildCard(
                  title: 'B_HEARTBEAT',
                  icon: Icons.monitor_heart,
                  child: TextFormField(
                    controller: _babyHeartbeatController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: autoI8lnGen.translate("ENTER_B_HEARTBEAT")),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitVitalInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const AutoText('S_V_I',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _haemoglobinController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _albuminController.dispose();
    _glucoseController.dispose();
    _pulseController.dispose();
    _fundaHeightController.dispose();
    _babyHeartbeatController.dispose();
    super.dispose();
  }
}
