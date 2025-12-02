import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/controllers/forgot_password.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';
import 'package:jambomama_nigeria/midwives/views/components/drop_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String email;

  const SettingsScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool receiveNotifications = true;
  bool isLoading = false;
  bool isSavingNotifications = false;

  // Local editable state — ALWAYS used in UI
  String fullName = "";
  String hospital = "";
  String stateValue = "";
  String cityValue = "";
  String villageTown = "";

  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController townController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadSettings();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    hospitalController.dispose();
    stateController.dispose();
    cityController.dispose();
    townController.dispose();
    super.dispose();
  }

  // -------------------------
  // LOAD PROFILE FROM FIRESTORE
  // -------------------------
  Future<void> _loadProfile() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('Health Professionals')
        .doc(user!.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      fullName = data['fullName'] ?? "";
      hospital = data['healthFacility'] ?? "";
      stateValue = data['stateValue'] ?? "";
      cityValue = data['cityValue'] ?? "";
      villageTown = data['villageTown'] ?? "";
    });
  }

  // -------------------------
  // SAVE PROFILE EDITS
  // -------------------------
  Future<bool> _saveProfileChanges() async {
    if (user == null) return false;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Health Professionals')
          .doc(user!.uid)
          .update({
        'fullName': fullNameController.text,
        'healthFacility': hospitalController.text,
        'stateValue': stateController.text,
        'cityValue': cityController.text,
        'villageTown': townController.text,
      });

      // Update UI immediately
      setState(() {
        fullName = fullNameController.text;
        hospital = hospitalController.text;
        stateValue = stateController.text;
        cityValue = cityController.text;
        villageTown = townController.text;
        isLoading = false;
      });

      _showSuccessSnackBar("Profile updated successfully");
      return true;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("Error updating profile: $e");
      return false;
    }
  }

  // -------------------------
  // LOAD NOTIFICATION SETTINGS
  // -------------------------
  Future<void> _loadSettings() async {
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          receiveNotifications = snapshot['receiveNotifications'] ?? true;
        });
      }
    } catch (_) {}
  }

  // -------------------------
  // TOGGLE NOTIFICATIONS
  // -------------------------
  Future<void> _toggleNotifications(bool value) async {
    if (user == null) return;

    final previous = receiveNotifications;

    setState(() {
      receiveNotifications = value;
      isSavingNotifications = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(user!.uid)
          .set({'receiveNotifications': value}, SetOptions(merge: true));

      await prefs.setBool("disabled_notification_key", !value);

      String fcmToken = "";
      if (value) {
        fcmToken = NotificationService.instance.userFcmToken ?? "";
      }

      await FirebaseFirestore.instance
          .collection('Health Professionals')
          .doc(user!.uid)
          .update({'fcmToken': fcmToken});

      setState(() {
        isSavingNotifications = false;
      });
    } catch (e) {
      setState(() {
        receiveNotifications = previous;
        isSavingNotifications = false;
      });
      _showErrorSnackBar("Failed: $e");
    }
  }

  // -------------------------
  // EDIT MODAL
  // -------------------------
  void _showEditProfileModal() {
    // Populate controllers from state (NOT widget)
    fullNameController.text = fullName;
    hospitalController.text = hospital;
    stateController.text = stateValue;
    cityController.text = cityValue;
    townController.text = villageTown;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoText('EDIT_PROFILE',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildTextField(
                    label: autoI8lnGen.translate("FULL_NAME"),
                    controller: fullNameController),
                _buildTextField(
                    label: autoI8lnGen.translate("HOSPITAL"),
                    controller: hospitalController),
                _buildTextField(
                    label: autoI8lnGen.translate("STATE"),
                    controller: stateController),
                _buildTextField(
                    label: autoI8lnGen.translate("CITY"),
                    controller: cityController),
                _buildTextField(
                    label: autoI8lnGen.translate("TOWN"),
                    controller: townController),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final ok = await _saveProfileChanges();
                            if (ok && mounted) Navigator.pop(context);
                          },
                    child: isLoading
                        ? CircularProgressIndicator(strokeWidth: 2)
                        : AutoText('SAVE_CHANGES'),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // -------------------------
  // UI BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AutoText('SETTINGS')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildProfileSection(),
          SizedBox(height: 20),
          _buildNotificationSettings(),
          SizedBox(height: 20),
          _buildPrivacySecuritySection(),
          SizedBox(height: 20),
          Center(child: AutoText('VERSION 1.0.0')),
        ],
      ),
    );
  }

  Widget _buildProfileSection() => Card(
        elevation: 2,
        child: ListTile(
          title: Text(fullName, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(widget.email),
          trailing: TextButton(
            onPressed: _showEditProfileModal,
            child: AutoText('EDIT_PROFILE'),
          ),
        ),
      );

  Widget _buildNotificationSettings() => Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoText('NOTIFICATIONS',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SwitchListTile(
              value: receiveNotifications,
              onChanged: isSavingNotifications ? null : _toggleNotifications,
              title: Row(
                children: [
                  Expanded(child: AutoText('RECEIVE_NOTIFICATIONS')),
                  if (isSavingNotifications)
                    CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
            ),
            DropDownButton(),
          ],
        ),
      );

  Widget _buildPrivacySecuritySection() => Card(
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AutoText('PRIVACY&SECURITY',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.lock_outline),
              title: AutoText('CHANGE_PASSWORD'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );

  // -------------------------
  // SNACKBARS
  // -------------------------
  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }
}




// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jambomama_nigeria/controllers/forgot_password.dart';
// import 'package:jambomama_nigeria/controllers/notifications.dart';
// import 'package:jambomama_nigeria/midwives/views/components/drop_down_button.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SettingsScreen extends StatefulWidget {
//   final String email;
//   final String address;
//   final String fullName;
//   final String cityValue;
//   final String stateValue;
//   final String villageTown;
//   final String hospital;

//   const SettingsScreen({
//     Key? key,
//     required this.email,
//     required this.address,
//     required this.fullName,
//     required this.cityValue,
//     required this.stateValue,
//     required this.villageTown,
//     required this.hospital,
//   }) : super(key: key);

//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool receiveNotifications = true;
//   bool isLoading = false;
//   bool isSavingNotifications = false;

//   // Mutable state - stored in State class
//   late String fullName;
//   late String hospital;
//   late String stateValue;
//   late String cityValue;
//   late String villageTown;
//   late String address;

//   User? user = FirebaseAuth.instance.currentUser;
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController hospitalController = TextEditingController();
//   final TextEditingController stateController = TextEditingController();
//   final TextEditingController cityController = TextEditingController();
//   final TextEditingController townController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     // Initialize mutable state from widget properties
//     fullName = widget.fullName;
//     hospital = widget.hospital;
//     stateValue = widget.stateValue;
//     cityValue = widget.cityValue;
//     villageTown = widget.villageTown;

//     _loadSettings();

//     // Initialize controllers with current data
//     fullNameController.text = fullName;
//     hospitalController.text = hospital;
//     stateController.text = stateValue;
//     cityController.text = cityValue;
//     townController.text = villageTown;
//   }

//   @override
//   void dispose() {
//     fullNameController.dispose();
//     hospitalController.dispose();
//     stateController.dispose();
//     cityController.dispose();
//     townController.dispose();

//     super.dispose();
//   }

//   Future<bool> _saveProfileChanges() async {
//     if (user == null) {
//       _showErrorSnackBar("No user is signed in");
//       return false;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Update data in Firestore - Health Professionals collection
//       await FirebaseFirestore.instance
//           .collection('Health Professionals')
//           .doc(user!.uid)
//           .update({
//         'fullName': fullNameController.text,
//         'healthFacility': hospitalController.text,
//         'stateValue': stateController.text,
//         'cityValue': cityController.text,
//         'villageTown': townController.text,
//       });

//       // Only update local state after successful Firestore update
//       if (mounted) {
//         setState(() {
//           fullName = fullNameController.text;
//           hospital = hospitalController.text;
//           stateValue = stateController.text;
//           cityValue = cityController.text;
//           villageTown = townController.text;

//           isLoading = false;
//         });
//       }

//       _showSuccessSnackBar("Profile updated successfully");
//       return true;
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       _showErrorSnackBar("Error updating profile: ${e.toString()}");
//       return false;
//     }
//   }

//   Future<void> _toggleNotifications(bool value) async {
//     if (user == null) {
//       _showErrorSnackBar("No user is signed in");
//       return;
//     }

//     // Store the previous value in case we need to revert
//     final previousValue = receiveNotifications;

//     setState(() {
//       receiveNotifications = value;
//       isSavingNotifications = true;
//     });

//     try {
//       String userId = user!.uid;

//       // Save to Firestore - notification settings
//       await FirebaseFirestore.instance
//           .collection('user_notification_settings')
//           .doc(userId)
//           .set({'receiveNotifications': value}, SetOptions(merge: true));

//       // Save to SharedPreferences
//       final SharedPreferences sharedPreferences =
//           await SharedPreferences.getInstance();
//       await sharedPreferences.setBool("disabled_notification_key", !value);

//       // Get current FCM token
//       String fcmToken = "";
//       if (value) {
//         fcmToken = NotificationService.instance.userFcmToken ?? "";
//         if (fcmToken.isEmpty) {
//           throw Exception("FCM token not available");
//         }
//       }

//       // Update FCM token in Health Professionals collection
//       await FirebaseFirestore.instance
//           .collection('Health Professionals')
//           .doc(userId)
//           .update({
//         'fcmToken': fcmToken,
//       });

//       if (mounted) {
//         setState(() {
//           isSavingNotifications = false;
//         });
//       }

//       _showSuccessSnackBar(
//         value
//             ? "Notifications enabled successfully"
//             : "Notifications disabled successfully",
//       );
//     } catch (e) {
//       // Revert the toggle if save failed
//       if (mounted) {
//         setState(() {
//           receiveNotifications = previousValue;
//           isSavingNotifications = false;
//         });
//       }
//       _showErrorSnackBar(
//           "Failed to update notification settings: ${e.toString()}");
//     }
//   }

//   Future<void> _loadSettings() async {
//     if (user == null) {
//       return;
//     }

//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('user_notification_settings')
//           .doc(user!.uid)
//           .get();

//       if (snapshot.exists && mounted) {
//         setState(() {
//           receiveNotifications = snapshot['receiveNotifications'] ?? true;
//         });
//       }
//     } catch (e) {
//       print("Error loading settings: $e");
//     }
//   }

//   void _showSuccessSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showEditProfileModal(BuildContext context) {
//     // Reset controllers to current state values
//     fullNameController.text = fullName;
//     hospitalController.text = hospital;
//     stateController.text = stateValue;
//     cityController.text = cityValue;
//     townController.text = villageTown;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 left: 16,
//                 right: 16,
//                 top: 16,
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     AutoText('EDIT_PROFILE',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 16),
//                     _buildTextField(
//                       label: autoI8lnGen.translate("FULL_NAME"),
//                       controller: fullNameController,
//                     ),
//                     _buildTextField(
//                       label: autoI8lnGen.translate("HOSPITAL"),
//                       controller: hospitalController,
//                     ),
//                     _buildTextField(
//                       label: autoI8lnGen.translate("STATE"),
//                       controller: stateController,
//                     ),
//                     _buildTextField(
//                       label: autoI8lnGen.translate("CITY"),
//                       controller: cityController,
//                     ),
//                     _buildTextField(
//                       label: autoI8lnGen.translate("TOWN"),
//                       controller: townController,
//                     ),
//                     SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () async {
//                                 final success = await _saveProfileChanges();
//                                 if (success && mounted) {
//                                   await Future.delayed(
//                                       Duration(milliseconds: 100));
//                                   Navigator.pop(context);
//                                 }
//                               },
//                         child: isLoading
//                             ? SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               )
//                             : AutoText('SAVE_CHANGES'),
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: TextField(
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         controller: controller,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('SETTINGS'),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           _buildProfileSection(context),
//           SizedBox(height: 20),
//           _buildNotificationSettings(),
//           SizedBox(height: 20),
//           _buildPrivacySecuritySection(),
//           SizedBox(height: 20),
//           Center(
//             child:
//                 AutoText('VERSION 1.0.0', style: TextStyle(color: Colors.grey)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileSection(BuildContext context) => Card(
//         elevation: 2,
//         child: ListTile(
//           title: Text(fullName, style: TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Text(widget.email),
//           trailing: TextButton(
//             onPressed: () => _showEditProfileModal(context),
//             child: AutoText('EDIT_PROFILE'),
//           ),
//         ),
//       );

//   Widget _buildNotificationSettings() => Card(
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: AutoText('NOTIFICATIONS',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//               SwitchListTile(
//                 value: receiveNotifications,
//                 onChanged: isSavingNotifications ? null : _toggleNotifications,
//                 title: Row(
//                   children: [
//                     Expanded(child: AutoText('RECEIVE_NOTIFICATIONS')),
//                     if (isSavingNotifications)
//                       SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                   ],
//                 ),
//               ),
//               DropDownButton(),
//             ],
//           ),
//         ),
//       );

//   Widget _buildPrivacySecuritySection() => Card(
//         elevation: 2,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: AutoText('PRIVACY&SECURITY',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: Icon(Icons.lock_outline),
//               title: AutoText('CHANGE_PASSWORD'),
//               trailing: Icon(Icons.chevron_right),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ForgotPasswordScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       );
// }




