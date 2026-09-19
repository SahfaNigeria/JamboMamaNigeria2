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

  // IMPORTANT: These are the keys actually stored in Firestore under
  // medical_professionals/{id}/availability. They must stay fixed
  // (never translated), or a schedule saved in one language becomes
  // unreadable/unmatched when the app is used in another language —
  // this must match AllowedToChatScreen's _dayKeys exactly.
  static const _dayKeys = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Localized labels, for display only. Index-aligned with _dayKeys.
  static const _dayTranslationKeys = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  String _dayLabel(String dayKey) {
    final index = _dayKeys.indexOf(dayKey);
    if (index == -1) return dayKey;
    return autoI8lnGen.translate(_dayTranslationKeys[index]);
  }

  /// Short badge text for the leading avatar (e.g. "Mon"). Falls back to
  /// the first 3 characters of the translated label if it's long.
  String _dayAbbrev(String dayKey) {
    final label = _dayLabel(dayKey);
    return label.length <= 3 ? label : label.substring(0, 3);
  }

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

          // Convert the fetched data to the expected format.
          // Also normalizes any legacy documents that may have been saved
          // with translated day names as keys (from before this fix), by
          // mapping them back onto the fixed English day keys where possible.
          //
          // FIX: If a stored key can't be mapped to one of the fixed
          // _dayKeys (e.g. it was saved under a different app locale than
          // the one currently active, so the translation lookup in
          // _normalizeDayKey doesn't match), it used to be kept under its
          // original, foreign key. That entry was invisible in the UI
          // (_buildDayCard only ever renders the fixed _dayKeys) but was
          // still included in _saveSchedule's validation loop — so an
          // incomplete legacy entry (e.g. "Lundi" with only a start time)
          // would permanently block saving with an error like "Incomplete
          // schedule for: Lundi", with no way to edit or clear it from the
          // screen. We now drop any entry that doesn't normalize to a
          // fixed day key instead of keeping it under a foreign key.
          Map<String, Map<String, String>> fetchedAvailability = {};
          availabilityData.forEach((day, schedule) {
            if (schedule is Map<String, dynamic>) {
              final normalizedKey = _normalizeDayKey(day);
              if (_dayKeys.contains(normalizedKey)) {
                fetchedAvailability[normalizedKey] = {
                  'start': schedule['start']?.toString() ?? '',
                  'end': schedule['end']?.toString() ?? '',
                };
              }
              // else: unresolvable legacy key — dropped. The next
              // successful save will overwrite Firestore with only the
              // clean, English-keyed data, removing the ghost entry there
              // too.
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

  /// Maps a stored day string back onto one of the fixed English day keys.
  /// Handles legacy documents that were saved with a translated day name
  /// (e.g. "Lundi") instead of the fixed key ("Monday"). Falls back to
  /// returning the value unchanged if no match is found — callers must
  /// check the result against _dayKeys before trusting it (see
  /// _fetchAvailability).
  String _normalizeDayKey(String storedDay) {
    if (_dayKeys.contains(storedDay)) return storedDay;

    for (var i = 0; i < _dayTranslationKeys.length; i++) {
      if (autoI8lnGen.translate(_dayTranslationKeys[i]) == storedDay) {
        return _dayKeys[i];
      }
    }
    return storedDay;
  }

  Future<void> _pickTime(String dayKey, bool isStart) async {
    // Parse existing time if available
    TimeOfDay? initialTime;

    if (_availability.containsKey(dayKey)) {
      final timeString = _availability[dayKey]![isStart ? "start" : "end"];
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
        if (!_availability.containsKey(dayKey)) {
          _availability[dayKey] = {"start": "", "end": ""};
        }
        _availability[dayKey]![isStart ? "start" : "end"] =
            picked.format(context);
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

  Future<void> _clearDaySchedule(String dayKey) async {
    final dayLabel = _dayLabel(dayKey);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AutoText('CLR $dayLabel SCH'),
        content: AutoText('AYSF $dayLabel?'),
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
        _availability.remove(dayKey);
        _hasChanges = true;
      });
    }
  }

  /// Opens a dialog letting the user apply [sourceDayKey]'s start/end
  /// times to any of the other days via checkboxes.
  Future<void> _copyToOtherDays(String sourceDayKey) async {
    final sourceSchedule = _availability[sourceDayKey];
    if (sourceSchedule == null ||
        sourceSchedule['start']!.isEmpty ||
        sourceSchedule['end']!.isEmpty) {
      return;
    }

    final otherDayKeys = _dayKeys.where((d) => d != sourceDayKey).toList();
    final selected = <String, bool>{for (final d in otherDayKeys) d: false};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: AutoText('COPY_TO_DAYS ${_dayLabel(sourceDayKey)}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        "${sourceSchedule['start']} - ${sourceSchedule['end']}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...otherDayKeys.map((d) {
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(_dayLabel(d)),
                        value: selected[d],
                        onChanged: (val) {
                          setDialogState(() => selected[d] = val ?? false);
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const AutoText('CANCEL'),
                ),
                TextButton(
                  onPressed: selected.containsValue(true)
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  child: const AutoText('APPLY'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final targetDays =
          selected.entries.where((e) => e.value).map((e) => e.key).toList();

      setState(() {
        for (final d in targetDays) {
          _availability[d] = {
            'start': sourceSchedule['start']!,
            'end': sourceSchedule['end']!,
          };
        }
        _hasChanges = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText('SCHEDULE_COPIED ${targetDays.length}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _saveSchedule() async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoText("N_C_S")),
      );
      return;
    }

    // ── Validation ──────────────────────────────────────────────
    List<String> incompleteDays = [];
    List<String> invalidRangeDays = [];

    for (final entry in _availability.entries) {
      final dayKey = entry.key;
      final dayLabel = _dayLabel(dayKey);
      final schedule = entry.value;
      final hasStart = schedule['start']?.isNotEmpty ?? false;
      final hasEnd = schedule['end']?.isNotEmpty ?? false;

      if (hasStart && !hasEnd) {
        incompleteDays.add(dayLabel); // start set, end missing
      } else if (!hasStart && hasEnd) {
        incompleteDays.add(dayLabel); // end set, start missing
      } else if (hasStart && hasEnd) {
        // Validate that end time is after start time
        try {
          final start = _parseTimeString(schedule['start']!);
          final end = _parseTimeString(schedule['end']!);
          final startMinutes = start.hour * 60 + start.minute;
          final endMinutes = end.hour * 60 + end.minute;
          if (endMinutes <= startMinutes) {
            invalidRangeDays.add(dayLabel);
          }
        } catch (_) {
          incompleteDays.add(dayLabel);
        }
      }
    }

    if (incompleteDays.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Incomplete schedule for: ${incompleteDays.join(', ')}. "
            "Please set both start and end times.",
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (invalidRangeDays.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "End time must be after start time for: ${invalidRangeDays.join(', ')}.",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    // ── End Validation ───────────────────────────────────────────

    try {
      final uid = _auth.currentUser!.uid;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final docRef = _firestore.collection('medical_professionals').doc(uid);

      // FIX: previously this did a single
      // set({"availability": _availability}, SetOptions(merge: true)).
      // merge:true only adds/overwrites fields present in the payload —
      // it never deletes fields that are simply absent. Since
      // _availability only contains the days currently present locally,
      // any day cleared (or otherwise missing) locally was left
      // untouched on the server. The save appeared to succeed, but the
      // old value for that day silently remained in Firestore and came
      // back on the next fetch — looking like edits had "reverted to
      // default."
      //
      // Fix: write each day as its own field path via update(), and
      // explicitly FieldValue.delete() any day no longer present
      // locally, so what's on the server always exactly matches
      // _availability after a save.
      //
      // update() requires the document (and 'availability' field) to
      // already exist, so first ensure it does with a cheap no-op merge.
      await docRef.set(
        {'availability': <String, dynamic>{}},
        SetOptions(merge: true),
      );

      final Map<String, dynamic> fieldUpdates = {};
      for (final dayKey in _dayKeys) {
        final fieldPath = 'availability.$dayKey';
        if (_availability.containsKey(dayKey)) {
          fieldUpdates[fieldPath] = _availability[dayKey];
        } else {
          fieldUpdates[fieldPath] = FieldValue.delete();
        }
      }
      await docRef.update(fieldUpdates);

      Navigator.of(context).pop();
      setState(() => _hasChanges = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoText("A_S_S"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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

  Widget _buildDayCard(String dayKey) {
    final dayLabel = _dayLabel(dayKey);
    final schedule = _availability[dayKey];
    final hasSchedule = schedule != null &&
        schedule['start']!.isNotEmpty &&
        schedule['end']!.isNotEmpty;

    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasSchedule ? accent.withOpacity(0.25) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Leading day badge — filled when scheduled, outlined when not.
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasSchedule ? accent : Colors.transparent,
                    border: Border.all(
                      color: hasSchedule ? accent : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _dayAbbrev(dayKey),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasSchedule ? Colors.white : Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasSchedule
                            ? "${schedule['start']} - ${schedule['end']}"
                            : autoI8lnGen.translate("N_SCHE"),
                        style: TextStyle(
                          fontSize: 13,
                          color: hasSchedule ? accent : Colors.grey.shade500,
                          fontWeight:
                              hasSchedule ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasSchedule)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                    onSelected: (value) {
                      if (value == 'copy') {
                        _copyToOtherDays(dayKey);
                      } else if (value == 'clear') {
                        _clearDaySchedule(dayKey);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            const Icon(Icons.copy_all, size: 18),
                            const SizedBox(width: 8),
                            AutoText('COPY_TO_OTHER_DAYS'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            const Icon(Icons.clear,
                                size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            AutoText('C_SCHE',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    icon: Icons.access_time,
                    label: schedule != null && schedule['start']!.isNotEmpty
                        ? schedule['start']!
                        : autoI8lnGen.translate('S_S_T'),
                    color: accent,
                    onTap: () => _pickTime(dayKey, true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TimeChip(
                    icon: Icons.schedule,
                    label: schedule != null && schedule['end']!.isNotEmpty
                        ? schedule['end']!
                        : autoI8lnGen.translate('S_E_T_2'),
                    color: Colors.deepOrange,
                    onTap: () => _pickTime(dayKey, false),
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
                    itemCount: _dayKeys.length,
                    itemBuilder: (context, index) {
                      return _buildDayCard(_dayKeys[index]);
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
    );
  }
}

/// Small pill-shaped tappable chip used for the start/end time selectors
/// on each day card. Replaces the old full-size OutlinedButton.icon for a
/// more compact, consistent look.
class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TimeChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
          color: color.withOpacity(0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AvailabilitySchedulePage extends StatefulWidget {
//   @override
//   _AvailabilitySchedulePageState createState() =>
//       _AvailabilitySchedulePageState();
// }

// class _AvailabilitySchedulePageState extends State<AvailabilitySchedulePage> {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;

//   // IMPORTANT: These are the keys actually stored in Firestore under
//   // medical_professionals/{id}/availability. They must stay fixed
//   // (never translated), or a schedule saved in one language becomes
//   // unreadable/unmatched when the app is used in another language —
//   // this must match AllowedToChatScreen's _dayKeys exactly.
//   static const _dayKeys = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday',
//   ];

//   // Localized labels, for display only. Index-aligned with _dayKeys.
//   static const _dayTranslationKeys = [
//     'MONDAY',
//     'TUESDAY',
//     'WEDNESDAY',
//     'THURSDAY',
//     'FRIDAY',
//     'SATURDAY',
//     'SUNDAY',
//   ];

//   String _dayLabel(String dayKey) {
//     final index = _dayKeys.indexOf(dayKey);
//     if (index == -1) return dayKey;
//     return autoI8lnGen.translate(_dayTranslationKeys[index]);
//   }

//   Map<String, Map<String, String>> _availability = {};
//   int _connectedPatients = 0;
//   bool _isLoadingPatients = true;
//   bool _isLoadingAvailability = true;
//   bool _hasChanges = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchConnectedPatients();
//     _fetchAvailability();
//   }

//   Future<void> _fetchConnectedPatients() async {
//     try {
//       final uid = _auth.currentUser!.uid;

//       final query = await _firestore
//           .collection("allowed_to_chat")
//           .where("recipientId", isEqualTo: uid)
//           .get();

//       setState(() {
//         _connectedPatients = query.docs.length;
//         _isLoadingPatients = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingPatients = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: AutoText("E_P_A $e")),
//       );
//     }
//   }

//   Future<void> _fetchAvailability() async {
//     try {
//       final uid = _auth.currentUser!.uid;

//       final doc =
//           await _firestore.collection('medical_professionals').doc(uid).get();

//       if (doc.exists && doc.data() != null) {
//         final data = doc.data()!;
//         if (data.containsKey('availability')) {
//           final availabilityData = data['availability'] as Map<String, dynamic>;

//           // Convert the fetched data to the expected format.
//           // Also normalizes any legacy documents that may have been saved
//           // with translated day names as keys (from before this fix), by
//           // mapping them back onto the fixed English day keys where possible.
//           Map<String, Map<String, String>> fetchedAvailability = {};
//           availabilityData.forEach((day, schedule) {
//             if (schedule is Map<String, dynamic>) {
//               final normalizedKey = _normalizeDayKey(day);
//               fetchedAvailability[normalizedKey] = {
//                 'start': schedule['start']?.toString() ?? '',
//                 'end': schedule['end']?.toString() ?? '',
//               };
//             }
//           });

//           setState(() {
//             _availability = fetchedAvailability;
//             _isLoadingAvailability = false;
//           });
//         } else {
//           setState(() {
//             _isLoadingAvailability = false;
//           });
//         }
//       } else {
//         setState(() {
//           _isLoadingAvailability = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingAvailability = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: AutoText("E_L_A $e")),
//       );
//     }
//   }

//   /// Maps a stored day string back onto one of the fixed English day keys.
//   /// Handles legacy documents that were saved with a translated day name
//   /// (e.g. "Lundi") instead of the fixed key ("Monday"). Falls back to
//   /// returning the value unchanged if no match is found.
//   String _normalizeDayKey(String storedDay) {
//     if (_dayKeys.contains(storedDay)) return storedDay;

//     for (var i = 0; i < _dayTranslationKeys.length; i++) {
//       if (autoI8lnGen.translate(_dayTranslationKeys[i]) == storedDay) {
//         return _dayKeys[i];
//       }
//     }
//     return storedDay;
//   }

//   Future<void> _pickTime(String dayKey, bool isStart) async {
//     // Parse existing time if available
//     TimeOfDay? initialTime;

//     if (_availability.containsKey(dayKey)) {
//       final timeString = _availability[dayKey]![isStart ? "start" : "end"];
//       if (timeString != null && timeString.isNotEmpty) {
//         try {
//           initialTime = _parseTimeString(timeString);
//         } catch (e) {
//           initialTime = TimeOfDay.now();
//         }
//       }
//     }

//     final picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime ?? TimeOfDay.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         if (!_availability.containsKey(dayKey)) {
//           _availability[dayKey] = {"start": "", "end": ""};
//         }
//         _availability[dayKey]![isStart ? "start" : "end"] =
//             picked.format(context);
//         _hasChanges = true;
//       });
//     }
//   }

//   TimeOfDay _parseTimeString(String timeString) {
//     // Handle formats like "12:00 PM", "4:19 PM", etc.
//     final parts = timeString.trim().split(' ');
//     final timePart = parts[0];
//     final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

//     final timeComponents = timePart.split(':');
//     int hour = int.parse(timeComponents[0]);
//     final minute = timeComponents.length > 1 ? int.parse(timeComponents[1]) : 0;

//     // Convert to 24-hour format for TimeOfDay
//     if (amPm == 'PM' && hour != 12) {
//       hour += 12;
//     } else if (amPm == 'AM' && hour == 12) {
//       hour = 0;
//     }

//     return TimeOfDay(hour: hour, minute: minute);
//   }

//   Future<void> _clearDaySchedule(String dayKey) async {
//     final dayLabel = _dayLabel(dayKey);
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AutoText('CLR $dayLabel SCH'),
//         content: AutoText('AYSF $dayLabel?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: AutoText('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: AutoText('CLR', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       setState(() {
//         _availability.remove(dayKey);
//         _hasChanges = true;
//       });
//     }
//   }

//   Future<void> _saveSchedule() async {
//     if (!_hasChanges) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: AutoText("N_C_S")),
//       );
//       return;
//     }

//     // ── Validation ──────────────────────────────────────────────
//     List<String> incompleteDays = [];
//     List<String> invalidRangeDays = [];

//     for (final entry in _availability.entries) {
//       final dayKey = entry.key;
//       final dayLabel = _dayLabel(dayKey);
//       final schedule = entry.value;
//       final hasStart = schedule['start']?.isNotEmpty ?? false;
//       final hasEnd = schedule['end']?.isNotEmpty ?? false;

//       if (hasStart && !hasEnd) {
//         incompleteDays.add(dayLabel); // start set, end missing
//       } else if (!hasStart && hasEnd) {
//         incompleteDays.add(dayLabel); // end set, start missing
//       } else if (hasStart && hasEnd) {
//         // Validate that end time is after start time
//         try {
//           final start = _parseTimeString(schedule['start']!);
//           final end = _parseTimeString(schedule['end']!);
//           final startMinutes = start.hour * 60 + start.minute;
//           final endMinutes = end.hour * 60 + end.minute;
//           if (endMinutes <= startMinutes) {
//             invalidRangeDays.add(dayLabel);
//           }
//         } catch (_) {
//           incompleteDays.add(dayLabel);
//         }
//       }
//     }

//     if (incompleteDays.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Incomplete schedule for: ${incompleteDays.join(', ')}. "
//             "Please set both start and end times.",
//           ),
//           backgroundColor: Colors.orange,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//       return;
//     }

//     if (invalidRangeDays.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "End time must be after start time for: ${invalidRangeDays.join(', ')}.",
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//       return;
//     }
//     // ── End Validation ───────────────────────────────────────────

//     try {
//       final uid = _auth.currentUser!.uid;

//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );

//       // _availability is always keyed by the fixed English day keys
//       // (_dayKeys), so this write is safe regardless of the doctor's
//       // current app language.
//       await _firestore
//           .collection('medical_professionals')
//           .doc(uid)
//           .set({"availability": _availability}, SetOptions(merge: true));

//       Navigator.of(context).pop();
//       setState(() => _hasChanges = false);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: AutoText("A_S_S"),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: AutoText("E_S_A $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _isLoadingAvailability = true;
//       _isLoadingPatients = true;
//     });

//     await Future.wait([
//       _fetchAvailability(),
//       _fetchConnectedPatients(),
//     ]);
//   }

//   Widget _buildDayCard(String dayKey) {
//     final dayLabel = _dayLabel(dayKey);
//     final schedule = _availability[dayKey];
//     final hasSchedule = schedule != null &&
//         schedule['start']!.isNotEmpty &&
//         schedule['end']!.isNotEmpty;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   dayLabel,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (hasSchedule)
//                   IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.red),
//                     onPressed: () => _clearDaySchedule(dayKey),
//                     tooltip: autoI8lnGen.translate("C_SCHE"),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (hasSchedule) ...[
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.schedule, color: Colors.green, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "${schedule['start']} - ${schedule['end']}",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ] else ...[
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.schedule, color: Colors.grey.shade500, size: 20),
//                     const SizedBox(width: 8),
//                     AutoText(
//                       "N_SCHE",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _pickTime(dayKey, true),
//                     icon: const Icon(Icons.access_time),
//                     label: AutoText(
//                       schedule != null && schedule['start']!.isNotEmpty
//                           ? 'START ${schedule['start']}'
//                           : 'S_S_T',
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.blue,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _pickTime(dayKey, false),
//                     icon: const Icon(Icons.schedule),
//                     label: AutoText(
//                       schedule != null && schedule['end']!.isNotEmpty
//                           ? 'END ${schedule['end']}'
//                           : 'S_E_T_2',
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.orange,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const AutoText("AV_SCHE"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshData,
//             tooltip: autoI8lnGen.translate("REFRESH"),
//           ),
//         ],
//       ),
//       body: _isLoadingAvailability
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   AutoText('L_A_V_I'),
//                 ],
//               ),
//             )
//           : Column(
//               children: [
//                 // Connected Patients Info
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: _isLoadingPatients
//                       ? const CircularProgressIndicator()
//                       : Card(
//                           color: Colors.blue.shade50,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.people,
//                                     color: Colors.blue, size: 32),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       AutoText(
//                                         "CONNECTED_PATIENTS $_connectedPatients",
//                                         style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       if (_connectedPatients > 0)
//                                         AutoText(
//                                           "Y_S_W_V",
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                 ),

//                 // Availability List
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _dayKeys.length,
//                     itemBuilder: (context, index) {
//                       return _buildDayCard(_dayKeys[index]);
//                     },
//                   ),
//                 ),

//                 // Save Button at Bottom
//                 if (_hasChanges)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _saveSchedule,
//                         icon: const Icon(Icons.save),
//                         label: const AutoText('SAVE_CHANGES'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//     );
//   }
// }

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AvailabilitySchedulePage extends StatefulWidget {
//   @override
//   _AvailabilitySchedulePageState createState() =>
//       _AvailabilitySchedulePageState();
// }

// class _AvailabilitySchedulePageState extends State<AvailabilitySchedulePage> {
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;

//   final _days = [
//     autoI8lnGen.translate("MONDAY"),
//     autoI8lnGen.translate("TUESDAY"),
//     autoI8lnGen.translate("WEDNESDAY"),
//     autoI8lnGen.translate("THURSDAY"),
//     autoI8lnGen.translate("FRIDAY"),
//     autoI8lnGen.translate("SATURDAY"),
//     autoI8lnGen.translate("SUNDAY"),
//   ];

//   Map<String, Map<String, String>> _availability = {};
//   int _connectedPatients = 0;
//   bool _isLoadingPatients = true;
//   bool _isLoadingAvailability = true;
//   bool _hasChanges = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchConnectedPatients();
//     _fetchAvailability();
//   }

//   Future<void> _fetchConnectedPatients() async {
//     try {
//       final uid = _auth.currentUser!.uid;

//       final query = await _firestore
//           .collection("allowed_to_chat")
//           .where("recipientId", isEqualTo: uid)
//           .get();

//       setState(() {
//         _connectedPatients = query.docs.length;
//         _isLoadingPatients = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingPatients = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: AutoText("E_P_A $e")),
//       );
//     }
//   }

//   Future<void> _fetchAvailability() async {
//     try {
//       final uid = _auth.currentUser!.uid;

//       final doc =
//           await _firestore.collection('medical_professionals').doc(uid).get();

//       if (doc.exists && doc.data() != null) {
//         final data = doc.data()!;
//         if (data.containsKey('availability')) {
//           final availabilityData = data['availability'] as Map<String, dynamic>;

//           // Convert the fetched data to the expected format
//           Map<String, Map<String, String>> fetchedAvailability = {};
//           availabilityData.forEach((day, schedule) {
//             if (schedule is Map<String, dynamic>) {
//               fetchedAvailability[day] = {
//                 'start': schedule['start']?.toString() ?? '',
//                 'end': schedule['end']?.toString() ?? '',
//               };
//             }
//           });

//           setState(() {
//             _availability = fetchedAvailability;
//             _isLoadingAvailability = false;
//           });
//         } else {
//           setState(() {
//             _isLoadingAvailability = false;
//           });
//         }
//       } else {
//         setState(() {
//           _isLoadingAvailability = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingAvailability = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: AutoText("E_L_A $e")),
//       );
//     }
//   }

//   Future<void> _pickTime(String day, bool isStart) async {
//     // Parse existing time if available
//     TimeOfDay? initialTime;

//     if (_availability.containsKey(day)) {
//       final timeString = _availability[day]![isStart ? "start" : "end"];
//       if (timeString != null && timeString.isNotEmpty) {
//         try {
//           initialTime = _parseTimeString(timeString);
//         } catch (e) {
//           initialTime = TimeOfDay.now();
//         }
//       }
//     }

//     final picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime ?? TimeOfDay.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         if (!_availability.containsKey(day)) {
//           _availability[day] = {"start": "", "end": ""};
//         }
//         _availability[day]![isStart ? "start" : "end"] = picked.format(context);
//         _hasChanges = true;
//       });
//     }
//   }

//   TimeOfDay _parseTimeString(String timeString) {
//     // Handle formats like "12:00 PM", "4:19 PM", etc.
//     final parts = timeString.trim().split(' ');
//     final timePart = parts[0];
//     final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

//     final timeComponents = timePart.split(':');
//     int hour = int.parse(timeComponents[0]);
//     final minute = timeComponents.length > 1 ? int.parse(timeComponents[1]) : 0;

//     // Convert to 24-hour format for TimeOfDay
//     if (amPm == 'PM' && hour != 12) {
//       hour += 12;
//     } else if (amPm == 'AM' && hour == 12) {
//       hour = 0;
//     }

//     return TimeOfDay(hour: hour, minute: minute);
//   }

//   Future<void> _clearDaySchedule(String day) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AutoText('CLR $day SCH'),
//         content: AutoText('AYSF $day?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: AutoText('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: AutoText('CLR', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       setState(() {
//         _availability.remove(day);
//         _hasChanges = true;
//       });
//     }
//   }

//   // Future<void> _saveSchedule() async {
//   //   if (!_hasChanges) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: AutoText("N_C_S")),
//   //     );
//   //     return;
//   //   }

//   //   try {
//   //     final uid = _auth.currentUser!.uid;

//   //     // Show loading
//   //     showDialog(
//   //       context: context,
//   //       barrierDismissible: false,
//   //       builder: (context) => const Center(
//   //         child: CircularProgressIndicator(),
//   //       ),
//   //     );

//   //     await _firestore
//   //         .collection('medical_professionals')
//   //         .doc(uid)
//   //         .set({"availability": _availability}, SetOptions(merge: true));

//   //     // Hide loading
//   //     Navigator.of(context).pop();

//   //     setState(() {
//   //       _hasChanges = false;
//   //     });

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: AutoText("A_S_S"),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     // Hide loading
//   //     Navigator.of(context).pop();

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: AutoText("E_S_A $e"),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   }
//   // }
//   Future<void> _saveSchedule() async {
//     if (!_hasChanges) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: AutoText("N_C_S")),
//       );
//       return;
//     }

//     // ── Validation ──────────────────────────────────────────────
//     List<String> incompleteDays = [];
//     List<String> invalidRangeDays = [];

//     for (final entry in _availability.entries) {
//       final day = entry.key;
//       final schedule = entry.value;
//       final hasStart = schedule['start']?.isNotEmpty ?? false;
//       final hasEnd = schedule['end']?.isNotEmpty ?? false;

//       if (hasStart && !hasEnd) {
//         incompleteDays.add(day); // start set, end missing
//       } else if (!hasStart && hasEnd) {
//         incompleteDays.add(day); // end set, start missing
//       } else if (hasStart && hasEnd) {
//         // Validate that end time is after start time
//         try {
//           final start = _parseTimeString(schedule['start']!);
//           final end = _parseTimeString(schedule['end']!);
//           final startMinutes = start.hour * 60 + start.minute;
//           final endMinutes = end.hour * 60 + end.minute;
//           if (endMinutes <= startMinutes) {
//             invalidRangeDays.add(day);
//           }
//         } catch (_) {
//           incompleteDays.add(day);
//         }
//       }
//     }

//     if (incompleteDays.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Incomplete schedule for: ${incompleteDays.join(', ')}. "
//             "Please set both start and end times.",
//           ),
//           backgroundColor: Colors.orange,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//       return;
//     }

//     if (invalidRangeDays.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "End time must be after start time for: ${invalidRangeDays.join(', ')}.",
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//         ),
//       );
//       return;
//     }
//     // ── End Validation ───────────────────────────────────────────

//     try {
//       final uid = _auth.currentUser!.uid;

//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(child: CircularProgressIndicator()),
//       );

//       await _firestore
//           .collection('medical_professionals')
//           .doc(uid)
//           .set({"availability": _availability}, SetOptions(merge: true));

//       Navigator.of(context).pop();
//       setState(() => _hasChanges = false);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: AutoText("A_S_S"),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: AutoText("E_S_A $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       _isLoadingAvailability = true;
//       _isLoadingPatients = true;
//     });

//     await Future.wait([
//       _fetchAvailability(),
//       _fetchConnectedPatients(),
//     ]);
//   }

//   Widget _buildDayCard(String day) {
//     final schedule = _availability[day];
//     final hasSchedule = schedule != null &&
//         schedule['start']!.isNotEmpty &&
//         schedule['end']!.isNotEmpty;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   day,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (hasSchedule)
//                   IconButton(
//                     icon: const Icon(Icons.clear, color: Colors.red),
//                     onPressed: () => _clearDaySchedule(day),
//                     tooltip: autoI8lnGen.translate("C_SCHE"),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (hasSchedule) ...[
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.schedule, color: Colors.green, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "${schedule['start']} - ${schedule['end']}",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ] else ...[
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.schedule, color: Colors.grey.shade500, size: 20),
//                     const SizedBox(width: 8),
//                     AutoText(
//                       "N_SCHE",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _pickTime(day, true),
//                     icon: const Icon(Icons.access_time),
//                     label: AutoText(
//                       schedule != null && schedule['start']!.isNotEmpty
//                           ? 'START ${schedule['start']}'
//                           : 'S_S_T',
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.blue,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => _pickTime(day, false),
//                     icon: const Icon(Icons.schedule),
//                     label: AutoText(
//                       schedule != null && schedule['end']!.isNotEmpty
//                           ? 'END ${schedule['end']}'
//                           : 'S_E_T_2',
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.orange,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const AutoText("AV_SCHE"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshData,
//             tooltip: autoI8lnGen.translate("REFRESH"),
//           ),
//         ],
//       ),
//       body: _isLoadingAvailability
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   AutoText('L_A_V_I'),
//                 ],
//               ),
//             )
//           : Column(
//               children: [
//                 // Connected Patients Info
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: _isLoadingPatients
//                       ? const CircularProgressIndicator()
//                       : Card(
//                           color: Colors.blue.shade50,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.people,
//                                     color: Colors.blue, size: 32),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       AutoText(
//                                         "CONNECTED_PATIENTS $_connectedPatients",
//                                         style: const TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600),
//                                       ),
//                                       if (_connectedPatients > 0)
//                                         AutoText(
//                                           "Y_S_W_V",
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.grey.shade600,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                 ),

//                 // Availability List
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _days.length,
//                     itemBuilder: (context, index) {
//                       return _buildDayCard(_days[index]);
//                     },
//                   ),
//                 ),

//                 // Save Button at Bottom
//                 if (_hasChanges)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _saveSchedule,
//                         icon: const Icon(Icons.save),
//                         label: const AutoText('SAVE_CHANGES'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//     );
//   }
// }
