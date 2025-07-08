import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientVitalDisplayScreen extends StatefulWidget {
  final String providerId;
  final String patientId;

  const PatientVitalDisplayScreen({
    Key? key,
    required this.providerId,
    required this.patientId,
  }) : super(key: key);

  @override
  State<PatientVitalDisplayScreen> createState() =>
      _PatientVitalDisplayScreenState();
}

class _PatientVitalDisplayScreenState extends State<PatientVitalDisplayScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? patientData;

  @override
  void initState() {
    super.initState();
    _loadPatientInfo();
  }

  Future<void> _loadPatientInfo() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.patientId).get();
      if (userDoc.exists) {
        setState(() {
          patientData = userDoc.data();
        });
      }
    } catch (e) {
      print('Error loading patient info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patientData?['name'] ?? 'Patient Vital Information'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('health_provider_data')
            .doc(widget.providerId)
            .collection('vital_info_from_patients')
            .doc(widget.patientId)
            .collection('records')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading vital information: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No vital information records found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Patient has not submitted any vital information yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildVitalCard(data, index == 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildVitalCard(Map<String, dynamic> data, bool isLatest) {
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr = timestamp != null
        ? DateFormat('EEEE, MMMM dd, yyyy • HH:mm').format(timestamp.toDate())
        : 'No date available';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isLatest ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              isLatest ? Border.all(color: Colors.blue[300]!, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.medical_information,
                    color: isLatest ? Colors.blue[700] : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isLatest ? Colors.blue[700] : Colors.grey[800],
                          ),
                        ),
                        if (isLatest)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Latest Record',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Week ${data['currentWeek'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Vital Signs
              _buildVitalSection('Physical Measurements', [
                if (data['weight'] != null)
                  _buildVitalRow('Weight', '${data['weight']} kg',
                      Icons.monitor_weight, Colors.blue),
                if (data['fundalHeight'] != null)
                  _buildVitalRow('Fundal Height', '${data['fundalHeight']} cm',
                      Icons.straighten, Colors.purple),
              ]),

              _buildVitalSection('Cardiovascular', [
                if (data['systolicPressure'] != null &&
                    data['diastolicPressure'] != null)
                  _buildVitalRow(
                      'Blood Pressure',
                      '${data['systolicPressure']}/${data['diastolicPressure']} mmHg',
                      Icons.favorite,
                      Colors.red),
                if (data['pulseRate'] != null)
                  _buildVitalRow('Pulse Rate', '${data['pulseRate']} bpm',
                      Icons.favorite_border, Colors.pink),
                if (data['babyHeartbeat'] != null)
                  _buildVitalRow(
                      'Baby Heartbeat',
                      '${data['babyHeartbeat']} bpm',
                      Icons.child_care,
                      Colors.orange),
              ]),

              _buildVitalSection('Laboratory Results', [
                if (data['haemoglobin'] != null)
                  _buildVitalRow('Hemoglobin', '${data['haemoglobin']} g/dL',
                      Icons.bloodtype, Colors.red),
                if (data['glucose'] != null)
                  _buildVitalRow('Glucose', '${data['glucose']} mg/dL',
                      Icons.water_drop, Colors.amber),
                if (data['albumin'] != null)
                  _buildVitalRow('Albumin', '${data['albumin']} g/dL',
                      Icons.science, Colors.teal),
              ]),

              // Urine Analysis
              if (data['urineAnalysis'] != null &&
                  data['urineAnalysis'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment,
                              color: Colors.amber[800], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Urine Analysis',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[800],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['urineAnalysis'].toString(),
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalSection(String title, List<Widget> vitals) {
    if (vitals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...vitals,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVitalRow(
      String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
