import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/controllers/forgot_password.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';
import 'package:jambomama_nigeria/midwives/views/components/drop_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  String email;
  String address;
  String userName;
  String cityValue;
  String stateValue;
  String villageTown;
  String hospital;

  SettingsScreen({
    Key? key,
    required this.email,
    required this.address,
    required this.userName,
    required this.cityValue,
    required this.stateValue,
    required this.villageTown,
    required this.hospital,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool receiveNotifications = true;

  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize controllers with passed data
    fullNameController.text = widget.userName;
    hospitalController.text = widget.hospital;
    stateController.text = widget.stateValue;
    cityController.text = widget.cityValue;
    townController.text = widget.villageTown;
    addressController.text = widget.address;
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    fullNameController.dispose();
    hospitalController.dispose();
    stateController.dispose();
    cityController.dispose();
    townController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    if (user == null) {
      print("No user is signed in");
      return;
    }

    try {
      // Update data in Firestore
      await FirebaseFirestore.instance
          .collection('Health Professionals')
          .doc(user!.uid)
          .update({
        'userName': fullNameController.text,
        'hospital': hospitalController.text,
        'stateValue': stateController.text,
        'cityValue': cityController.text,
        'villageTown': townController.text,
        'address': addressController.text,
      });

      setState(() {
        // Update UI with new values
        widget.userName = fullNameController.text;
        widget.hospital = hospitalController.text;
        widget.stateValue = stateController.text;
        widget.cityValue = cityController.text;
        widget.villageTown = townController.text;
        widget.address = addressController.text;
      });

      print("Profile updated successfully");
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  void _toggleNotifications(bool value) async {
    if (user == null) {
      print("No user is signed in");
      return;
    }
    if (user != null) {
      String userId = user!.uid; // The unique user ID

      setState(() {
        receiveNotifications = value;
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(userId)
          .set({'receiveNotifications': value}, SetOptions(merge: true));
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setBool(
        "disabled_notification_key",
        value,
      );
      if (value == false) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'fcmToken': "",
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'fcmToken': NotificationService.instance.userFcmToken,
        });
      }
    } else {
      // Handle the case where the user is not signed in
      print("No user is signed in");
    }
  }

  void _loadSettings() async {
    if (user == null) {
      print("No user is signed in");
      return;
    }
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_notification_settings')
        .doc(user!.uid)
        .get();

    if (snapshot.exists) {
      setState(() {
        receiveNotifications = snapshot['receiveNotifications'] ?? true;
      });
    }
  }

  void _showEditProfileModal(BuildContext context) {
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
                  controller: fullNameController,
                ),
                _buildTextField(
                  label: autoI8lnGen.translate("HOSPITAL"),
                  controller: hospitalController,
                ),
                _buildTextField(
                  label: autoI8lnGen.translate("STATE"),
                  controller: stateController,
                ),
                _buildTextField(
                  label: autoI8lnGen.translate("CITY"),
                  controller: cityController,
                ),
                _buildTextField(
                  label: autoI8lnGen.translate("TOWN"),
                  controller: townController,
                ),
                _buildTextField(
                  label: autoI8lnGen.translate("Address"),
                  controller: addressController,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _saveProfileChanges();
                    Navigator.pop(context); // Close the modal
                  },
                  child: AutoText('SAVE_CHANGES'),
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
    return TextField(
      decoration: InputDecoration(labelText: label),
      controller: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('SETTINGS'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildProfileSection(context),
          SizedBox(height: 20),
          _buildNotificationSettings(),
          SizedBox(height: 20),
          SizedBox(height: 20),
          _buildPrivacySecuritySection(),
          SizedBox(height: 20),
          // _buildHealthFacilitySection(),
          // SizedBox(height: 20),
          // _buildSupportLegalSection(),
          // SizedBox(height: 20),
          Center(
              child: AutoText('VERSION 1.0.0',
                  style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) => ListTile(
        title: Text(widget.userName,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(widget.email),
        trailing: TextButton(
          onPressed: () => _showEditProfileModal(context),
          child: AutoText('EDIT_PROFILE'),
        ),
      );

  Widget _buildNotificationSettings() => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoText('NOTIFICATIONS',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SwitchListTile(
                value: receiveNotifications,
                onChanged: _toggleNotifications,
                title: AutoText('RECEIVE_NOTIFICATIONS'),
              ),
              DropDownButton(),
            ],
          ),
        ),
      );

  Widget _buildPrivacySecuritySection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText('PRIVACY&SECURITY',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
              title: AutoText('CHANGE_PASSWORD'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              }),
        ],
      );

  // Widget _buildSupportLegalSection() => Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         AutoText('SUPPORT_LEGAL',
  //             style: TextStyle(fontWeight: FontWeight.bold)),
  //         // ListTile(title: Text('FAQs'), onTap: () {}),
  //         ListTile(title: AutoText('CONTACT_SUPPORT'), onTap: () {}),
  //         // ListTile(title: Text('Terms & Conditions'), onTap: () {}),
  //         // ListTile(title: Text('Privacy Policy'), onTap: () {}),
  //       ],
  //     );
}
