import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
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
          _buildProfileSection(),
          Divider(),
          _buildNotificationSettings(),
          Divider(),
          _buildLanguageRegionSection(),
          Divider(),
          _buildPrivacySecuritySection(),
          Divider(),
          _buildHealthFacilitySection(),
          Divider(),
          _buildSupportLegalSection(),
          SizedBox(height: 20),
          Center(
              child:
                  Text('Version 1.0.0', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildProfileSection() => ListTile(
        leading: CircleAvatar(
            radius: 30, backgroundImage: AssetImage('assets/avatar.png')),
        title: Text('Laetitia Van Haren'),
        subtitle: Text('contact@sahfa.org'),
        trailing: TextButton(onPressed: () {}, child: Text('Edit Profile')),
      );

  Widget _buildNotificationSettings() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
              value: true,
              onChanged: (val) {},
              title: Text('Receive Notifications')),
          SwitchListTile(
              value: true,
              onChanged: (val) {},
              title: Text('Health Check Reminders')),
          SwitchListTile(
              value: false,
              onChanged: (val) {},
              title: Text('Appointment Reminders')),
        ],
      );

  Widget _buildLanguageRegionSection() => ListTile(
        title: Text('Language & Region'),
        subtitle: Text('English - West Africa'),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {},
      );

  Widget _buildPrivacySecuritySection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy & Security',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(title: Text('Change Password'), onTap: () {}),
          ListTile(title: Text('Enable Biometric Login'), onTap: () {}),
          ListTile(title: Text('Logout from All Devices'), onTap: () {}),
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
          ListTile(title: Text('FAQs'), onTap: () {}),
          ListTile(title: Text('Contact Support'), onTap: () {}),
          ListTile(title: Text('Terms & Conditions'), onTap: () {}),
          ListTile(title: Text('Privacy Policy'), onTap: () {}),
        ],
      );
}
