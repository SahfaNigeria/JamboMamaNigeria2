import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthcareProfessionalAssessmentScreen extends StatefulWidget {
  final String patientId;
  //final String patientName;

  const HealthcareProfessionalAssessmentScreen({
    Key? key,
    required this.patientId,
    // required this.patientName,
  }) : super(key: key);

  @override
  _HealthcareProfessionalAssessmentScreenState createState() =>
      _HealthcareProfessionalAssessmentScreenState();
}

class _HealthcareProfessionalAssessmentScreenState
    extends State<HealthcareProfessionalAssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Patient Assessment: ${widget.patientName}'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_assessments')
            .where('userId', isEqualTo: widget.patientId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: AutoText('ERROR: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return  Center(
              child: AutoText('ASSESSMENT_NOT_FOUND'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Sort documents by timestamp in Dart instead of Firestore
              final docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final aTime = (a.data() as Map<String, dynamic>)['timestamp']
                    as Timestamp?;
                final bTime = (b.data() as Map<String, dynamic>)['timestamp']
                    as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime); // Descending order
              });

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(data),
                      const SizedBox(height: 16),
                      _buildCriticalAlerts(data),
                      const SizedBox(height: 16),
                      _buildAssessmentSections(data),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final formattedDate = timestamp != null
        ? "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
        : "UNKNOWN_DATE";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_information, color: Colors.teal[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoText(
                  'EMERGENCY_ASSESSMENT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                AutoText(
                  'SUBMITTED $formattedDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlerts(Map<String, dynamic> data) {
    List<Widget> alerts = [];

    // Check for high-priority symptoms
    if (data['hasVaginalBleeding'] == true &&
        data['bleedingAmount'] == autoI8lnGen.translate("HEAVY")) {
      alerts.add(
          _buildAlert('CRITICAL_VAGINA', Colors.red));
    }

    if (data['babyStoppedMoving'] == true) {
      alerts.add(_buildAlert(
          'URGENT_VAGINA', Colors.red));
    }

    if (data['hasContractions'] == true &&
        data['contractionType'] == autoI8lnGen.translate('REGULAR_PAINFUL')) {
      alerts.add(
          _buildAlert('URGENT_VAGINA_2', Colors.orange));
    }

    if (data['hasFever'] == true) {
      alerts.add(_buildAlert('WARNING_1', Colors.orange));
    }

    if (data['headacheSeverity'] == autoI8lnGen.translate('SEVERE')) {
      alerts
          .add(_buildAlert('WARNING_2', Colors.orange));
    }

    if (alerts.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(
          'PRIORITY_ALERTS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 8),
        ...alerts,
      ],
    );
  }

  Widget _buildAlert(String message, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(left: BorderSide(width: 4, color: color)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: AutoText(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentSections(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildSection('BLEEDING_DISCHARGE', [
          _buildSymptomRow('V_BLEEDING', data['hasVaginalBleeding'],
              details: data['hasVaginalBleeding'] == true
                  ? 'AMNT ${data['bleedingAmount'] ?? 'NOT_SPECIFIED'}'
                  : null),
          _buildSymptomRow('V_DISCHARGE', data['hasVaginalDischarge'],
              details: data['hasVaginalDischarge'] == true
                  ? 'DURATION ${data['dischargeDuration'] ?? 'NOT_SPECIFIED'}'
                  : null),
          _buildSymptomRow('FLUID_LOSS', data['hasFluidLoss'],
              details: data['hasFluidLoss'] == true
                  ? 'AMNT ${data['fluidAmount'] ?? 'NOT_SPECIFIED'}'
                  : null),
        ]),
        _buildSection('U_D', [
          _buildSymptomRow('B_U', data['hasBurningUrination']),
          _buildSymptomRow('DIARRHEA', data['hasDiarrhea'],
              details: data['hasDiarrhea'] == true
                  ? 'DURATION ${data['diarrheadays'] ?? 'NOT_SPECIFIED'} DAYS, FREQUENCY ${data['diarrheaFrequency'] ?? 'NOT_SPECIFIED'}'
                  : null),
        ]),
        _buildSection('GENERAL_S', [
          _buildSymptomRow('FEVER', data['hasFever']),
          _buildSymptomRow('COUGH', data['hasCough'],
              details: data['hasCough'] == true
                  ? 'TIMING ${data['coughTiming'] ?? 'NOT_SPECIFIED'}, DURATION ${data['coughDays'] ?? 'NOT_SPECIFIED'} DAYS'
                  : null),
          _buildSymptomRow('S_L', data['hasSwollenLegs']),
          _buildSymptomRow('N_B', data['hasNumbness']),
          _buildSymptomRow('H_D', data['hasHeadache'],
              details: data['hasHeadache'] == true
                  ? 'SEVERITY ${data['headacheSeverity'] ?? 'NOT_SPECIFIED'}'
                  : null),
        ]),
        _buildSection('PREGNANCY_SPECIFIC', [
          _buildSymptomRow('CONTRACTIONS', data['hasContractions'],
              details: data['hasContractions'] == true
                  ? 'TYPE ${data['contractionType'] ?? 'NOT_SPECIFIED'}'
                  : null),
          _buildSymptomRow('BABY_STOPPED_MOVING', data['babyStoppedMoving']),
        ]),
        if (data['otherConcerns'] != null &&
            data['otherConcerns'].toString().isNotEmpty)
          _buildSection('ADDITIONAL_CONCERNS_2', [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: AutoText(
                data['otherConcerns'].toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal[700],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomRow(String symptom, dynamic hasSymptom,
      {String? details}) {
    final bool isPresent = hasSymptom == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? Colors.red : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AutoText(
                  symptom,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isPresent ? FontWeight.w600 : FontWeight.normal,
                    color: isPresent ? Colors.red[700] : Colors.green[700],
                  ),
                ),
              ),
              AutoText(
                isPresent ? 'YES' : 'NO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPresent ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          if (details != null && isPresent)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: AutoText(
                details,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Usage example - you would call this screen like:
/*
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => HealthcareProfessionalAssessmentScreen(
      patientId: 'patient-user-id',
      patientName: 'Patient Name',
    ),
  ),
);
*/