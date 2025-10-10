import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service_mothers.dart';

class AllowedToChatScreen extends StatelessWidget {
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
              child: AutoText('ERROR_17'),
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
                    final userPosition = userData['position'] ?? 'Health Provider';
                    final hospital = userData['hospital'] ?? '';

                    // Process availability data from medical_professionals collection
                    Map<String, dynamic>? availabilityData;
                    if (medicalProfSnapshot.exists) {
                      final medicalData = medicalProfSnapshot.data() as Map<String, dynamic>;
                      availabilityData = medicalData['availability'] as Map<String, dynamic>?;
                    }

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
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.chat_bubble,
                          color: Colors.blue.shade600,
                        ),
                        onPressed: () {
                          startChat(context, requesterId);
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
        child: Text(
          'Availability not set',
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
        color: isCurrentlyAvailable ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCurrentlyAvailable 
            ? 'Available now'
            : nextAvailability != null 
                ? 'Next: $nextAvailability'
                : 'Schedule not available',
        style: TextStyle(
          color: isCurrentlyAvailable ? Colors.green.shade700 : Colors.orange.shade700,
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
            'No availability schedule set',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          AutoText(
            'Contact the health provider directly',
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
            Text(
              'Weekly Schedule',
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
        _buildEmergencyContact(availabilityData),
      ],
    );
  }

  List<Widget> _buildWeeklySchedule(Map<String, dynamic> availabilityData) {
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    List<Widget> scheduleWidgets = [];
    
    for (String day in days) {
      // Use the exact case as stored in Firestore (capitalized)
      final dayData = availabilityData[day] as Map<String, dynamic>?;
      
      scheduleWidgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Expanded(
                child: _buildDaySchedule(dayData),
              ),
            ],
          ),
        ),
      );
    }
    
    return scheduleWidgets;
  }

  Widget _buildDaySchedule(Map<String, dynamic>? dayData) {
    if (dayData == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Not available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      );
    }

    final startTime = dayData['start'] ?? '';
    final endTime = dayData['end'] ?? '';

    if (startTime.toString().isEmpty || endTime.toString().isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Not available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      );
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

  Widget _buildEmergencyContact(Map<String, dynamic> availabilityData) {
    // Since your structure doesn't include emergency contact fields,
    // we'll skip this section or you can add these fields to your availability structure
    return SizedBox.shrink();
  }

  bool _isCurrentlyAvailable(Map<String, dynamic> availabilityData) {
    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday); // Use capitalized day name
    final currentTime = TimeOfDay.now();

    final dayData = availabilityData[currentDay] as Map<String, dynamic>?;
    
    if (dayData == null) {
      return false;
    }

    final startTimeStr = dayData['start'] as String?;
    final endTimeStr = dayData['end'] as String?;

    if (startTimeStr == null || endTimeStr == null || 
        startTimeStr.isEmpty || endTimeStr.isEmpty) {
      return false;
    }

    try {
      final startTime = _parseTimeString(startTimeStr);
      final endTime = _parseTimeString(endTimeStr);

      // Convert current time to minutes for comparison
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      return false;
    }
  }

  String? _getNextAvailability(Map<String, dynamic> availabilityData) {
    final now = DateTime.now();
    final currentDay = now.weekday;

    // Check remaining days of current week and next week
    for (int i = 0; i < 7; i++) {
      final checkDay = (currentDay + i - 1) % 7 + 1;
      final dayName = _getDayName(checkDay); // Use capitalized day name
      final dayData = availabilityData[dayName] as Map<String, dynamic>?;

      if (dayData != null) {
        final startTimeStr = dayData['start'] as String?;
        if (startTimeStr != null && startTimeStr.isNotEmpty) {
          if (i == 0) {
            // Today - check if there's still time
            final currentTime = TimeOfDay.now();
            final endTimeStr = dayData['end'] as String?;
            if (endTimeStr != null) {
              try {
                final endTime = _parseTimeString(endTimeStr);
                final currentMinutes = currentTime.hour * 60 + currentTime.minute;
                final endMinutes = endTime.hour * 60 + endTime.minute;
                
                if (currentMinutes < endMinutes) {
                  return 'Today at $startTimeStr';
                }
              } catch (e) {
                // Continue to next day if parsing fails
              }
            }
          } else {
            final dayLabel = i == 1 ? 'Tomorrow' : dayName;
            return '$dayLabel at $startTimeStr';
          }
        }
      }
    }

    return null;
  }

  // Helper function to parse 12-hour time format to TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    // Handle formats like "12:00 PM", "4:19 PM", etc.
    final parts = timeString.trim().split(' ');
    final timePart = parts[0];
    final amPm = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
    
    final timeComponents = timePart.split(':');
    int hour = int.parse(timeComponents[0]);
    final minute = timeComponents.length > 1 ? int.parse(timeComponents[1]) : 0;
    
    // Convert to 24-hour format
    if (amPm == 'PM' && hour != 12) {
      hour += 12;
    } else if (amPm == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }
}

