import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BirthPlanScreen extends StatefulWidget {
  final String patientId;

  const BirthPlanScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _BirthPlanScreenState createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  String selectedTransport = '';
  String selectedTransportReturn = '';
  String bloodGroup = '';
  String selectedFacilityType = '';
  String chosenHealthFacility = '';
  String healthFacilityPhoneNumber = '';
  String bloodDonorName = '';
  String bloodDonorRelationship = '';
  String bloodDonorPhoneNumber = '';
  String caretakerName = '';
  String caretakerRelationship = '';
  String caretakerPhoneNumber = '';
  String? selectedHealthProvider;
  String healthProviderName = '';
  String healthProviderPhone = '';
  String? accompanyingPerson;
  String accompanyingPersonName = '';
  String accompanyingPersonRelationship = '';
  String accompanyingPersonPhone = '';
  bool? willStayAfterBirth;
  String? chosenReturnMethod;
  String? selectedTimeOption;
  String visitPlan = '';
  String taxiName = '';
  String taxiPhone = '';

  bool moneyForTransport = false;
  bool prescribedMedication = false;
  bool gloves = false;
  bool eyeDrops = false;
  bool clothes = false;
  bool soap = false;
  bool drink = false;
  bool food = false;
  bool washBasin = false;

  // UI State
  bool _isEditMode = false;
  bool _isLoading = true;
  Set<String> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('birth_plan')
          .doc('birth_plan_data')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          selectedFacilityType = data['facility_type'] ?? '';
          chosenHealthFacility = data['facility_name'] ?? '';
          healthFacilityPhoneNumber = data['facility_phone'] ?? '';
          selectedTransport = data['transport_to'] ?? '';
          selectedTransportReturn = data['transport_return'] ?? '';
          bloodDonorName = data['blood_donor_name'] ?? '';
          bloodDonorRelationship = data['blood_donor_relationship'] ?? '';
          bloodDonorPhoneNumber = data['blood_donor_phone'] ?? '';
          bloodGroup = data['blood_group'] ?? '';
          selectedTimeOption = data['trip_duration'] ?? '';
          accompanyingPersonName = data['accompanying_person_name'] ?? '';
          accompanyingPersonRelationship = data['accompanying_person_relationship'] ?? '';
          accompanyingPersonPhone = data['accompanying_person_phone'] ?? '';
          willStayAfterBirth = data['will_stay_after_birth'];
          selectedHealthProvider = data['health_provider_type'];
          healthProviderName = data['health_provider_name'] ?? '';
          healthProviderPhone = data['health_provider_phone'] ?? '';
          chosenReturnMethod = data['return_home_person'];
          taxiName = data['taxi_name'] ?? '';
          taxiPhone = data['taxi_phone'] ?? '';
          visitPlan = data['visit_plan'] ?? '';
          caretakerName = data['caretaker_name'] ?? '';
          caretakerRelationship = data['caretaker_relationship'] ?? '';
          caretakerPhoneNumber = data['caretaker_phone'] ?? '';
          moneyForTransport = data['has_transport_money'] ?? false;
          prescribedMedication = data['has_medication'] ?? false;
          gloves = data['has_gloves'] ?? false;
          eyeDrops = data['has_eye_drops'] ?? false;
          clothes = data['has_clothes'] ?? false;
          soap = data['has_soap'] ?? false;
          drink = data['has_drink'] ?? false;
          food = data['has_food'] ?? false;
          washBasin = data['has_wash_basin'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _getCompletionPercentage() {
    int totalFields = 15;
    int filledFields = 0;

    if (selectedFacilityType.isNotEmpty) filledFields++;
    if (chosenHealthFacility.isNotEmpty) filledFields++;
    if (selectedTransport.isNotEmpty) filledFields++;
    if (bloodDonorName.isNotEmpty) filledFields++;
    if (bloodGroup.isNotEmpty) filledFields++;
    if (selectedTimeOption != null) filledFields++;
    if (accompanyingPersonName.isNotEmpty) filledFields++;
    if (willStayAfterBirth != null) filledFields++;
    if (selectedHealthProvider != null) filledFields++;
    if (chosenReturnMethod != null) filledFields++;
    if (selectedTransportReturn.isNotEmpty) filledFields++;
    if (visitPlan.isNotEmpty) filledFields++;
    if (caretakerName.isNotEmpty) filledFields++;
    if (moneyForTransport || prescribedMedication || gloves || eyeDrops || 
        clothes || soap || drink || food || washBasin) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }

  List<String> _getMissingFields() {
    List<String> missing = [];

    if (selectedFacilityType.isEmpty) missing.add(autoI8lnGen.translate("WHERE_WILL_YOU_GIVE_BIRTH"));
    if (selectedTransport.isEmpty) missing.add(autoI8lnGen.translate("TRANSPORT_OPTIONS"));
    if (bloodDonorName.isEmpty) missing.add(autoI8lnGen.translate("GIVE_BLOOD"));
    if (selectedTimeOption == null) missing.add(autoI8lnGen.translate("HOW_LONG_TRIP"));
    if (accompanyingPersonName.isEmpty) missing.add(autoI8lnGen.translate("WHO_WILL_COME_W"));
    if (selectedHealthProvider == null) missing.add(autoI8lnGen.translate("W_H_P"));
    if (chosenReturnMethod == null) missing.add(autoI8lnGen.translate("W_W_H"));
    if (selectedTransportReturn.isEmpty) missing.add(autoI8lnGen.translate("R_HOME"));
    if (caretakerName.isEmpty) missing.add(autoI8lnGen.translate("LOOK_CHILDREN"));

    return missing;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('PLEASE_FILL_REQUIRED')),
      );
      return;
    }

    // Find connected health provider
    String? providerId;
    try {
      final connectionQuery = await _firestore
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: widget.patientId)
          .limit(1)
          .get();

      if (connectionQuery.docs.isEmpty) {
        throw Exception('This patient is not connected to a health provider.');
      }

      providerId = connectionQuery.docs.first['recipientId'];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'facility_type': selectedFacilityType,
      'facility_name': chosenHealthFacility,
      'facility_phone': healthFacilityPhoneNumber,
      'transport_to': selectedTransport,
      'transport_return': selectedTransportReturn,
      'blood_donor_name': bloodDonorName,
      'blood_donor_relationship': bloodDonorRelationship,
      'blood_donor_phone': bloodDonorPhoneNumber,
      'blood_group': bloodGroup,
      'trip_duration': selectedTimeOption,
      'accompanying_person_name': accompanyingPersonName,
      'accompanying_person_relationship': accompanyingPersonRelationship,
      'accompanying_person_phone': accompanyingPersonPhone,
      'will_stay_after_birth': willStayAfterBirth,
      'health_provider_type': selectedHealthProvider,
      'health_provider_name': healthProviderName,
      'health_provider_phone': healthProviderPhone,
      'return_home_person': chosenReturnMethod,
      'taxi_name': taxiName,
      'taxi_phone': taxiPhone,
      'visit_plan': visitPlan,
      'caretaker_name': caretakerName,
      'caretaker_relationship': caretakerRelationship,
      'caretaker_phone': caretakerPhoneNumber,
      'has_transport_money': moneyForTransport,
      'has_medication': prescribedMedication,
      'has_gloves': gloves,
      'has_eye_drops': eyeDrops,
      'has_clothes': clothes,
      'has_soap': soap,
      'has_drink': drink,
      'has_food': food,
      'has_wash_basin': washBasin,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'providerId': providerId,
      'patientId': widget.patientId,
    };

    try {
      // Save to patient's collection
      await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('birth_plan')
          .doc('birth_plan_data')
          .set(data, SetOptions(merge: true));

      // Save to provider's collection
      await _firestore
          .collection('health_provider_data')
          .doc(providerId)
          .collection('birth_plans')
          .doc(widget.patientId)
          .set(data, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText('BIRTH_PLAN_SAVED'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => _isEditMode = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOverviewCard() {
    final completionPercentage = _getCompletionPercentage();
    final missingFields = _getMissingFields();

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoText(
                  'BIRTHDAY_PLAN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _isEditMode = !_isEditMode),
                  icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
                  tooltip: _isEditMode ? autoI8lnGen.translate("V_MODE") : autoI8lnGen.translate("E_MODE"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionPercentage >= 80 ? Colors.green :
                      completionPercentage >= 50 ? Colors.orange : Colors.red
                    ),
                  ),
                ),
                SizedBox(width: 12),
                AutoText(
                  '$completionPercentage% COMPLETE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (missingFields.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[600]),
                        SizedBox(width: 8),
                        AutoText(
                          'STN (${missingFields.length} ITEMS):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: missingFields.map((field) => Chip(
                        label: Text(field, style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.orange[100],
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
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

  Widget _buildExpandableSection({
    required String title,
    required String sectionKey,
    required List<Widget> children,
    required int filledCount,
    required int totalCount,
  }) {
    final isExpanded = _expandedSections.contains(sectionKey);
    final isEmpty = filledCount == 0;
    final isComplete = filledCount == totalCount;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: AutoText(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isComplete ? Colors.green[100] :
                           isEmpty ? Colors.red[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AutoText(
                    '$filledCount/$totalCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isComplete ? Colors.green[700] :
                             isEmpty ? Colors.red[700] : Colors.orange[700],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isComplete ? Icons.check_circle :
                  isEmpty ? Icons.error : Icons.warning,
                  color: isComplete ? Colors.green[700] :
                         isEmpty ? Colors.red[700] : Colors.orange[700],
                ),
              ],
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections.remove(sectionKey);
                } else {
                  _expandedSections.add(sectionKey);
                }
              });
            },
          ),
          if (isExpanded) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildSelectableOption(String label, IconData icon, Color color,
      Function() onTap, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: _isEditMode ? onTap : null,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: 2,
            ),
            color: isSelected ? color : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 28),
              SizedBox(height: 4),
              AutoText(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripTimeOption(String label) {
    bool isSelected = selectedTimeOption == label;
    return Expanded(
      child: GestureDetector(
        onTap: _isEditMode ? () {
          setState(() {
            selectedTimeOption = label;
          });
        } : null,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          child: Center(
            child: AutoText(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    Widget? trailing,
  }) {
    final isEmpty = value.isEmpty || value == autoI8lnGen.translate("NOT_SPECIFIED");

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEmpty ? Colors.red[200]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isEmpty ? Colors.red[50] : Colors.grey[50],
      ),
      child: ListTile(
        dense: true,
        title: AutoText(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: AutoText(
          isEmpty ? 'T_A_P_ADD' : value,
          style: TextStyle(
            fontSize: 13,
            color: isEmpty ? Colors.red[600] : Colors.black87,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        trailing: trailing ?? (isEmpty ? Icon(Icons.add, color: Colors.red[600]) : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: AutoText('BIRTHDAY_PLAN')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoText('BIRTHDAY_PLAN'),
        backgroundColor: Colors.purple[700],
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
            icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
            tooltip: _isEditMode ? autoI8lnGen.translate("V_MODE") : autoI8lnGen.translate("E_MODE"),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildOverviewCard(),

              // 1. Birth Facility Section
              _buildExpandableSection(
                title: 'WHERE_WILL_YOU_GIVE_BIRTH',
                sectionKey: 'facility',
                filledCount: [
                  selectedFacilityType,
                  chosenHealthFacility,
                  healthFacilityPhoneNumber,
                ].where((x) => x.isNotEmpty).length,
                totalCount: 3,
                children: _isEditMode ? [
                  Row(
                    children: [
                      buildSelectableOption('HOSPITAL', Icons.local_hospital, Colors.green, () {
                        setState(() => selectedFacilityType = autoI8lnGen.translate("HOSPITAL"));
                      }, selectedFacilityType == autoI8lnGen.translate("HOSPITAL")),
                      buildSelectableOption('HEALTH_CENTER', Icons.health_and_safety, Colors.red, () {
                        setState(() => selectedFacilityType = autoI8lnGen.translate("HEALTH_CENTER"));
                      }, selectedFacilityType == autoI8lnGen.translate("HEALTH_CENTER")),
                      buildSelectableOption('DISPENSARY', Icons.local_pharmacy, Colors.blue, () {
                        setState(() => selectedFacilityType = autoI8lnGen.translate("DISPENSARY"));
                      }, selectedFacilityType == autoI8lnGen.translate("DISPENSARY")),
                    ],
                  ),
                  if (selectedFacilityType.isNotEmpty) ...[
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: chosenHealthFacility,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("NAME_OF_CHOSEN_HEALTH_FACILITY"),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => chosenHealthFacility = value),
                      enabled: _isEditMode,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      initialValue: healthFacilityPhoneNumber,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("TELEPHONE_NUMBER"),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => setState(() => healthFacilityPhoneNumber = value),
                      enabled: _isEditMode,
                    ),
                  ],
                ] : [
                  _buildSummaryItem(
                    label: 'FACILITY_TYPE',
                    value: selectedFacilityType.isEmpty ? autoI8lnGen.translate("NOT_SPECIFIED") : selectedFacilityType,
                  ),
                  if (chosenHealthFacility.isNotEmpty)
                    _buildSummaryItem(label: 'FACILITY_NAME', value: chosenHealthFacility),
                  if (healthFacilityPhoneNumber.isNotEmpty)
                    _buildSummaryItem(label: 'TELEPHONE_NUMBER', value: healthFacilityPhoneNumber),
                ],
              ),

              // 2. Transport Section
              _buildExpandableSection(
                title: 'TRANSPORT_OPTIONS',
                sectionKey: 'transport',
                filledCount: [selectedTransport, selectedTimeOption].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode ? [
                  Row(
                    children: [
                      buildSelectableOption('ON_FOOT', Icons.directions_walk, Colors.green, () {
                        setState(() => selectedTransport = autoI8lnGen.translate("FOOT"));
                      }, selectedTransport == autoI8lnGen.translate("FOOT")),
                      buildSelectableOption('BYBIKE', Icons.directions_bike, Colors.blue, () {
                        setState(() => selectedTransport = autoI8lnGen.translate("BIKE"));
                      }, selectedTransport == autoI8lnGen.translate("BIKE")),
                      buildSelectableOption('MOTOR_BIKE', Icons.motorcycle, Colors.orange, () {
                        setState(() => selectedTransport = autoI8lnGen.translate("MOTOR_BIKE"));
                      }, selectedTransport == autoI8lnGen.translate("MOTOR_BIKE")),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      buildSelectableOption('CAR_1', Icons.directions_car, Colors.purple, () {
                        setState(() => selectedTransport = autoI8lnGen.translate("CAR_2"));
                      }, selectedTransport == autoI8lnGen.translate("CAR_2")),
                      buildSelectableOption('BOAT_1', Icons.directions_boat, Colors.teal, () {
                        setState(() => selectedTransport = autoI8lnGen.translate("BOAT_2"));
                      }, selectedTransport == autoI8lnGen.translate("BOAT_2")),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                  SizedBox(height: 20),
                  AutoText("HOW_LONG_TRIP", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTripTimeOption("LESS_1_H"),
                      SizedBox(width: 10),
                      _buildTripTimeOption("1_2_H"),
                      SizedBox(width: 10),
                      _buildTripTimeOption("O_2_H"),
                    ],
                  ),
                ] : [
                  _buildSummaryItem(
                    label: 'TRANSPORT_TO_FACILITY',
                    value: selectedTransport.isEmpty ? autoI8lnGen.translate("NOT_SPECIFIED") : selectedTransport,
                  ),
                  if (selectedTimeOption != null)
                    _buildSummaryItem(label: 'TRIP_DURATION', value: selectedTimeOption!),
                ],
              ),

              // 3. Blood Donor Section
              _buildExpandableSection(
                title: 'GIVE_BLOOD',
                sectionKey: 'blood',
                filledCount: [bloodDonorName, bloodGroup].where((x) => x.isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode ? [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: bloodDonorName,
                          decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("NAME"),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() => bloodDonorName = value),
                          enabled: _isEditMode,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: bloodDonorRelationship,
                          decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("RELATIONSHIP"),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() => bloodDonorRelationship = value),
                          enabled: _isEditMode,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: bloodDonorPhoneNumber,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("T_N"),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => setState(() => bloodDonorPhoneNumber = value),
                    enabled: _isEditMode,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("WHAT_BLOOD_GROUP"),
                      border: OutlineInputBorder(),
                    ),
                    value: bloodGroup.isEmpty ? null : bloodGroup,
                    items: ['O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: _isEditMode ? (value) => setState(() => bloodGroup = value ?? '') : null,
                  ),
                ] : [
                  _buildSummaryItem(
                    label: 'BLOOD_DONOR',
                    value: bloodDonorName.isEmpty ? autoI8lnGen.translate("NOT_SPECIFIED") : 
                           '$bloodDonorName${bloodDonorRelationship.isNotEmpty ? " ($bloodDonorRelationship)" : ""}',
                  ),
                  if (bloodDonorPhoneNumber.isNotEmpty)
                    _buildSummaryItem(label: 'PHONE', value: bloodDonorPhoneNumber),
                  if (bloodGroup.isNotEmpty)
                    _buildSummaryItem(label: 'BLOOD_GROUP', value: bloodGroup),
                ],
              ),

              // 4. Accompanying Person Section
              _buildExpandableSection(
                title: 'WHO_WILL_COME_W',
                sectionKey: 'accompanying',
                filledCount: [accompanyingPersonName, willStayAfterBirth?.toString()].where((x) => x != null && x.isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode ? [
                  TextFormField(
                    initialValue: accompanyingPersonRelationship,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("RELATIONSHIP"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => accompanyingPersonRelationship = value),
                    enabled: _isEditMode,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: accompanyingPersonName,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("NAME"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => accompanyingPersonName = value),
                    enabled: _isEditMode,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: accompanyingPersonPhone,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("T_N"),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => setState(() => accompanyingPersonPhone = value),
                    enabled: _isEditMode,
                  ),
                  SizedBox(height: 16),
                  AutoText("STAY_AFTER_BIRTH", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: AutoText("YES_2"),
                          value: true,
                          groupValue: willStayAfterBirth,
                          onChanged: _isEditMode ? (value) => setState(() => willStayAfterBirth = value) : null,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: AutoText("NO_2"),
                          value: false,
                          groupValue: willStayAfterBirth,
                          onChanged: _isEditMode ? (value) => setState(() => willStayAfterBirth = value) : null,
                        ),
                      ),
                    ],
                  ),
                ] : [
                  _buildSummaryItem(
                    label: 'ACCOMPANYING_PERSON',
                    value: accompanyingPersonName.isEmpty ? autoI8lnGen.translate("NOT_SPECIFIED") :
                           '$accompanyingPersonName${accompanyingPersonRelationship.isNotEmpty ? " ($accompanyingPersonRelationship)" : ""}',
                  ),
                  if (accompanyingPersonPhone.isNotEmpty)
                    _buildSummaryItem(label: 'PHONE', value: accompanyingPersonPhone),
                  if (willStayAfterBirth != null)
                    _buildSummaryItem(
                      label: 'WILL_STAY_AFTER_BIRTH',
                      value: willStayAfterBirth! ? autoI8lnGen.translate("YES_2") : autoI8lnGen.translate("NO_2"),
                    ),
                ],
              ),

              // 5. Health Provider Section
              _buildExpandableSection(
                title: 'W_H_P',
                sectionKey: 'provider',
                filledCount: [selectedHealthProvider, healthProviderName].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode ? [
                  Row(
                    children: [
                      Expanded(
                        child: _buildHealthProviderOption("NURSE"),
                      ),
                      Expanded(
                        child: _buildHealthProviderOption("MIDWIFE"),
                      ),
                      Expanded(
                        child: _buildHealthProviderOption("DOCTOR"),
                      ),
                    ],
                  ),
                  if (selectedHealthProvider != null) ...[
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: healthProviderName,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("NAME"),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => healthProviderName = value),
                      enabled: _isEditMode,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      initialValue: healthProviderPhone,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("T_N"),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => setState(() => healthProviderPhone = value),
                      enabled: _isEditMode,
                    ),
                  ],
                ] : [
                  _buildSummaryItem(
                    label: 'HEALTH_PROVIDER_TYPE',
                    value: selectedHealthProvider ?? autoI8lnGen.translate("NOT_SPECIFIED"),
                  ),
                  if (healthProviderName.isNotEmpty)
                    _buildSummaryItem(label: 'PROVIDER_NAME', value: healthProviderName),
                  if (healthProviderPhone.isNotEmpty)
                    _buildSummaryItem(label: 'PHONE', value: healthProviderPhone),
                ],
              ),

              // 6. Return Home Section
              _buildExpandableSection(
                title: 'W_W_H',
                sectionKey: 'return',
                filledCount: [chosenReturnMethod, selectedTransportReturn].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode ? [
                  Row(
                    children: [
                      Expanded(child: _buildReturnHomeOption("HUSBAND")),
                      Expanded(child: _buildReturnHomeOption("RELATIVE")),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildReturnHomeOption("FRIEND")),
                      Expanded(child: _buildReturnHomeOption("MYSEF")),
                    ],
                  ),
                  if (chosenReturnMethod == autoI8lnGen.translate("MYSEF")) ...[
                    SizedBox(height: 16),
                    AutoText("NAME_CONTACT_TAXI", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: taxiName,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("NAME"),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => taxiName = value),
                      enabled: _isEditMode,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      initialValue: taxiPhone,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("T_N"),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => setState(() => taxiPhone = value),
                      enabled: _isEditMode,
                    ),
                  ],
                  SizedBox(height: 20),
                  AutoText("R_HOME", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      buildSelectableOption('ON_FOOT', Icons.directions_walk, Colors.green, () {
                        setState(() => selectedTransportReturn = autoI8lnGen.translate("FOOT"));
                      }, selectedTransportReturn == autoI8lnGen.translate("FOOT")),
                      buildSelectableOption('BYBIKE', Icons.directions_bike, Colors.blue, () {
                        setState(() => selectedTransportReturn = autoI8lnGen.translate("BIKE"));
                      }, selectedTransportReturn == autoI8lnGen.translate("BIKE")),
                      buildSelectableOption('MOTOR_BIKE', Icons.motorcycle, Colors.orange, () {
                        setState(() => selectedTransportReturn = autoI8lnGen.translate("MOTOR_BIKE"));
                      }, selectedTransportReturn == autoI8lnGen.translate("MOTOR_BIKE")),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      buildSelectableOption('CAR_1', Icons.directions_car, Colors.purple, () {
                        setState(() => selectedTransportReturn = autoI8lnGen.translate("CAR_2"));
                      }, selectedTransportReturn == autoI8lnGen.translate("CAR_2")),
                      buildSelectableOption('BOAT_1', Icons.directions_boat, Colors.teal, () {
                        setState(() => selectedTransportReturn = autoI8lnGen.translate("BOAT_2"));
                      }, selectedTransportReturn == autoI8lnGen.translate("BOAT_2")),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ] : [
                  _buildSummaryItem(
                    label: 'WHO_TAKES_HOME',
                    value: chosenReturnMethod ?? autoI8lnGen.translate("NOT_SPECIFIED"),
                  ),
                  if (taxiName.isNotEmpty)
                    _buildSummaryItem(label: 'TAXI_CONTACT', value: '$taxiName - $taxiPhone'),
                  if (selectedTransportReturn.isNotEmpty)
                    _buildSummaryItem(label: 'RETURN_TRANSPORT', value: selectedTransportReturn),
                ],
              ),

              // 7. Visit Plan Section
              _buildExpandableSection(
                title: 'PLANNING_VISIT_HEALTH_F',
                sectionKey: 'visit',
                filledCount: visitPlan.isNotEmpty ? 1 : 0,
                totalCount: 1,
                children: _isEditMode ? [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      autoI8lnGen.translate("T_WEEK"),
                      autoI8lnGen.translate("T_MONTH"),
                      autoI8lnGen.translate("N_MONTH"),
                      autoI8lnGen.translate("DONT_KNOW"),
                    ].map((visitOption) {
                      return ChoiceChip(
                        label: AutoText(visitOption, style: TextStyle(fontSize: 14)),
                        selected: visitPlan == visitOption,
                        onSelected: _isEditMode ? (selected) {
                          setState(() => visitPlan = visitOption);
                        } : null,
                      );
                    }).toList(),
                  ),
                ] : [
                  _buildSummaryItem(
                    label: 'VISIT_PLAN',
                    value: visitPlan.isEmpty ? autoI8lnGen.translate("NOT_SPECIFIED") : visitPlan,
                  ),
                ],
              ),

              // 8. Caretaker Section
              _buildExpandableSection(
                title: 'LOOK_CHILDREN',
                sectionKey: 'caretaker',
                filledCount: caretakerName.isNotEmpty ? 1 : 0,
                totalCount: 1,
                children: _isEditMode ? [
                  TextFormField(
                    initialValue: caretakerRelationship,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("RELATIONSHIP"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => caretakerRelationship = value),
                    enabled: _isEditMode,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: caretakerName,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("NAME"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => caretakerName = value),
                    enabled: _isEditMode,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: caretakerPhoneNumber,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("T_N"),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => setState(() => caretakerPhoneNumber = value),
                    enabled: _isEditMode,
                  ),
                ] : [
                  _buildSummaryItem(
                    label: 'CARETAKER',
                    value: caretakerName.isEmpty ? autoI8lnGen.translate("NOT_SPECIFIED") :
                           '$caretakerName${caretakerRelationship.isNotEmpty ? " ($caretakerRelationship)" : ""}',
                  ),
                  if (caretakerPhoneNumber.isNotEmpty)
                    _buildSummaryItem(label: 'PHONE', value: caretakerPhoneNumber),
                ],
              ),

              // 9. Items to Bring Section
              _buildExpandableSection(
                title: 'BRING_HEALTH_FACILITY',
                sectionKey: 'items',
                filledCount: [
                  moneyForTransport, prescribedMedication, gloves, eyeDrops,
                  clothes, soap, drink, food, washBasin
                ].where((x) => x == true).length,
                totalCount: 9,
                children: _isEditMode ? [
                  CheckboxListTile(
                    title: AutoText('MONEY_TFARE'),
                    value: moneyForTransport,
                    onChanged: _isEditMode ? (value) => setState(() => moneyForTransport = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('P_MEDICATION'),
                    value: prescribedMedication,
                    onChanged: _isEditMode ? (value) => setState(() => prescribedMedication = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('GLOVES'),
                    value: gloves,
                    onChanged: _isEditMode ? (value) => setState(() => gloves = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('EYE_DROPS'),
                    value: eyeDrops,
                    onChanged: _isEditMode ? (value) => setState(() => eyeDrops = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('CLOTHES_UR'),
                    value: clothes,
                    onChanged: _isEditMode ? (value) => setState(() => clothes = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('SOAP'),
                    value: soap,
                    onChanged: _isEditMode ? (value) => setState(() => soap = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('DRINK'),
                    value: drink,
                    onChanged: _isEditMode ? (value) => setState(() => drink = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('FOOD'),
                    value: food,
                    onChanged: _isEditMode ? (value) => setState(() => food = value!) : null,
                  ),
                  CheckboxListTile(
                    title: AutoText('WASH_BASIN'),
                    value: washBasin,
                    onChanged: _isEditMode ? (value) => setState(() => washBasin = value!) : null,
                  ),
                ] : [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (moneyForTransport) _buildCheckItem('MONEY_TFARE'),
                        if (prescribedMedication) _buildCheckItem('P_MEDICATION'),
                        if (gloves) _buildCheckItem('GLOVES'),
                        if (eyeDrops) _buildCheckItem('EYE_DROPS'),
                        if (clothes) _buildCheckItem('CLOTHES_UR'),
                        if (soap) _buildCheckItem('SOAP'),
                        if (drink) _buildCheckItem('DRINK'),
                        if (food) _buildCheckItem('FOOD'),
                        if (washBasin) _buildCheckItem('WASH_BASIN'),
                        if (![moneyForTransport, prescribedMedication, gloves, eyeDrops,
                            clothes, soap, drink, food, washBasin].any((x) => x))
                          AutoText('NO_ITEMS_SELECTED', style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),

              // Information Footer
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.purple[700]),
                        SizedBox(width: 8),
                        AutoText(
                          'ABOUT_BIRTH_PLAN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                
                  ],
                ),
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _saveForm,
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              icon: Icon(Icons.save),
              label: AutoText('SAVE'),
            )
          : FloatingActionButton(
              onPressed: () => setState(() => _isEditMode = true),
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              child: Icon(Icons.edit),
              tooltip: autoI8lnGen.translate("E_MODE"),
            ),
    );
  }

  Widget _buildHealthProviderOption(String label) {
    bool isSelected = selectedHealthProvider == label;
    return GestureDetector(
      onTap: _isEditMode ? () {
        setState(() => selectedHealthProvider = label);
      } : null,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            SizedBox(height: 4),
            AutoText(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnHomeOption(String label) {
    bool isSelected = chosenReturnMethod == label;
    return GestureDetector(
      onTap: _isEditMode ? () {
        setState(() => chosenReturnMethod = label);
      } : null,
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.purple : Colors.grey,
            ),
            SizedBox(height: 4),
            AutoText(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          AutoText(label),
        ],
      ),
    );
  }
}


// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';

// class BirthPlanScreen extends StatefulWidget {
//   @override
//   _BirthPlanScreenState createState() => _BirthPlanScreenState();
// }

// class _BirthPlanScreenState extends State<BirthPlanScreen> {
//   // State variables
//   String selectedTransport = '';
//   String selectedTransportReturn = '';

//   String bloodType = '';
//   String bloodGroup = '';
//   String visitPlan = '';
//   String selectedFacilityType = '';
//   String chosenHealthFacility = '';
//   String healthFacilityPhoneNumber = '';
//   String bloodDonorName = '';
//   String bloodDonorRelationship = '';
//   String bloodDonorPhoneNumber = '';
//   String caretakerName = '';
//   String caretakerRelationship = '';
//   String caretakerPhoneNumber = '';
//   String? selectedHealthProvider;
//   String? accompanyingPerson;
//   bool? willStayAfterBirth;
//   String? chosenReturnMethod;
//   String? _selectedTimeOption;

//   bool moneyForTransport = false;
//   bool prescribedMedication = false;
//   bool gloves = false;
//   bool eyeDrops = false;
//   bool clothes = false;
//   bool soap = false;
//   bool drink = false;
//   bool food = false;
//   bool washBasin = false;

//   Widget buildSelectableOption(String label, IconData icon, Color color,
//       Function() onTap, bool isSelected) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? Colors.black : color,
//             width: 2,
//           ),
//           color: isSelected ? Colors.black : Colors.transparent,
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : color),
//             AutoText(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _saveForm() {
//     // Collect all form data and process it
//     print('Transport: $selectedTransport');
//     print('Health Facility: $chosenHealthFacility');
//     print('Blood Donor: $bloodDonorName');
//     // ... collect other inputs here
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: AutoText('BIRTHDAY_PLAN')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 10),
//             AutoText(
//               'WHERE_WILL_YOU_GIVE_BIRTH',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 buildSelectableOption(
//                     'HOSPITAL', Icons.local_hospital, Colors.green, () {
//                   setState(() {
//                     selectedFacilityType = autoI8lnGen.translate("HOSPITAL");
//                   });
//                 }, selectedFacilityType == autoI8lnGen.translate("HOSPITAL")),
//                 buildSelectableOption(
//                     'HEALTH_CENTER', Icons.health_and_safety, Colors.red, () {
//                   setState(() {
//                     selectedFacilityType =
//                         autoI8lnGen.translate("HEALTH_CENTER");
//                   });
//                 },
//                     selectedFacilityType ==
//                         autoI8lnGen.translate("HEALTH_CENTER")),
//                 buildSelectableOption(
//                     'DISPENSARY', Icons.local_pharmacy, Colors.blue, () {
//                   setState(() {
//                     selectedFacilityType = autoI8lnGen.translate("DISPENSARY");
//                   });
//                 }, selectedFacilityType == autoI8lnGen.translate("DISPENSARY")),
//               ],
//             ),

//             SizedBox(height: 10),
//             Visibility(
//               visible: selectedFacilityType
//                   .isNotEmpty, // Show when a type is selected
//               child: Column(
//                 children: [
//                   SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: autoI8lnGen
//                           .translate("NAME_OF_CHOSEN_HEALTH_FACILITY"),
//                       labelStyle: TextStyle(fontSize: 14),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         chosenHealthFacility = value;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: autoI8lnGen.translate("TELEPHONE_NUMBER"),
//                       labelStyle: TextStyle(fontSize: 14),
//                     ),
//                     keyboardType: TextInputType.phone,
//                     onChanged: (value) {
//                       setState(() {
//                         healthFacilityPhoneNumber = value;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 20),
//             // Transport Options
//             AutoText(
//               'TRANSPORT_OPTIONS',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 buildSelectableOption(
//                     'ON_FOOT', Icons.directions_walk, Colors.green, () {
//                   setState(() {
//                     selectedTransport = autoI8lnGen.translate("FOOT");
//                   });
//                 }, selectedTransport == autoI8lnGen.translate("FOOT")),
//                 buildSelectableOption(
//                     'BYBIKE', Icons.directions_bike, Colors.blue, () {
//                   setState(() {
//                     selectedTransport = autoI8lnGen.translate("BIKE");
//                   });
//                 }, selectedTransport == autoI8lnGen.translate("BIKE")),
//                 buildSelectableOption(
//                     'MOTOR_BIKE', Icons.motorcycle, Colors.orange, () {
//                   setState(() {
//                     selectedTransport = autoI8lnGen.translate("MOTOR_BIKE");
//                   });
//                 }, selectedTransport == autoI8lnGen.translate("MOTOR_BIKE")),
//                 buildSelectableOption(
//                     'CAR_1', Icons.directions_car, Colors.purple, () {
//                   setState(() {
//                     selectedTransport = autoI8lnGen.translate("CAR_2");
//                   });
//                 }, selectedTransport == autoI8lnGen.translate("CAR_2")),
//                 buildSelectableOption(
//                     'BOAT_1', Icons.directions_boat, Colors.teal, () {
//                   setState(() {
//                     selectedTransport = autoI8lnGen.translate("BOAT_2");
//                   });
//                 }, selectedTransport == autoI8lnGen.translate("BOAT_2")),
//               ],
//             ),
//             SizedBox(height: 20),

//             // Blood donation section
//             AutoText(
//               'GIVE_BLOOD',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       labelText: autoI8lnGen.translate("NAME"),
//                       labelStyle: TextStyle(fontSize: 14),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         bloodDonorName = value;
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       labelText: autoI8lnGen.translate("RELATIONSHIP"),
//                       labelStyle: TextStyle(fontSize: 14),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         bloodDonorRelationship = value;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: autoI8lnGen.translate("T_N"),
//                 labelStyle: TextStyle(fontSize: 14),
//               ),
//               keyboardType: TextInputType.phone,
//               onChanged: (value) {
//                 setState(() {
//                   bloodDonorPhoneNumber = value;
//                 });
//               },
//             ),
//             SizedBox(height: 10),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   AutoText('WHAT_BLOOD_GROUP', style: TextStyle(fontSize: 14)),
//                   DropdownButton<String>(
//                     value: bloodGroup.isEmpty ? null : bloodGroup,
//                     items: <String>['O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-']
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         bloodGroup = value ?? '';
//                       });
//                     },
//                     hint: AutoText(
//                       'SELECT_BLOOD_GROUP',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 20),
//             // 3. How long does the trip take?
//             AutoText("HOW_LONG_TRIP", style: TextStyle(fontSize: 14)),
//             SizedBox(height: 10),
//             Row(
//               children: [
//                 _buildTripTimeOption("LESS_1_H"),
//                 SizedBox(width: 10),
//                 _buildTripTimeOption("1_2_H"),
//                 SizedBox(width: 10),
//                 _buildTripTimeOption("O_2_H"),
//               ],
//             ),

//             SizedBox(height: 20),
//             // 4. Who will come with you?
//             AutoText("WHO_WILL_COME_W", style: TextStyle(fontSize: 14)),
//             TextFormField(
//               decoration: InputDecoration(
//                   labelText: autoI8lnGen.translate("RELATIONSHIP")),
//             ),
//             TextFormField(
//               decoration:
//                   InputDecoration(labelText: autoI8lnGen.translate("NAME")),
//             ),
//             TextFormField(
//               decoration:
//                   InputDecoration(labelText: autoI8lnGen.translate("T_N")),
//             ),
//             SizedBox(height: 10),
//             AutoText("STAY_AFTER_BIRTH", style: TextStyle(fontSize: 14)),
//             Row(
//               children: [
//                 Radio<bool>(
//                   value: true,
//                   groupValue: willStayAfterBirth,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       willStayAfterBirth =
//                           value; // Update the state with selected value
//                     });
//                   },
//                 ),
//                 AutoText("YES_2"),
//                 Radio<bool>(
//                   value: false,
//                   groupValue: willStayAfterBirth,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       willStayAfterBirth =
//                           value; // Update the state with selected value
//                     });
//                   },
//                 ),
//                 AutoText("NO_2"),
//                 Radio<bool?>(
//                   value: null,
//                   groupValue: willStayAfterBirth,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       willStayAfterBirth =
//                           value; // Update the state with selected value
//                     });
//                   },
//                 ),
//                 AutoText("DONT_KNOW"),
//               ],
//             ),

//             SizedBox(height: 10),
//             // 6. Which health provider will assist at the birth?
//             AutoText("W_H_P", style: TextStyle(fontSize: 14)),
//             Row(
//               children: [
//                 _buildHealthProviderOption("NURSE"),
//                 _buildHealthProviderOption("MIDWIFE"),
//                 _buildHealthProviderOption("DOCTOR"),
//               ],
//             ),
//             if (selectedHealthProvider != null) ...[
//               TextFormField(
//                 decoration:
//                     InputDecoration(labelText: autoI8lnGen.translate("NAME")),
//               ),
//               TextFormField(
//                 decoration:
//                     InputDecoration(labelText: autoI8lnGen.translate("T_N")),
//               ),
//             ],

//             SizedBox(height: 20),
//             // 7. Who will take you home?
//             AutoText("W_W_H", style: TextStyle(fontSize: 14)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildReturnHomeOption("HUSBAND"),
//                 _buildReturnHomeOption("RELATIVE"),
//                 _buildReturnHomeOption("FRIEND"),
//                 _buildReturnHomeOption("MYSEF"),
//               ],
//             ),
//             if (chosenReturnMethod == autoI8lnGen.translate("MYSEF")) ...[
//               AutoText("NAME_CONTACT_TAXI"),
//               TextFormField(
//                 decoration:
//                     InputDecoration(labelText: autoI8lnGen.translate("NAME")),
//               ),
//               TextFormField(
//                 decoration:
//                     InputDecoration(labelText: autoI8lnGen.translate("T_N")),
//               ),
//             ],

//             SizedBox(height: 20),
//             // 8. How do you return home after the birth?
//             AutoText("R_HOME",
//                 style: TextStyle(fontSize: 14)),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 buildSelectableOption(
//                     'ON_FOOT', Icons.directions_walk, Colors.green, () {
//                   setState(() {
//                     selectedTransportReturn = autoI8lnGen.translate("FOOT");
//                   });
//                 }, selectedTransportReturn == autoI8lnGen.translate("FOOT")),
//                 buildSelectableOption(
//                     'BYBIKE', Icons.directions_bike, Colors.blue, () {
//                   setState(() {
//                     selectedTransportReturn = autoI8lnGen.translate("BIKE");
//                   });
//                 }, selectedTransportReturn == autoI8lnGen.translate("BIKE")),
//                 buildSelectableOption(
//                     'MOTOR_BIKE', Icons.motorcycle, Colors.orange, () {
//                   setState(() {
//                     selectedTransportReturn =
//                         autoI8lnGen.translate("MOTOR_BIKE");
//                   });
//                 },
//                     selectedTransportReturn ==
//                         autoI8lnGen.translate("MOTOR_BIKE")),
//                 buildSelectableOption(
//                     'CAR_1', Icons.directions_car, Colors.purple, () {
//                   setState(() {
//                     selectedTransportReturn = autoI8lnGen.translate("CAR_2");
//                   });
//                 }, selectedTransportReturn == autoI8lnGen.translate("CAR_2")),
//                 buildSelectableOption(
//                     'BOAT_1', Icons.directions_boat, Colors.teal, () {
//                   setState(() {
//                     selectedTransportReturn = autoI8lnGen.translate("BOAT_2");
//                   });
//                 }, selectedTransportReturn == autoI8lnGen.translate("BOAT_2")),
//               ],
//             ),
//             SizedBox(height: 10),
//             if (chosenReturnMethod != null) AutoText("SAVE_TFARE"),

//             SizedBox(height: 20),
//             // 10. Visit the health facility beforehand
//             AutoText(
//               'PLANNING_VISIT_HEALTH_F',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   autoI8lnGen.translate("T_WEEK"),
//                   autoI8lnGen.translate("T_MONTH"),
//                   autoI8lnGen.translate("N_MONTH"),
//                   autoI8lnGen.translate("DONT_KNOW"),
//                 ].map((visitOption) {
//                   return ChoiceChip(
//                     label: AutoText(visitOption, style: TextStyle(fontSize: 14)),
//                     selected: visitPlan == visitOption,
//                     onSelected: (selected) {
//                       setState(() {
//                         visitPlan = visitOption;
//                       });
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//             SizedBox(height: 20),
//             // 11. Who will look after your children?

//             AutoText(
//               'LOOK_CHILDREN',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: autoI8lnGen.translate("RELATIONSHIP"),
//                 labelStyle: TextStyle(fontSize: 14),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   caretakerRelationship = value;
//                 });
//               },
//             ),
//             SizedBox(height: 10),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: autoI8lnGen.translate("NAME"),
//                 labelStyle: TextStyle(fontSize: 14),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   caretakerName = value;
//                 });
//               },
//             ),
//             SizedBox(height: 10),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: autoI8lnGen.translate("T_N"),
//                 labelStyle: TextStyle(fontSize: 14),
//               ),
//               keyboardType: TextInputType.phone,
//               onChanged: (value) {
//                 setState(() {
//                   caretakerPhoneNumber = value;
//                 });
//               },
//             ),
//             SizedBox(height: 20),

//             // Checkbox section
//             AutoText(
//               'BRING_HEALTH_FACILITY',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             CheckboxListTile(
//               title:
//                   AutoText('MONEY_TFARE', style: TextStyle(fontSize: 14)),
//               value: moneyForTransport,
//               onChanged: (value) {
//                 setState(() {
//                   moneyForTransport = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title:
//               AutoText('P_MEDICATION', style: TextStyle(fontSize: 14)),
//               value: prescribedMedication,
//               onChanged: (value) {
//                 setState(() {
//                   prescribedMedication = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: AutoText('GLOVES', style: TextStyle(fontSize: 14)),
//               value: gloves,
//               onChanged: (value) {
//                 setState(() {
//                   gloves = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: AutoText('EYE_DROPS', style: TextStyle(fontSize: 14)),
//               value: eyeDrops,
//               onChanged: (value) {
//                 setState(() {
//                   eyeDrops = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title:
//                   AutoText('CLOTHES_UR', style: TextStyle(fontSize: 14)),
//               value: clothes,
//               onChanged: (value) {
//                 setState(() {
//                   clothes = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: AutoText('SOAP', style: TextStyle(fontSize: 14)),
//               value: soap,
//               onChanged: (value) {
//                 setState(() {
//                   soap = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: AutoText('DRINK', style: TextStyle(fontSize: 14)),
//               value: drink,
//               onChanged: (value) {
//                 setState(() {
//                   drink = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: AutoText('FOOD', style: TextStyle(fontSize: 14)),
//               value: food,
//               onChanged: (value) {
//                 setState(() {
//                   food = value!;
//                 });
//               },
//             ),
//             CheckboxListTile(
//               title: AutoText('WASH_BASIN', style: TextStyle(fontSize: 14)),
//               value: washBasin,
//               onChanged: (value) {
//                 setState(() {
//                   washBasin = value!;
//                 });
//               },
//             ),

//             // Add space at the bottom for the floating action button
//             SizedBox(height: 80),
//           ],
//         ),
//       ),
//       // Add the floating action button here
//       floatingActionButton: SizedBox(
//         width: 200, // Make it wider
//         height: 56, // Make it taller
//         child: FloatingActionButton(
//           onPressed: _saveForm,
//           child: AutoText(
//             'SAVE',
//             style: TextStyle(fontSize: 16), // Larger text
//           ),
//         ),
//       ),
//       // Center the floating action button
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   Widget _buildTransportOption(String label, IconData icon, Color color) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedTransport = label;
//         });
//       },
//       child: Column(
//         children: [
//           Icon(icon, color: selectedTransport == label ? color : Colors.black),
//           AutoText(label,
//               style: TextStyle(
//                   color: selectedTransport == label ? color : Colors.black)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTripTimeOption(String label) {
//     bool isSelected = _selectedTimeOption == label;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedTimeOption = label; // Update selected option
//           });
//         },
//         child: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.blue : Colors.grey[200],
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: isSelected ? Colors.blue : Colors.grey,
//             ),
//           ),
//           child: Center(
//             child: AutoText(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHealthProviderOption(String label) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedHealthProvider = label;
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.all(5),
//         child: Row(
//           children: [
//             Icon(
//               selectedHealthProvider == label
//                   ? Icons.check_box
//                   : Icons.check_box_outline_blank,
//               color: Colors.green,
//             ),
//             SizedBox(width: 5),
//             AutoText(label),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReturnHomeOption(String label) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           chosenReturnMethod = label;
//         });
//       },
//       child: Column(
//         children: [
//           Icon(
//             chosenReturnMethod == label
//                 ? Icons.check_box
//                 : Icons.check_box_outline_blank,
//             color: Colors.purple,
//           ),
//           AutoText(label),
//         ],
//       ),
//     );
//   }
// }
