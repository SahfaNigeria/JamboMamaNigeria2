import 'package:auto_i8ln/auto_i8ln.dart';
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
            AutoText(
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
      appBar: AppBar(title: AutoText('BIRTHDAY_PLAN')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            AutoText(
              'WHERE_WILL_YOU_GIVE_BIRTH',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSelectableOption(
                    'HOSPITAL', Icons.local_hospital, Colors.green, () {
                  setState(() {
                    selectedFacilityType = autoI8lnGen.translate("HOSPITAL");
                  });
                }, selectedFacilityType == autoI8lnGen.translate("HOSPITAL")),
                buildSelectableOption(
                    'HEALTH_CENTER', Icons.health_and_safety, Colors.red, () {
                  setState(() {
                    selectedFacilityType =
                        autoI8lnGen.translate("HEALTH_CENTER");
                  });
                },
                    selectedFacilityType ==
                        autoI8lnGen.translate("HEALTH_CENTER")),
                buildSelectableOption(
                    'DISPENSARY', Icons.local_pharmacy, Colors.blue, () {
                  setState(() {
                    selectedFacilityType = autoI8lnGen.translate("DISPENSARY");
                  });
                }, selectedFacilityType == autoI8lnGen.translate("DISPENSARY")),
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
                      labelText: autoI8lnGen
                          .translate("NAME_OF_CHOSEN_HEALTH_FACILITY"),
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
                      labelText: autoI8lnGen.translate("TELEPHONE_NUMBER"),
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
            AutoText(
              'TRANSPORT_OPTIONS',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSelectableOption(
                    'ON_FOOT', Icons.directions_walk, Colors.green, () {
                  setState(() {
                    selectedTransport = autoI8lnGen.translate("FOOT");
                  });
                }, selectedTransport == autoI8lnGen.translate("FOOT")),
                buildSelectableOption(
                    'BYBIKE', Icons.directions_bike, Colors.blue, () {
                  setState(() {
                    selectedTransport = autoI8lnGen.translate("BIKE");
                  });
                }, selectedTransport == autoI8lnGen.translate("BIKE")),
                buildSelectableOption(
                    'MOTOR_BIKE', Icons.motorcycle, Colors.orange, () {
                  setState(() {
                    selectedTransport = autoI8lnGen.translate("MOTOR_BIKE");
                  });
                }, selectedTransport == autoI8lnGen.translate("MOTOR_BIKE")),
                buildSelectableOption(
                    'CAR_1', Icons.directions_car, Colors.purple, () {
                  setState(() {
                    selectedTransport = autoI8lnGen.translate("CAR_2");
                  });
                }, selectedTransport == autoI8lnGen.translate("CAR_2")),
                buildSelectableOption(
                    'BOAT_1', Icons.directions_boat, Colors.teal, () {
                  setState(() {
                    selectedTransport = autoI8lnGen.translate("BOAT_2");
                  });
                }, selectedTransport == autoI8lnGen.translate("BOAT_2")),
              ],
            ),
            SizedBox(height: 20),

            // Blood donation section
            AutoText(
              'GIVE_BLOOD',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("NAME"),
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
                      labelText: autoI8lnGen.translate("RELATIONSHIP"),
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
                labelText: autoI8lnGen.translate("T_N"),
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
                  AutoText('WHAT_BLOOD_GROUP', style: TextStyle(fontSize: 14)),
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
                    hint: AutoText(
                      'SELECT_BLOOD_GROUP',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            // 3. How long does the trip take?
            AutoText("HOW_LONG_TRIP", style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            Row(
              children: [
                _buildTripTimeOption("LESS_1_H"),
                SizedBox(width: 10),
                _buildTripTimeOption("1_2_H"),
                SizedBox(width: 10),
                _buildTripTimeOption("O_2_H"),
              ],
            ),

            SizedBox(height: 20),
            // 4. Who will come with you?
            AutoText("WHO_WILL_COME_W", style: TextStyle(fontSize: 14)),
            TextFormField(
              decoration: InputDecoration(
                  labelText: autoI8lnGen.translate("RELATIONSHIP")),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: autoI8lnGen.translate("NAME")),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: autoI8lnGen.translate("T_N")),
            ),
            SizedBox(height: 10),
            AutoText("STAY_AFTER_BIRTH", style: TextStyle(fontSize: 14)),
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
                AutoText("YES_2"),
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
                AutoText("NO_2"),
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
                AutoText("DONT_KNOW"),
              ],
            ),

            SizedBox(height: 10),
            // 6. Which health provider will assist at the birth?
            AutoText("W_H_P", style: TextStyle(fontSize: 14)),
            Row(
              children: [
                _buildHealthProviderOption("NURSE"),
                _buildHealthProviderOption("MIDWIFE"),
                _buildHealthProviderOption("DOCTOR"),
              ],
            ),
            if (selectedHealthProvider != null) ...[
              TextFormField(
                decoration:
                    InputDecoration(labelText: autoI8lnGen.translate("NAME")),
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: autoI8lnGen.translate("T_N")),
              ),
            ],

            SizedBox(height: 20),
            // 7. Who will take you home?
            AutoText("W_W_H", style: TextStyle(fontSize: 14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildReturnHomeOption("HUSBAND"),
                _buildReturnHomeOption("RELATIVE"),
                _buildReturnHomeOption("FRIEND"),
                _buildReturnHomeOption("MYSEF"),
              ],
            ),
            if (chosenReturnMethod == autoI8lnGen.translate("MYSEF")) ...[
              AutoText("NAME_CONTACT_TAXI"),
              TextFormField(
                decoration:
                    InputDecoration(labelText: autoI8lnGen.translate("NAME")),
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: autoI8lnGen.translate("T_N")),
              ),
            ],

            SizedBox(height: 20),
            // 8. How do you return home after the birth?
            AutoText("R_HOME",
                style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildSelectableOption(
                    'ON_FOOT', Icons.directions_walk, Colors.green, () {
                  setState(() {
                    selectedTransportReturn = autoI8lnGen.translate("FOOT");
                  });
                }, selectedTransportReturn == autoI8lnGen.translate("FOOT")),
                buildSelectableOption(
                    'BYBIKE', Icons.directions_bike, Colors.blue, () {
                  setState(() {
                    selectedTransportReturn = autoI8lnGen.translate("BIKE");
                  });
                }, selectedTransportReturn == autoI8lnGen.translate("BIKE")),
                buildSelectableOption(
                    'MOTOR_BIKE', Icons.motorcycle, Colors.orange, () {
                  setState(() {
                    selectedTransportReturn =
                        autoI8lnGen.translate("MOTOR_BIKE");
                  });
                },
                    selectedTransportReturn ==
                        autoI8lnGen.translate("MOTOR_BIKE")),
                buildSelectableOption(
                    'CAR_1', Icons.directions_car, Colors.purple, () {
                  setState(() {
                    selectedTransportReturn = autoI8lnGen.translate("CAR_2");
                  });
                }, selectedTransportReturn == autoI8lnGen.translate("CAR_2")),
                buildSelectableOption(
                    'BOAT_1', Icons.directions_boat, Colors.teal, () {
                  setState(() {
                    selectedTransportReturn = autoI8lnGen.translate("BOAT_2");
                  });
                }, selectedTransportReturn == autoI8lnGen.translate("BOAT_2")),
              ],
            ),
            SizedBox(height: 10),
            if (chosenReturnMethod != null) AutoText("SAVE_TFARE"),

            SizedBox(height: 20),
            // 10. Visit the health facility beforehand
            AutoText(
              'PLANNING_VISIT_HEALTH_F',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  autoI8lnGen.translate("T_WEEK"),
                  autoI8lnGen.translate("T_MONTH"),
                  autoI8lnGen.translate("N_MONTH"),
                  autoI8lnGen.translate("DONT_KNOW"),
                ].map((visitOption) {
                  return ChoiceChip(
                    label: AutoText(visitOption, style: TextStyle(fontSize: 14)),
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

            AutoText(
              'LOOK_CHILDREN',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: autoI8lnGen.translate("RELATIONSHIP"),
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
                labelText: autoI8lnGen.translate("NAME"),
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
                labelText: autoI8lnGen.translate("T_N"),
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
            AutoText(
              'BRING_HEALTH_FACILITY',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title:
                  AutoText('MONEY_TFARE', style: TextStyle(fontSize: 14)),
              value: moneyForTransport,
              onChanged: (value) {
                setState(() {
                  moneyForTransport = value!;
                });
              },
            ),
            CheckboxListTile(
              title:
              AutoText('P_MEDICATION', style: TextStyle(fontSize: 14)),
              value: prescribedMedication,
              onChanged: (value) {
                setState(() {
                  prescribedMedication = value!;
                });
              },
            ),
            CheckboxListTile(
              title: AutoText('GLOVES', style: TextStyle(fontSize: 14)),
              value: gloves,
              onChanged: (value) {
                setState(() {
                  gloves = value!;
                });
              },
            ),
            CheckboxListTile(
              title: AutoText('EYE_DROPS', style: TextStyle(fontSize: 14)),
              value: eyeDrops,
              onChanged: (value) {
                setState(() {
                  eyeDrops = value!;
                });
              },
            ),
            CheckboxListTile(
              title:
                  AutoText('CLOTHES_UR', style: TextStyle(fontSize: 14)),
              value: clothes,
              onChanged: (value) {
                setState(() {
                  clothes = value!;
                });
              },
            ),
            CheckboxListTile(
              title: AutoText('SOAP', style: TextStyle(fontSize: 14)),
              value: soap,
              onChanged: (value) {
                setState(() {
                  soap = value!;
                });
              },
            ),
            CheckboxListTile(
              title: AutoText('DRINK', style: TextStyle(fontSize: 14)),
              value: drink,
              onChanged: (value) {
                setState(() {
                  drink = value!;
                });
              },
            ),
            CheckboxListTile(
              title: AutoText('FOOD', style: TextStyle(fontSize: 14)),
              value: food,
              onChanged: (value) {
                setState(() {
                  food = value!;
                });
              },
            ),
            CheckboxListTile(
              title: AutoText('WASH_BASIN', style: TextStyle(fontSize: 14)),
              value: washBasin,
              onChanged: (value) {
                setState(() {
                  washBasin = value!;
                });
              },
            ),

            // Add space at the bottom for the floating action button
            SizedBox(height: 80),
          ],
        ),
      ),
      // Add the floating action button here
      floatingActionButton: SizedBox(
        width: 200, // Make it wider
        height: 56, // Make it taller
        child: FloatingActionButton(
          onPressed: _saveForm,
          child: AutoText(
            'SAVE',
            style: TextStyle(fontSize: 16), // Larger text
          ),
        ),
      ),
      // Center the floating action button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          AutoText(label,
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
            child: AutoText(
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
            AutoText(label),
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
          AutoText(label),
        ],
      ),
    );
  }
}
