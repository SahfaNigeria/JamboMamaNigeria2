import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailabilitySchedulePage extends StatefulWidget {
  @override
  _AvailabilitySchedulePageState createState() =>
      _AvailabilitySchedulePageState();
}

class _AvailabilitySchedulePageState extends State<AvailabilitySchedulePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _days = [
    autoI8lnGen.translate("MONDAY"),
    autoI8lnGen.translate("TUESDAY"),
    autoI8lnGen.translate("WEDNESDAY"),
    autoI8lnGen.translate("THURSDAY"),
    autoI8lnGen.translate("FRIDAY"),
    autoI8lnGen.translate("SATURDAY"),
    autoI8lnGen.translate("SUNDAY"),
  ];

  Map<String, Map<String, String>> _availability = {};
  int _connectedPatients = 0;
  bool _isLoadingPatients = true;
  bool _isLoadingAvailability = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _fetchConnectedPatients();
    _fetchAvailability();
  }

  Future<void> _fetchConnectedPatients() async {
    try {
      final uid = _auth.currentUser!.uid;

      final query = await _firestore
          .collection("allowed_to_chat")
          .where("recipientId", isEqualTo: uid)
          .get();

      setState(() {
        _connectedPatients = query.docs.length;
        _isLoadingPatients = false;
      });
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText("E_P_A $e")),
      );
    }
  }

  Future<void> _fetchAvailability() async {
    try {
      final uid = _auth.currentUser!.uid;

      final doc =
          await _firestore.collection('medical_professionals').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('availability')) {
          final availabilityData = data['availability'] as Map<String, dynamic>;

          // Convert the fetched data to the expected format
          Map<String, Map<String, String>> fetchedAvailability = {};
          availabilityData.forEach((day, schedule) {
            if (schedule is Map<String, dynamic>) {
              fetchedAvailability[day] = {
                'start': schedule['start']?.toString() ?? '',
                'end': schedule['end']?.toString() ?? '',
              };
            }
          });

          setState(() {
            _availability = fetchedAvailability;
            _isLoadingAvailability = false;
          });
        } else {
          setState(() {
            _isLoadingAvailability = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAvailability = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAvailability = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText("E_L_A $e")),
      );
    }
  }

  Future<void> _pickTime(String day, bool isStart) async {
    // Parse existing time if available
    TimeOfDay? initialTime;

    if (_availability.containsKey(day)) {
      final timeString = _availability[day]![isStart ? "start" : "end"];
      if (timeString != null && timeString.isNotEmpty) {
        try {
          initialTime = _parseTimeString(timeString);
        } catch (e) {
          initialTime = TimeOfDay.now();
        }
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (!_availability.containsKey(day)) {
          _availability[day] = {"start": "", "end": ""};
        }
        _availability[day]![isStart ? "start" : "end"] = picked.format(context);
        _hasChanges = true;
      });
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    // Handle formats like "12:00 PM", "4:19 PM", etc.
    final parts = timeString.trim().split(' ');
    final timePart = parts[0];
    final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

    final timeComponents = timePart.split(':');
    int hour = int.parse(timeComponents[0]);
    final minute = timeComponents.length > 1 ? int.parse(timeComponents[1]) : 0;

    // Convert to 24-hour format for TimeOfDay
    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _clearDaySchedule(String day) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AutoText('CLR $day SCH'),
        content: AutoText('AYSF $day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AutoText('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: AutoText('CLR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _availability.remove(day);
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoText("N_C_S")),
      );
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _firestore
          .collection('medical_professionals')
          .doc(uid)
          .set({"availability": _availability}, SetOptions(merge: true));

      // Hide loading
      Navigator.of(context).pop();

      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoText("A_S_S"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Hide loading
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText("E_S_A $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingAvailability = true;
      _isLoadingPatients = true;
    });

    await Future.wait([
      _fetchAvailability(),
      _fetchConnectedPatients(),
    ]);
  }

  Widget _buildDayCard(String day) {
    final schedule = _availability[day];
    final hasSchedule = schedule != null &&
        schedule['start']!.isNotEmpty &&
        schedule['end']!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasSchedule)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => _clearDaySchedule(day),
                    tooltip: autoI8lnGen.translate("C_SCHE"),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasSchedule) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "${schedule['start']} - ${schedule['end']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey.shade500, size: 20),
                    const SizedBox(width: 8),
                    AutoText(
                      "N_SCHE",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(day, true),
                    icon: const Icon(Icons.access_time),
                    label: AutoText(
                      schedule != null && schedule['start']!.isNotEmpty
                          ? 'START ${schedule['start']}'
                          : 'S_S_T',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(day, false),
                    icon: const Icon(Icons.schedule),
                    label: AutoText(
                      schedule != null && schedule['end']!.isNotEmpty
                          ? 'END ${schedule['end']}'
                          : 'S_E_T_2',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoText("AV_SCHE"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: autoI8lnGen.translate("REFRESH"),
          ),
        ],
      ),
      body: _isLoadingAvailability
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  AutoText('L_A_V_I'),
                ],
              ),
            )
          : Column(
              children: [
                // Connected Patients Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoadingPatients
                      ? const CircularProgressIndicator()
                      : Card(
                          color: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.people,
                                    color: Colors.blue, size: 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoText(
                                        "CONNECTED_PATIENTS $_connectedPatients",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      if (_connectedPatients > 0)
                                        AutoText(
                                          "Y_S_W_V",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),

                // Availability List
                Expanded(
                  child: ListView.builder(
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      return _buildDayCard(_days[index]);
                    },
                  ),
                ),

                // Save Button at Bottom
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveSchedule,
                        icon: const Icon(Icons.save),
                        label: const AutoText('SAVE_CHANGES'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      // floatingActionButton: !_hasChanges
      //     ? null
      //     : FloatingActionButton.extended(
      //         onPressed: _saveSchedule,
      //         label: const AutoText("SAVE"),
      //         icon: const Icon(Icons.save),
      //         backgroundColor: Colors.green,
      //       ),
    );
  }
}
