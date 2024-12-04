import 'package:flutter/material.dart';

class BirthPlanScreen extends StatefulWidget {
  @override
  _BirthPlanScreenState createState() => _BirthPlanScreenState();
}

class _BirthPlanScreenState extends State<BirthPlanScreen> {
  // State variables
  String selectedTransport = '';
  String selectedTransportReturn = '';

  String bloodType = '';
  String bloodGroup = '';
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
  String? selectedHealthProvider;
  String? accompanyingPerson;
  bool? willStayAfterBirth;
  String? chosenReturnMethod;
  String? _selectedTimeOption;

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

            SizedBox(height: 10),
            Visibility(
              visible: selectedFacilityType
                  .isNotEmpty, // Show when a type is selected
              child: Column(
                children: [
                  SizedBox(height: 10),
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
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('What is his/her blood group? ',
                      style: TextStyle(fontSize: 14)),
                  DropdownButton<String>(
                    value: bloodGroup.isEmpty ? null : bloodGroup,
                    items: <String>['O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        bloodGroup = value ?? '';
                      });
                    },
                    hint: Text(
                      'Select Blood Group',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            // 3. How long does the trip take?
            Text("How long does that trip take?",
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            Row(
              children: [
                _buildTripTimeOption("< 1 hour"),
                SizedBox(width: 10),
                _buildTripTimeOption("1-2 hours"),
                SizedBox(width: 10),
                _buildTripTimeOption("Over 2 hours"),
              ],
            ),

            SizedBox(height: 20),
            // 4. Who will come with you?
            Text("Who will come with you?", style: TextStyle(fontSize: 14)),
            TextFormField(
              decoration: InputDecoration(labelText: "Relationship"),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Telephone"),
            ),
            SizedBox(height: 10),
            Text("Will they stay with you until after birth?",
                style: TextStyle(fontSize: 14)),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: willStayAfterBirth,
                  onChanged: (bool? value) {
                    setState(() {
                      willStayAfterBirth =
                          value; // Update the state with selected value
                    });
                  },
                ),
                Text("Yes"),
                Radio<bool>(
                  value: false,
                  groupValue: willStayAfterBirth,
                  onChanged: (bool? value) {
                    setState(() {
                      willStayAfterBirth =
                          value; // Update the state with selected value
                    });
                  },
                ),
                Text("No"),
                Radio<bool?>(
                  value: null,
                  groupValue: willStayAfterBirth,
                  onChanged: (bool? value) {
                    setState(() {
                      willStayAfterBirth =
                          value; // Update the state with selected value
                    });
                  },
                ),
                Text("Don't know"),
              ],
            ),

            SizedBox(height: 10),
            // 6. Which health provider will assist at the birth?
            Text("Which health provider will assist at the birth?",
                style: TextStyle(fontSize: 14)),
            Row(
              children: [
                _buildHealthProviderOption("Nurse"),
                _buildHealthProviderOption("Midwife"),
                _buildHealthProviderOption("Doctor"),
              ],
            ),
            if (selectedHealthProvider != null) ...[
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Telephone"),
              ),
            ],

            SizedBox(height: 20),
            // 7. Who will take you home?
            Text("Who will take you home?", style: TextStyle(fontSize: 14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReturnHomeOption("Husband"),
                _buildReturnHomeOption("Relative"),
                _buildReturnHomeOption("Friend"),
                _buildReturnHomeOption("Myself"),
              ],
            ),
            if (chosenReturnMethod == "Myself") ...[
              Text(
                  "Name and contact details of taxi driver or trusted person:"),
              TextFormField(
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Telephone"),
              ),
            ],

            SizedBox(height: 20),
            // 8. How do you return home after the birth?
            Text("How do you return home after the birth?",
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSelectableOption(
                    'On foot', Icons.directions_walk, Colors.green, () {
                  setState(() {
                    selectedTransportReturn = 'foot';
                  });
                }, selectedTransportReturn == 'foot'),
                buildSelectableOption(
                    'By bike', Icons.directions_bike, Colors.blue, () {
                  setState(() {
                    selectedTransportReturn = 'bike';
                  });
                }, selectedTransportReturn == 'bike'),
                buildSelectableOption(
                    'Motorbike', Icons.motorcycle, Colors.orange, () {
                  setState(() {
                    selectedTransportReturn = 'motorbike';
                  });
                }, selectedTransportReturn == 'motorbike'),
                buildSelectableOption(
                    'Car', Icons.directions_car, Colors.purple, () {
                  setState(() {
                    selectedTransportReturn = 'car';
                  });
                }, selectedTransportReturn == 'car'),
                buildSelectableOption(
                    'Boat', Icons.directions_boat, Colors.teal, () {
                  setState(() {
                    selectedTransportReturn = 'boat';
                  });
                }, selectedTransportReturn == 'boat'),
              ],
            ),
            SizedBox(height: 10),
            if (chosenReturnMethod != null)
              Text("If you have to pay for transport, start saving now!"),

            SizedBox(height: 20),
            // 10. Visit the health facility beforehand
            Text(
              'When are you planning to visit the health facility?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  'This week',
                  'This month',
                  'Next month',
                  'Don’t know'
                ].map((visitOption) {
                  return ChoiceChip(
                    label: Text(visitOption, style: TextStyle(fontSize: 14)),
                    selected: visitPlan == visitOption,
                    onSelected: (selected) {
                      setState(() {
                        visitPlan = visitOption;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // 11. Who will look after your children?

            Text(
              'Who will look after your children?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Relationship',
                labelStyle: TextStyle(fontSize: 14),
              ),
              onChanged: (value) {
                setState(() {
                  caretakerRelationship = value;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: 14),
              ),
              onChanged: (value) {
                setState(() {
                  caretakerName = value;
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
                  caretakerPhoneNumber = value;
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

  Widget _buildTransportOption(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTransport = label;
        });
      },
      child: Column(
        children: [
          Icon(icon, color: selectedTransport == label ? color : Colors.black),
          Text(label,
              style: TextStyle(
                  color: selectedTransport == label ? color : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildTripTimeOption(String label) {
    bool isSelected = _selectedTimeOption == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeOption = label; // Update selected option
          });
        },
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthProviderOption(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHealthProvider = label;
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        child: Row(
          children: [
            Icon(
              selectedHealthProvider == label
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.green,
            ),
            SizedBox(width: 5),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnHomeOption(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          chosenReturnMethod = label;
        });
      },
      child: Column(
        children: [
          Icon(
            chosenReturnMethod == label
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: Colors.purple,
          ),
          Text(label),
        ],
      ),
    );
  }
}
