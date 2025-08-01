import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthcareProfessionalAssessmentScreen extends StatefulWidget {
  final String patientId;
  final String assessmentId;

  const HealthcareProfessionalAssessmentScreen({
    Key? key,
    required this.patientId,
    required this.assessmentId,
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
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No emergency assessments found for this patient.'),
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
        : "Unknown date";

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
                Text(
                  'Emergency Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                Text(
                  'Submitted: $formattedDate',
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
        data['bleedingAmount'] == 'Heavy') {
      alerts.add(
          _buildAlert('CRITICAL: Heavy vaginal bleeding reported', Colors.red));
    }

    if (data['babyStoppedMoving'] == true) {
      alerts.add(_buildAlert(
          'URGENT: Patient reports baby stopped moving', Colors.red));
    }

    if (data['hasContractions'] == true &&
        data['contractionType'] == 'Regular and painful') {
      alerts.add(
          _buildAlert('URGENT: Regular painful contractions', Colors.orange));
    }

    if (data['hasFever'] == true) {
      alerts.add(_buildAlert('WARNING: Fever present', Colors.orange));
    }

    if (data['headacheSeverity'] == 'Severe') {
      alerts
          .add(_buildAlert('WARNING: Severe headache reported', Colors.orange));
    }

    if (alerts.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIORITY ALERTS',
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
            child: Text(
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
        _buildHeader(data['patientName'] ?? 'Unknown Patient'), //New Addition, untested.
        _buildSection('Bleeding & Discharge', [
          _buildSymptomRow('Vaginal Bleeding', data['hasVaginalBleeding'],
              details: data['hasVaginalBleeding'] == true
                  ? 'Amount: ${data['bleedingAmount'] ?? 'Not specified'}'
                  : null),
          _buildSymptomRow('Vaginal Discharge', data['hasVaginalDischarge'],
              details: data['hasVaginalDischarge'] == true
                  ? 'Duration: ${data['dischargeDuration'] ?? 'Not specified'}'
                  : null),
          _buildSymptomRow('Fluid Loss', data['hasFluidLoss'],
              details: data['hasFluidLoss'] == true
                  ? 'Amount: ${data['fluidAmount'] ?? 'Not specified'}'
                  : null),
        ]),
        _buildSection('Urinary & Digestive', [
          _buildSymptomRow('Burning Urination', data['hasBurningUrination']),
          _buildSymptomRow('Diarrhea', data['hasDiarrhea'],
              details: data['hasDiarrhea'] == true
                  ? 'Duration: ${data['diarrheadays'] ?? 'Not specified'} days, Frequency: ${data['diarrheaFrequency'] ?? 'Not specified'}'
                  : null),
        ]),
        _buildSection('General Symptoms', [
          _buildSymptomRow('Fever', data['hasFever']),
          _buildSymptomRow('Cough', data['hasCough'],
              details: data['hasCough'] == true
                  ? 'Timing: ${data['coughTiming'] ?? 'Not specified'}, Duration: ${data['coughDays'] ?? 'Not specified'} days'
                  : null),
          _buildSymptomRow('Swollen Legs', data['hasSwollenLegs']),
          _buildSymptomRow('Numbness', data['hasNumbness']),
          _buildSymptomRow('Headache', data['hasHeadache'],
              details: data['hasHeadache'] == true
                  ? 'Severity: ${data['headacheSeverity'] ?? 'Not specified'}'
                  : null),
        ]),
        _buildSection('Pregnancy-Specific', [
          _buildSymptomRow('Contractions', data['hasContractions'],
              details: data['hasContractions'] == true
                  ? 'Type: ${data['contractionType'] ?? 'Not specified'}'
                  : null),
          _buildSymptomRow('Baby Stopped Moving', data['babyStoppedMoving']),
        ]),
        if (data['otherConcerns'] != null &&
            data['otherConcerns'].toString().isNotEmpty)
          _buildSection('Additional Concerns', [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
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
          Text(
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
                child: Text(
                  symptom,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isPresent ? FontWeight.w600 : FontWeight.normal,
                    color: isPresent ? Colors.red[700] : Colors.green[700],
                  ),
                ),
              ),
              Text(
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
              child: Text(
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
