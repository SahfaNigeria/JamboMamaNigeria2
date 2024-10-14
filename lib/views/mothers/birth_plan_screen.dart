import 'package:flutter/material.dart';

class BirthPlanScreen extends StatefulWidget {
  @override
  _BirthPlanScreenState createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  // State variables
  String selectedTransport = '';
  String bloodType = '';
  String visitPlan = '';
  String selectedFacilityType = '';
  String chosenHealthFacility = '';
  String healthFacilityPhoneNumber = '';
  String bloodDonorName = '';
  String bloodDonorRelationship = '';
  String bloodDonorPhoneNumber = '';
  String caretakerName = '';
  String caretakerRelationship = '';
  String caretakerPhoneNumber = '';

  bool moneyForTransport = false;
  bool prescribedMedication = false;
  bool gloves = false;
  bool eyeDrops = false;
  bool clothes = false;
  bool soap = false;
  bool drink = false;
  bool food = false;
  bool washBasin = false;

  Widget buildSelectableOption(String label, IconData icon, Color color,
      Function() onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : color,
            width: 2,
          ),
          color: isSelected ? Colors.black : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveForm() {
    // Collect all form data and process it
    print('Transport: $selectedTransport');
    print('Health Facility: $chosenHealthFacility');
    print('Blood Donor: $bloodDonorName');
    // ... collect other inputs here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Birth Plan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Where will you go to give birth?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSelectableOption(
                    'Hospital', Icons.local_hospital, Colors.green, () {
                  setState(() {
                    selectedFacilityType = 'Hospital';
                  });
                }, selectedFacilityType == 'Hospital'),
                buildSelectableOption(
                    'Health Centre', Icons.health_and_safety, Colors.red, () {
                  setState(() {
                    selectedFacilityType = 'Health Centre';
                  });
                }, selectedFacilityType == 'Health Centre'),
                buildSelectableOption(
                    'Dispensary', Icons.local_pharmacy, Colors.blue, () {
                  setState(() {
                    selectedFacilityType = 'Dispensary';
                  });
                }, selectedFacilityType == 'Dispensary'),
              ],
            ),

            SizedBox(height: 20),
            Visibility(
              visible: selectedFacilityType
                  .isNotEmpty, // Show when a type is selected
              child: Column(
                children: [
                  SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Name of chosen health facility',
                      labelStyle: TextStyle(fontSize: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        chosenHealthFacility = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Telephone Number',
                      labelStyle: TextStyle(fontSize: 14),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        healthFacilityPhoneNumber = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            // Transport Options
            Text(
              'Transport Options',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSelectableOption(
                    'On foot', Icons.directions_walk, Colors.green, () {
                  setState(() {
                    selectedTransport = 'foot';
                  });
                }, selectedTransport == 'foot'),
                buildSelectableOption(
                    'By bike', Icons.directions_bike, Colors.blue, () {
                  setState(() {
                    selectedTransport = 'bike';
                  });
                }, selectedTransport == 'bike'),
                buildSelectableOption(
                    'Motorbike', Icons.motorcycle, Colors.orange, () {
                  setState(() {
                    selectedTransport = 'motorbike';
                  });
                }, selectedTransport == 'motorbike'),
                buildSelectableOption(
                    'Car', Icons.directions_car, Colors.purple, () {
                  setState(() {
                    selectedTransport = 'car';
                  });
                }, selectedTransport == 'car'),
                buildSelectableOption(
                    'Boat', Icons.directions_boat, Colors.teal, () {
                  setState(() {
                    selectedTransport = 'boat';
                  });
                }, selectedTransport == 'boat'),
              ],
            ),
            SizedBox(height: 20),

            // Blood donation section
            Text(
              'Who can give blood in case you need it?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        bloodDonorName = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      labelStyle: TextStyle(fontSize: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        bloodDonorRelationship = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Telephone Number',
                labelStyle: TextStyle(fontSize: 14),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  bloodDonorPhoneNumber = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Checkbox section
            Text(
              'Things to bring to the health facility:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title:
                  Text('Money for transport', style: TextStyle(fontSize: 14)),
              value: moneyForTransport,
              onChanged: (value) {
                setState(() {
                  moneyForTransport = value!;
                });
              },
            ),
            CheckboxListTile(
              title:
                  Text('Prescribed medication', style: TextStyle(fontSize: 14)),
              value: prescribedMedication,
              onChanged: (value) {
                setState(() {
                  prescribedMedication = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Gloves', style: TextStyle(fontSize: 14)),
              value: gloves,
              onChanged: (value) {
                setState(() {
                  gloves = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Eye Drops', style: TextStyle(fontSize: 14)),
              value: eyeDrops,
              onChanged: (value) {
                setState(() {
                  eyeDrops = value!;
                });
              },
            ),
            CheckboxListTile(
              title:
                  Text('Clothes for yourself', style: TextStyle(fontSize: 14)),
              value: clothes,
              onChanged: (value) {
                setState(() {
                  clothes = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Soap', style: TextStyle(fontSize: 14)),
              value: soap,
              onChanged: (value) {
                setState(() {
                  soap = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Drink', style: TextStyle(fontSize: 14)),
              value: drink,
              onChanged: (value) {
                setState(() {
                  drink = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Food', style: TextStyle(fontSize: 14)),
              value: food,
              onChanged: (value) {
                setState(() {
                  food = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Wash Basin', style: TextStyle(fontSize: 14)),
              value: washBasin,
              onChanged: (value) {
                setState(() {
                  washBasin = value!;
                });
              },
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveForm,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
