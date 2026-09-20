import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service_mothers.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:provider/provider.dart';

class AllowedToChatScreen extends StatelessWidget {
  // IMPORTANT: These keys must match exactly what's stored in Firestore
  // under medical_professionals/{id}/availability. They must NOT be
  // translated, or lookups silently break whenever the app locale changes.
  static const _dayKeys = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: AutoText('HEALTH_PROVIDER'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allowed_to_chat')
            .where('requesterId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0), child: AutoText('ERROR_17')),
            );
          }

          final allowedChats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: allowedChats.length,
            itemBuilder: (context, index) {
              final chatData =
                  allowedChats[index].data() as Map<String, dynamic>;
              final requesterId = chatData['recipientId'];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: Future.wait([
                    FirebaseFirestore.instance
                        .collection('Health Professionals')
                        .doc(requesterId)
                        .get(),
                    FirebaseFirestore.instance
                        .collection('medical_professionals')
                        .doc(requesterId)
                        .get(),
                  ]),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: AutoText('LOADING_2'),
                        subtitle: LinearProgressIndicator(),
                      );
                    }

                    if (!futureSnapshot.hasData ||
                        futureSnapshot.data!.length < 2) {
                      return ListTile(title: AutoText('USER_NOT_FOUND'));
                    }

                    final userSnapshot = futureSnapshot.data![0];
                    final medicalProfSnapshot = futureSnapshot.data![1];

                    if (!userSnapshot.exists) {
                      return ListTile(title: AutoText('USER_NOT_FOUND'));
                    }

                    final userData =
                        userSnapshot.data() as Map<String, dynamic>;
                    final userName = userData['fullName'] ?? 'NO_NAME';
                    final userPosition =
                        userData['position'] ?? 'Health Provider';
                    final hospital = userData['hospital'] ?? '';

                    // Process availability data
                    Map<String, dynamic>? availabilityData;
                    if (medicalProfSnapshot.exists) {
                      final medicalData =
                          medicalProfSnapshot.data() as Map<String, dynamic>;
                      availabilityData =
                          medicalData['availability'] as Map<String, dynamic>?;
                    }

                    final isAvailable = _isCurrentlyAvailable(availabilityData);

                    return ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userPosition,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          if (hospital.isNotEmpty)
                            Text(
                              hospital,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          SizedBox(height: 4),
                          _buildAvailabilityStatus(availabilityData),

                          const Divider(),

                          // Delete Button:

                          TextButton.icon(
                            onPressed: () => _confirmDeletion(
                                context, userId, requesterId, userName),
                            icon: const Icon(Icons.person_remove,
                                color: Colors.red),
                            label: const AutoText("DISCONNECT_PROVIDER",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.chat_bubble,
                          color: isAvailable
                              ? Colors.blue.shade600
                              : Colors.grey.shade400,
                        ),
                        onPressed: () {
                          if (isAvailable) {
                            startChat(context, requesterId);
                          } else {
                            _showNotAvailableDialog(context);
                          }
                        },
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: _buildAvailabilityDetails(availabilityData),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityStatus(Map<String, dynamic>? availabilityData) {
    if (availabilityData == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AutoText(
          'AVAILABILITY_NOT_SET',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final isCurrentlyAvailable = _isCurrentlyAvailable(availabilityData);
    final nextAvailability = _getNextAvailability(availabilityData);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrentlyAvailable
            ? Colors.green.shade100
            : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCurrentlyAvailable
            ? autoI8lnGen.translate('AVAILABLE_NOW')
            : nextAvailability != null
                ? '${autoI8lnGen.translate('NEXT')} $nextAvailability'
                : autoI8lnGen.translate('S_N_A'),
        style: TextStyle(
          color: isCurrentlyAvailable
              ? Colors.green.shade700
              : Colors.orange.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAvailabilityDetails(Map<String, dynamic>? availabilityData) {
    if (availabilityData == null) {
      return Column(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.grey.shade400,
            size: 48,
          ),
          SizedBox(height: 8),
          AutoText(
            'NASS',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          AutoText(
            'CHPD',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: Colors.blue.shade600,
              size: 20,
            ),
            SizedBox(width: 8),
            AutoText(
              'W_SC',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ..._buildWeeklySchedule(availabilityData),
        SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildWeeklySchedule(Map<String, dynamic> availabilityData) {
    return List.generate(7, (index) {
      final weekday = index + 1; // 1 = Monday ... 7 = Sunday
      final dayKey = _getDayKey(weekday);
      final dayLabel = _getDayLabel(weekday);
      final dayData = availabilityData[dayKey] as Map<String, dynamic>?;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                dayLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(child: _buildDaySchedule(dayData)),
          ],
        ),
      );
    });
  }

  Widget _buildDaySchedule(Map<String, dynamic>? dayData) {
    if (dayData == null) {
      return _notAvailableBox();
    }

    final startTime = dayData['start'] ?? '';
    final endTime = dayData['end'] ?? '';

    if (startTime.toString().isEmpty || endTime.toString().isEmpty) {
      return _notAvailableBox();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        '$startTime - $endTime',
        style: TextStyle(
          color: Colors.green.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _notAvailableBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AutoText(
        'NOT_AVAILABLE',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showNotAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AutoText(
            'PROVIDER_NOT_AVAILABLE_TITLE'), // "PROVIDER_NOT_AVAILABLE_TITLE": "Provider Not Available"
        content: AutoText(
          // "PROVIDER_NOT_AVAILABLE_MESSAGE": "This health provider is not available at the moment.\n\nPlease check their availability schedule or contact them during their working hours. In case of an emergency, go to the nearest health facility."
          'PROVIDER_NOT_AVAILABLE_MESSAGE',
          style: TextStyle(
              height:
                  1.5), // It's good practice to provide styling if needed for better readability
        ),
        actions: [
          // "OK": "OK"
          TextButton(
            child: AutoText('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  bool _isCurrentlyAvailable(Map<String, dynamic>? availabilityData) {
    if (availabilityData == null) return false;

    final now = DateTime.now();
    final currentDayKey = _getDayKey(now.weekday);
    final currentTime = TimeOfDay.now();

    final dayData = availabilityData[currentDayKey] as Map<String, dynamic>?;

    if (dayData == null) return false;

    final startTimeStr = dayData['start'] as String?;
    final endTimeStr = dayData['end'] as String?;

    final startTime = _parseTimeString(startTimeStr);
    final endTime = _parseTimeString(endTimeStr);

    if (startTime == null || endTime == null) return false;

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  String? _getNextAvailability(Map<String, dynamic> availabilityData) {
    final now = DateTime.now();
    final currentDay = now.weekday;

    for (int i = 0; i < 7; i++) {
      final checkDay = (currentDay + i - 1) % 7 + 1;
      final dayKey = _getDayKey(checkDay);
      final dayData = availabilityData[dayKey] as Map<String, dynamic>?;

      if (dayData != null) {
        final startTimeStr = dayData['start'] as String?;
        if (startTimeStr != null && startTimeStr.isNotEmpty) {
          if (i == 0) {
            final currentTime = TimeOfDay.now();
            final endTimeStr = dayData['end'] as String?;
            final endTime = _parseTimeString(endTimeStr);

            if (endTime != null) {
              final currentMinutes = currentTime.hour * 60 + currentTime.minute;
              final endMinutes = endTime.hour * 60 + endTime.minute;

              if (currentMinutes < endMinutes) {
                // Localized string interpolation
                return '${autoI8lnGen.translate("TODAY_AT")} $startTimeStr';
              }
            }
          } else {
            final dayLabel = i == 1
                ? autoI8lnGen.translate("TOMORROW")
                : _getDayLabel(checkDay);
            return '$dayLabel ${autoI8lnGen.translate("AT")} $startTimeStr';
          }
        }
      }
    }
    return null;
  }

  /// Parses a time string like "09:30", "9:30 PM", or "9" into a TimeOfDay.
  /// Returns null instead of throwing if the value is missing, empty, or
  /// malformed, so a single bad Firestore document can never crash the UI.
  TimeOfDay? _parseTimeString(String? timeString) {
    if (timeString == null || timeString.trim().isEmpty) return null;

    final parts = timeString.trim().split(' ');
    final timePart = parts[0];
    final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

    final timeComponents = timePart.split(':');
    if (timeComponents.isEmpty) return null;

    final hour = int.tryParse(timeComponents[0]);
    final minute =
        timeComponents.length > 1 ? int.tryParse(timeComponents[1]) : 0;

    if (hour == null || minute == null) return null;

    int adjustedHour = hour;
    if (amPm == 'PM' && hour != 12) {
      adjustedHour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      adjustedHour = 0;
    }

    return TimeOfDay(hour: adjustedHour, minute: minute);
  }

  /// Locale-independent key used to read from Firestore.
  /// This MUST match the keys written by whatever screen the medical
  /// professional uses to set their availability (e.g. 'Monday', not
  /// a translated string), or lookups break whenever the app locale changes.
  String _getDayKey(int weekday) => _dayKeys[weekday - 1];

  /// Localized label used only for on-screen display.
  String _getDayLabel(int weekday) {
    const translationKeys = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return autoI8lnGen.translate(translationKeys[weekday - 1]);
  }

  void _confirmDeletion(BuildContext context, String currentUserId,
      String otherUserId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoText('CONFIRM_DISCONNECT_TITLE'),
        content: Text(
            '${autoI8lnGen.translate('CONFIRM_DISCONNECT_MSG')} $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoText('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              // This calls the logic in your ConnectionStateModel
              await Provider.of<ConnectionStateModel>(context, listen: false)
                  .endConnection(
                      currentUserId: currentUserId, otherUserId: otherUserId);

              if (context.mounted) Navigator.pop(context);
            },
            child:
                const AutoText('DISCONNECT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/controllers/chat_service_mothers.dart';
// import 'package:jambomama_nigeria/providers/connection_provider.dart';
// import 'package:provider/provider.dart';

// class AllowedToChatScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('HEALTH_PROVIDER'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('allowed_to_chat')
//             .where('requesterId', isEqualTo: userId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: AutoText('ERROR_17'),
//             );
//           }

//           final allowedChats = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: allowedChats.length,
//             itemBuilder: (context, index) {
//               final chatData =
//                   allowedChats[index].data() as Map<String, dynamic>;
//               final requesterId = chatData['recipientId'];

//               return Card(
//                 margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 elevation: 2,
//                 child: FutureBuilder<List<DocumentSnapshot>>(
//                   future: Future.wait([
//                     FirebaseFirestore.instance
//                         .collection('Health Professionals')
//                         .doc(requesterId)
//                         .get(),
//                     FirebaseFirestore.instance
//                         .collection('medical_professionals')
//                         .doc(requesterId)
//                         .get(),
//                   ]),
//                   builder: (context, futureSnapshot) {
//                     if (futureSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return ListTile(
//                         title: AutoText('LOADING_2'),
//                         subtitle: LinearProgressIndicator(),
//                       );
//                     }

//                     if (!futureSnapshot.hasData ||
//                         futureSnapshot.data!.length < 2) {
//                       return ListTile(title: AutoText('USER_NOT_FOUND'));
//                     }

//                     final userSnapshot = futureSnapshot.data![0];
//                     final medicalProfSnapshot = futureSnapshot.data![1];

//                     if (!userSnapshot.exists) {
//                       return ListTile(title: AutoText('USER_NOT_FOUND'));
//                     }

//                     final userData =
//                         userSnapshot.data() as Map<String, dynamic>;
//                     final userName = userData['fullName'] ?? 'NO_NAME';
//                     final userPosition =
//                         userData['position'] ?? 'Health Provider';
//                     final hospital = userData['hospital'] ?? '';

//                     // Process availability data
//                     Map<String, dynamic>? availabilityData;
//                     if (medicalProfSnapshot.exists) {
//                       final medicalData =
//                           medicalProfSnapshot.data() as Map<String, dynamic>;
//                       availabilityData =
//                           medicalData['availability'] as Map<String, dynamic>?;
//                     }

//                     final isAvailable = _isCurrentlyAvailable(availabilityData);

//                     return ExpansionTile(
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.blue.shade100,
//                         child: Icon(
//                           Icons.medical_services,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                       title: Text(
//                         userName,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             userPosition,
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 14,
//                             ),
//                           ),
//                           if (hospital.isNotEmpty)
//                             Text(
//                               hospital,
//                               style: TextStyle(
//                                 color: Colors.grey.shade500,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           SizedBox(height: 4),
//                           _buildAvailabilityStatus(availabilityData),

//                           const Divider(),

//                           // Delete Button:

//                           TextButton.icon(
//                             onPressed: () => _confirmDeletion(
//                                 context, userId, requesterId, userName),
//                             icon: const Icon(Icons.person_remove,
//                                 color: Colors.red),
//                             label: const AutoText("DISCONNECT_PROVIDER",
//                                 style: TextStyle(color: Colors.red)),
//                           ),
//                         ],
//                       ),
//                       trailing: IconButton(
//                         icon: Icon(
//                           Icons.chat_bubble,
//                           color: isAvailable
//                               ? Colors.blue.shade600
//                               : Colors.grey.shade400,
//                         ),
//                         onPressed: () {
//                           if (isAvailable) {
//                             startChat(context, requesterId);
//                           } else {
//                             _showNotAvailableDialog(context);
//                           }
//                         },
//                       ),
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.all(16),
//                           child: _buildAvailabilityDetails(availabilityData),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildAvailabilityStatus(Map<String, dynamic>? availabilityData) {
//     if (availabilityData == null) {
//       return Container(
//         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: AutoText(
//           'AVAILABILITY_NOT_SET',
//           style: TextStyle(
//             color: Colors.grey.shade600,
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       );
//     }

//     final isCurrentlyAvailable = _isCurrentlyAvailable(availabilityData);
//     final nextAvailability = _getNextAvailability(availabilityData);

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: isCurrentlyAvailable
//             ? Colors.green.shade100
//             : Colors.orange.shade100,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: AutoText(
//         isCurrentlyAvailable
//             ? 'AVAILABLE_NOW'
//             : nextAvailability != null
//                 ? 'NEXT $nextAvailability'
//                 : 'S_N_A',
//         style: TextStyle(
//           color: isCurrentlyAvailable
//               ? Colors.green.shade700
//               : Colors.orange.shade700,
//           fontSize: 11,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailabilityDetails(Map<String, dynamic>? availabilityData) {
//     if (availabilityData == null) {
//       return Column(
//         children: [
//           Icon(
//             Icons.schedule,
//             color: Colors.grey.shade400,
//             size: 48,
//           ),
//           SizedBox(height: 8),
//           AutoText(
//             'NASS',
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 4),
//           AutoText(
//             'CHPD',
//             style: TextStyle(
//               color: Colors.grey.shade500,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.schedule,
//               color: Colors.blue.shade600,
//               size: 20,
//             ),
//             SizedBox(width: 8),
//             AutoText(
//               'W_SC',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.blue.shade700,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12),
//         ..._buildWeeklySchedule(availabilityData),
//         SizedBox(height: 16),
//       ],
//     );
//   }

//   List<Widget> _buildWeeklySchedule(Map<String, dynamic> availabilityData) {
//     final days = [
//       autoI8lnGen.translate("MONDAY"),
//       autoI8lnGen.translate("TUESDAY"),
//       autoI8lnGen.translate("WEDNESDAY"),
//       autoI8lnGen.translate("THURSDAY"),
//       autoI8lnGen.translate("FRIDAY"),
//       autoI8lnGen.translate("SATURDAY"),
//       autoI8lnGen.translate("SUNDAY"),
//     ];

//     return days.map((day) {
//       final dayData = availabilityData[day] as Map<String, dynamic>?;

//       return Padding(
//         padding: EdgeInsets.symmetric(vertical: 4),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 80,
//               child: Text(
//                 day,
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),
//             Expanded(child: _buildDaySchedule(dayData)),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildDaySchedule(Map<String, dynamic>? dayData) {
//     if (dayData == null) {
//       return _notAvailableBox();
//     }

//     final startTime = dayData['start'] ?? '';
//     final endTime = dayData['end'] ?? '';

//     if (startTime.toString().isEmpty || endTime.toString().isEmpty) {
//       return _notAvailableBox();
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.green.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Text(
//         '$startTime - $endTime',
//         style: TextStyle(
//           color: Colors.green.shade700,
//           fontWeight: FontWeight.w500,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }

//   Widget _notAvailableBox() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: AutoText(
//         'NOT_AVAILABLE',
//         style: TextStyle(
//           color: Colors.grey.shade600,
//           fontSize: 13,
//         ),
//       ),
//     );
//   }

//   void _showNotAvailableDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: AutoText(
//             'PROVIDER_NOT_AVAILABLE_TITLE'), // "PROVIDER_NOT_AVAILABLE_TITLE": "Provider Not Available"
//         content: AutoText(
//           // "PROVIDER_NOT_AVAILABLE_MESSAGE": "This health provider is not available at the moment.\n\nPlease check their availability schedule or contact them during their working hours. In case of an emergency, go to the nearest health facility."
//           'PROVIDER_NOT_AVAILABLE_MESSAGE',
//           style: TextStyle(
//               height:
//                   1.5), // It's good practice to provide styling if needed for better readability
//         ),
//         actions: [
//           // "OK": "OK"
//           TextButton(
//             child: AutoText('OK'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _isCurrentlyAvailable(Map<String, dynamic>? availabilityData) {
//     if (availabilityData == null) return false;

//     final now = DateTime.now();
//     final currentDay = _getDayName(now.weekday);
//     final currentTime = TimeOfDay.now();

//     final dayData = availabilityData[currentDay] as Map<String, dynamic>?;

//     if (dayData == null) return false;

//     final startTimeStr = dayData['start'] as String?;
//     final endTimeStr = dayData['end'] as String?;

//     if (startTimeStr == null || endTimeStr == null) return false;

//     try {
//       final startTime = _parseTimeString(startTimeStr);
//       final endTime = _parseTimeString(endTimeStr);

//       final currentMinutes = currentTime.hour * 60 + currentTime.minute;
//       final startMinutes = startTime.hour * 60 + startTime.minute;
//       final endMinutes = endTime.hour * 60 + endTime.minute;

//       return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
//     } catch (_) {
//       return false;
//     }
//   }

//   String? _getNextAvailability(Map<String, dynamic> availabilityData) {
//     final now = DateTime.now();
//     final currentDay = now.weekday;

//     for (int i = 0; i < 7; i++) {
//       final checkDay = (currentDay + i - 1) % 7 + 1;
//       final dayName = _getDayName(checkDay);
//       final dayData = availabilityData[dayName] as Map<String, dynamic>?;

//       if (dayData != null) {
//         final startTimeStr = dayData['start'] as String?;
//         if (startTimeStr != null && startTimeStr.isNotEmpty) {
//           if (i == 0) {
//             final currentTime = TimeOfDay.now();
//             final endTimeStr = dayData['end'] as String?;
//             if (endTimeStr != null) {
//               final endTime = _parseTimeString(endTimeStr);
//               final currentMinutes = currentTime.hour * 60 + currentTime.minute;
//               final endMinutes = endTime.hour * 60 + endTime.minute;

//               if (currentMinutes < endMinutes) {
//                 // Localized string interpolation
//                 return '${autoI8lnGen.translate("TODAY_AT")} $startTimeStr';
//               }
//             }
//           } else {
//             final dayLabel =
//                 i == 1 ? autoI8lnGen.translate("TOMORROW") : dayName;
//             return '$dayLabel ${autoI8lnGen.translate("AT")} $startTimeStr';
//           }
//         }
//       }
//     }
//     return null;
//   }

//   TimeOfDay _parseTimeString(String timeString) {
//     final parts = timeString.trim().split(' ');
//     final timePart = parts[0];
//     final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';

//     final timeComponents = timePart.split(':');
//     int hour = int.parse(timeComponents[0]);
//     final minute = timeComponents.length > 1 ? int.parse(timeComponents[1]) : 0;

//     if (amPm == 'PM' && hour != 12) {
//       hour += 12;
//     } else if (amPm == 'AM' && hour == 12) {
//       hour = 0;
//     }

//     return TimeOfDay(hour: hour, minute: minute);
//   }

//   String _getDayName(int weekday) {
//     final days = [
//       autoI8lnGen.translate("MONDAY"),
//       autoI8lnGen.translate("TUESDAY"),
//       autoI8lnGen.translate("WEDNESDAY"),
//       autoI8lnGen.translate("THURSDAY"),
//       autoI8lnGen.translate("FRIDAY"),
//       autoI8lnGen.translate("SATURDAY"),
//       autoI8lnGen.translate("SUNDAY"),
//     ];

//     return days[weekday - 1];
//   }

//   void _confirmDeletion(BuildContext context, String currentUserId,
//       String otherUserId, String name) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Disconnect'),
//         content: Text(
//             'Are you sure you want to end the chat connection with $name?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               // This calls the logic in your ConnectionStateModel
//               await Provider.of<ConnectionStateModel>(context, listen: false)
//                   .endConnection(
//                       currentUserId: currentUserId, otherUserId: otherUserId);

//               if (context.mounted) Navigator.pop(context);
//             },
//             child:
//                 const Text('Disconnect', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
