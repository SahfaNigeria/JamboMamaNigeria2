import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalsScreen extends StatelessWidget {
  // Firestore query to get only approved hospitals
  Stream<QuerySnapshot> _getApprovedHospitals() {
    return FirebaseFirestore.instance
        .collection('health_facilities')
        .where('approved', isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('HEALTH_FACILITIES'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getApprovedHospitals(),
              builder: (context, snapshot) {
                // If the data is still loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // If there are no hospitals approved yet
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: AutoText('NO_HEALTH_FACILITIES'));
                }

                // Display the list of approved hospitals
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var hospitalData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: AutoText(hospitalData['name'] ?? 'ERROR_6'),
                        subtitle: AutoText(hospitalData['location']['address'] ??
                            'ERROR_7'),
                        trailing: AutoText(
                            'LEVEL_COLUMN ${hospitalData['level'] ?? 'Unknown'}'),
                        onTap: () {
                          // Optional: Show more hospital details
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(hospitalData['name']),
                                content: AutoText(
                                  "ADDRESS ${hospitalData['location']['address']}\n"
                                  "SERVICES ${hospitalData['services']}\n"
                                  "PHONE ${hospitalData['contact']['phone']} ",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: AutoText('CLOSE'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AutoText(
              "DIDNT_SEE_YOUR_HOSPITAL",
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          )
        ],
      ),

      // Floating Action Button to add a hospital
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to hospital input form
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddHospitalFormScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: autoI8lnGen.translate("ADD_HOSPITAL"),
      ),
    );
  }
}

class AddHospitalFormScreen extends StatefulWidget {
  @override
  _AddHospitalFormScreenState createState() => _AddHospitalFormScreenState();
}

class _AddHospitalFormScreenState extends State<AddHospitalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phone = '';
  String services = '';
  int level = 1; // Default to level 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('ADD_HOSPITAL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: autoI8lnGen.translate("HOSPITAL_NAME")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return autoI8lnGen.translate("VALIDATION_Q_15");
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: autoI8lnGen.translate("Address")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return autoI8lnGen.translate("VALIDATION_Q_16");
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: autoI8lnGen.translate("PHONE")),
                onSaved: (value) {
                  phone = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: autoI8lnGen.translate("SERVICES_INCLUDED")),
                onSaved: (value) {
                  services = value!;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: autoI8lnGen.translate("LEVEL_COLUMN")),
                value: level,
                items: [
                  DropdownMenuItem(value: 1, child: AutoText('L_1')),
                  DropdownMenuItem(value: 2, child: AutoText('L_2')),
                  DropdownMenuItem(value: 3, child: AutoText('L_3')),
                ],
                onChanged: (value) {
                  setState(() {
                    level = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Save hospital details to Firestore
                    FirebaseFirestore.instance
                        .collection('health_facilities')
                        .add({
                      'name': name,
                      'location': {
                        'address': address,
                      },
                      'contact': {
                        'phone': phone,
                        'services': services,
                      },
                      'level': level,
                      'approved': false, // Mark as unapproved initially
                    });
                    Navigator.pop(context);
                  }
                },
                child: AutoText('SUBMIT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
