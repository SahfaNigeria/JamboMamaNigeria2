import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/controllers/forgot_password.dart';
import 'package:jambomama_nigeria/midwives/views/components/drop_down_button.dart';
import 'package:jambomama_nigeria/midwives/views/screens/edit_edd.dart';

class SettingsScreen extends StatefulWidget {
  final String email;
  final String address;
  final String userName;
  final String cityValue;
  final String stateValue;
  final String villageTown;
  final String hospital;

  const SettingsScreen({
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
  bool isLoading = false;

  // Mutable state - stored in State class
  late String userName;
  late String hospital;
  late String stateValue;
  late String cityValue;
  late String villageTown;
  late String address;

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

    // Initialize mutable state from widget properties
    userName = widget.userName;
    hospital = widget.hospital;
    stateValue = widget.stateValue;
    cityValue = widget.cityValue;
    villageTown = widget.villageTown;
    address = widget.address;

    _loadSettings();

    // Initialize controllers with current data
    fullNameController.text = userName;
    hospitalController.text = hospital;
    stateController.text = stateValue;
    cityController.text = cityValue;
    townController.text = villageTown;
    addressController.text = address;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    hospitalController.dispose();
    stateController.dispose();
    cityController.dispose();
    townController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<bool> _saveProfileChanges() async {
    if (user == null) {
      _showErrorSnackBar("No user is signed in");
      return false;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update data in Firestore
      await FirebaseFirestore.instance
          .collection('New Mothers')
          .doc(user!.uid)
          .update({
        'full name': fullNameController.text,
        'hospital': hospitalController.text,
        'stateValue': stateController.text,
        'cityValue': cityController.text,
        'villageTown': townController.text,
        'address': addressController.text,
      });

      // Only update local state after successful Firestore update
      if (mounted) {
        setState(() {
          // Update local state with new values
          userName = fullNameController.text;
          hospital = hospitalController.text;
          stateValue = stateController.text;
          cityValue = cityController.text;
          villageTown = townController.text;
          address = addressController.text;
          isLoading = false;
        });
      }

      _showSuccessSnackBar("Profile updated successfully");
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showErrorSnackBar("Error updating profile: ${e.toString()}");
      return false;
    }
  }

  void _toggleNotifications(bool value) async {
    if (user == null) {
      _showErrorSnackBar("No user is signed in");
      return;
    }

    setState(() {
      receiveNotifications = value;
    });

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(user!.uid)
          .set({'receiveNotifications': value}, SetOptions(merge: true));

      _showSuccessSnackBar("Notification settings updated");
    } catch (e) {
      // Revert the toggle if save failed
      setState(() {
        receiveNotifications = !value;
      });
      _showErrorSnackBar("Failed to update notification settings");
    }
  }

  Future<void> _loadSettings() async {
    if (user == null) {
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_notification_settings')
          .doc(user!.uid)
          .get();

      if (snapshot.exists && mounted) {
        setState(() {
          receiveNotifications = snapshot['receiveNotifications'] ?? true;
        });
      }
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context) {
    // Reset controllers to current state values
    fullNameController.text = userName;
    hospitalController.text = hospital;
    stateController.text = stateValue;
    cityController.text = cityValue;
    townController.text = villageTown;
    addressController.text = address;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final success = await _saveProfileChanges();
                                if (success && mounted) {
                                  // Wait a brief moment to ensure state is updated
                                  await Future.delayed(
                                      Duration(milliseconds: 100));
                                  Navigator.pop(context);
                                }
                              },
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        controller: controller,
      ),
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
          _buildPrivacySecuritySection(),
          SizedBox(height: 20),
          Center(
            child:
                AutoText('VERSION 1.0.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) => Card(
        elevation: 2,
        child: ListTile(
          title: Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(widget.email),
          trailing: TextButton(
            onPressed: () => _showEditProfileModal(context),
            child: AutoText('EDIT_PROFILE'),
          ),
        ),
      );

  Widget _buildNotificationSettings() => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoText('NOTIFICATIONS',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
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

  Widget _buildPrivacySecuritySection() => Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.calendar_today_outlined),
              title: AutoText('Edit Expected Delivery Date'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditExpectedDeliveryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );
}
