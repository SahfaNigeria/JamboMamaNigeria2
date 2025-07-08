import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/controllers/forgot_password.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';

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
          .collection('users')
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
                Text('Edit Profile',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Full Name',
                  controller: fullNameController,
                ),
                _buildTextField(
                  label: 'Hospital',
                  controller: hospitalController,
                ),
                _buildTextField(
                  label: 'State',
                  controller: stateController,
                ),
                _buildTextField(
                  label: 'City',
                  controller: cityController,
                ),
                _buildTextField(
                  label: 'Town',
                  controller: townController,
                ),
                _buildTextField(
                  label: 'Address',
                  controller: addressController,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _saveProfileChanges();
                    Navigator.pop(context); // Close the modal
                  },
                  child: Text('Save Changes'),
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
        title: Text('Settings'),
        actions: [IconButton(icon: Icon(Icons.help_outline), onPressed: () {})],
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
          _buildHealthFacilitySection(),
          SizedBox(height: 20),
          _buildSupportLegalSection(),
          SizedBox(height: 20),
          Center(
              child:
                  Text('Version 1.0.0', style: TextStyle(color: Colors.grey))),
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
          child: Text('Edit Profile'),
        ),
      );

  Widget _buildNotificationSettings() => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SwitchListTile(
                value: receiveNotifications,
                onChanged: _toggleNotifications,
                title: Text('Receive Notifications'),
              ),
              // SwitchListTile(
              //   value: true,
              //   onChanged: (val) {},
              //   title: Text('Health Check Reminders'),
              // ),
              SwitchListTile(
                value: false,
                onChanged: (val) {},
                title: Text('Appointment Reminders'),
              ),
            ],
          ),
        ),
      );

  Widget _buildPrivacySecuritySection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy & Security',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              }),
          // ListTile(title: Text('Enable Biometric Login'), onTap: () {}),
          // ListTile(title: Text('Logout from All Devices'), onTap: () {}),
        ],
      );

  Widget _buildHealthFacilitySection() => ListTile(
        title: Text('Health Facility Preferences'),
        subtitle: Text('Level 2 - [Saved Facilities]'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {},
      );

  Widget _buildSupportLegalSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support & Legal',
              style: TextStyle(fontWeight: FontWeight.bold)),
          // ListTile(title: Text('FAQs'), onTap: () {}),
          ListTile(title: Text('Contact Support'), onTap: () {}),
          // ListTile(title: Text('Terms & Conditions'), onTap: () {}),
          // ListTile(title: Text('Privacy Policy'), onTap: () {}),
        ],
      );
}
