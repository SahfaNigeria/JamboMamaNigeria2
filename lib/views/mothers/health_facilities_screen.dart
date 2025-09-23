import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart'
    show
        AppBar,
        BorderRadius,
        BorderSide,
        BoxDecoration,
        BuildContext,
        Card,
        Center,
        CircularProgressIndicator,
        Color,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        DraggableScrollableSheet,
        DropdownButtonFormField,
        DropdownMenuItem,
        EdgeInsets,
        ElevatedButton,
        Expanded,
        FloatingActionButton,
        FontWeight,
        Form,
        FormState,
        GlobalKey,
        Icon,
        IconButton,
        IconData,
        Icons,
        InputDecoration,
        Key,
        ListView,
        MainAxisAlignment,
        MediaQuery,
        Navigator,
        OutlineInputBorder,
        OutlinedButton,
        Padding,
        Radius,
        RefreshIndicator,
        RoundedRectangleBorder,
        Row,
        Scaffold,
        ScaffoldMessenger,
        SizedBox,
        SnackBar,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextFormField,
        TextInputType,
        TextStyle,
        VoidCallback,
        Widget,
        showModalBottomSheet,
        TextAlign,
        Border;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthFacilitiesScreen extends StatefulWidget {
  const HealthFacilitiesScreen({Key? key}) : super(key: key);

  @override
  State<HealthFacilitiesScreen> createState() => _HealthFacilitiesScreenState();
}

class _HealthFacilitiesScreenState extends State<HealthFacilitiesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userLocation = '';
  String userFullLocation = '';
  bool isLoading = true;
  List<HealthFacility> facilities = [];
  bool isHealthProvider = false;

  @override
  void initState() {
    super.initState();
    _loadUserLocationAndFacilities();
  }

  Future<void> _loadUserLocationAndFacilities() async {
    try {
      final user = _auth.currentUser;
      print('DEBUG: Current user = ${user?.uid}');

      if (user != null) {
        DocumentSnapshot? userDoc;

        // Check if user is a New Mother first
        DocumentSnapshot newMotherDoc =
            await _firestore.collection('New Mothers').doc(user.uid).get();
        print('DEBUG: New Mothers doc exists = ${newMotherDoc.exists}');

        if (newMotherDoc.exists) {
          userDoc = newMotherDoc;
          isHealthProvider = false;
          print('DEBUG: User is a New Mother');
        } else {
          // Check if user is a Health Professional
          DocumentSnapshot healthProfDoc = await _firestore
              .collection('Health Professionals')
              .doc(user.uid)
              .get();
          print(
              'DEBUG: Health Professionals doc exists = ${healthProfDoc.exists}');
          if (healthProfDoc.exists) {
            userDoc = healthProfDoc;
            isHealthProvider = true;
            print('DEBUG: User is a Health Professional');
          }
        }

        if (userDoc != null && userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          print('DEBUG: User data loaded = $userData');

          if (userData != null) {
            String villageTown = userData['villageTown'] ?? '';
            String cityValue = userData['cityValue'] ?? '';
            String stateValue = userData['stateValue'] ?? '';
            String countryValue = userData['countryValue'] ?? '';

            print(
                'DEBUG: Extracted location values → villageTown=$villageTown, cityValue=$cityValue, stateValue=$stateValue, countryValue=$countryValue');

            setState(() {
              userLocation = cityValue;
              userFullLocation = _buildFullLocationString(
                  villageTown, cityValue, stateValue, countryValue);
            });
            print('DEBUG: userLocation set = $userLocation');
            print('DEBUG: userFullLocation set = $userFullLocation');

            await _loadHealthFacilities();
          }
        }
      }
    } catch (e) {
      print('ERROR: Loading user location failed → $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_L_U_S $e')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  String _buildFullLocationString(
      String villageTown, String city, String state, String country) {
    List<String> locationParts = [];

    if (villageTown.isNotEmpty) locationParts.add(villageTown);
    if (city.isNotEmpty) locationParts.add(city);
    if (state.isNotEmpty) locationParts.add(state);
    if (country.isNotEmpty) locationParts.add(country);

    return locationParts.join(', ');
  }

  Future<void> _loadHealthFacilities() async {
    try {
      print('DEBUG: Loading health facilities... userLocation=$userLocation');

      Query query = _firestore
          .collection('health_facilities')
          .where('status', isEqualTo: true)
          .orderBy('name');

      if (userLocation.isNotEmpty) {
        query = query.where('district', isEqualTo: userLocation);
        print('DEBUG: Filtering facilities by district=$userLocation');
      }

      final snapshot = await query.get();
      print(
          'DEBUG: Facilities query returned ${snapshot.docs.length} documents');

      setState(() {
        facilities = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print('DEBUG: Facility loaded → id=${doc.id}, data=$data');
          return HealthFacility.fromMap(doc.id, data);
        }).toList();
      });

      print('DEBUG: facilities.length=${facilities.length}');
      for (var f in facilities) {
        f.debugCoordinates(); // Uses your helper method
      }
    } catch (e) {
      print('ERROR: Loading facilities failed → $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_L_F $e')),
      );
    }
  }

  // Future<void> _openGoogleMaps(HealthFacility facility) async {
  //   try {
  //     // Option 1: Let Google Maps handle current location automatically
  //     final String directionsUrl =
  //         'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}';

  //     if (await canLaunchUrl(Uri.parse(directionsUrl))) {
  //       await launchUrl(Uri.parse(directionsUrl),
  //           mode: LaunchMode.externalApplication);
  //     } else {
  //       // Fallback: Open facility location directly
  //       final String fallbackUrl =
  //           'https://www.google.com/maps/search/?api=1&query=${facility.latitude},${facility.longitude}';

  //       if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
  //         await launchUrl(Uri.parse(fallbackUrl),
  //             mode: LaunchMode.externalApplication);

  //       } else {
  //         throw 'Could not open maps';
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error opening maps: $e')),
  //     );
  //   }
  // }

  Future<void> _openGoogleMaps(HealthFacility facility) async {
    final Uri directionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}',
    );

    try {
      await launchUrl(
        directionsUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_O_G_P $e')),
      );
    }
  }

  void _showAddFacilityDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFacilityForm(
        userLocation: userLocation,
        userFullLocation: userFullLocation,
        onFacilityAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AutoText(
                  'FACILITY_SUBMITTED_APPROV'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'DEBUG: Building UI. isLoading=$isLoading, facilities.length=${facilities.length}');
    return Scaffold(
      appBar: AppBar(
        title: const AutoText('HEALTH_FACILITIES'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Location Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.teal, size: 20),
                    const SizedBox(width: 8),
                    AutoText(
                      'YL',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AutoText(
                  userFullLocation.isNotEmpty
                      ? userFullLocation
                      : 'LNS',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AutoText(
                  '${facilities.length} FF',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Facilities List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : facilities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_hospital_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No health facilities found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userLocation.isEmpty
                                  ? 'Please update your location in settings'
                                  : 'Be the first to add a facility in your area!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHealthFacilities,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: facilities.length,
                          itemBuilder: (context, index) {
                            final facility = facilities[index];
                            return HealthFacilityCard(
                              facility: facility,
                              onGetDirections: () => _openGoogleMaps(facility),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFacilityDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text(
          'Add Facility',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class HealthFacilityCard extends StatelessWidget {
  final HealthFacility facility;
  final VoidCallback onGetDirections;

  const HealthFacilityCard({
    Key? key,
    required this.facility,
    required this.onGetDirections,
  }) : super(key: key);

  Color _getFacilityTypeColor(String type) {
    String lowerType = type.toLowerCase();

    if (lowerType == autoI8lnGen.translate("HOSPITAL_1")) {
      return Colors.red;
    } else if (lowerType == autoI8lnGen.translate("H_C_2")) {
      return Colors.orange;
    } else if (lowerType == autoI8lnGen.translate("DISPENSARY_2")) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }


  IconData _getFacilityTypeIcon(String type) {
    String lowerType = type.toLowerCase();
    String hospital = autoI8lnGen.translate("HOSPITAL_1").toLowerCase();
    String healthCenter = autoI8lnGen.translate("H_C_2").toLowerCase();
    String dispensary = autoI8lnGen.translate("DISPENSARY_2").toLowerCase();

    if (lowerType == hospital) {
      return Icons.local_hospital;
    } else if (lowerType == healthCenter) {
      return Icons.medical_services;
    } else if (lowerType == dispensary) {
      return Icons.medication;
    } else {
      return Icons.healing;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _getFacilityTypeColor(facility.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFacilityTypeIcon(facility.type),
                    color: _getFacilityTypeColor(facility.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getFacilityTypeColor(facility.type)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          facility.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getFacilityTypeColor(facility.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (facility.address.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      facility.address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (facility.phoneNumber.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    facility.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGetDirections,
                    icon: const Icon(Icons.directions),
                    label: const AutoText('G_D'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                if (facility.phoneNumber.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final Uri phoneUri =
                          Uri(scheme: 'tel', path: facility.phoneNumber);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                    icon: const Icon(Icons.phone),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddFacilityForm extends StatefulWidget {
  final String userLocation;
  final String userFullLocation;
  final VoidCallback onFacilityAdded;

  const AddFacilityForm({
    Key? key,
    required this.userLocation,
    required this.userFullLocation,
    required this.onFacilityAdded,
  }) : super(key: key);

  @override
  State<AddFacilityForm> createState() => _AddFacilityFormState();
}

class _AddFacilityFormState extends State<AddFacilityForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedType = autoI8lnGen.translate("HOSPITAL");
  bool _isSubmitting = false;

  final List<String> _facilityTypes = [
    autoI8lnGen.translate("HEALTH_FACILITIES_HOSPITAL"), // "Hospital"
    autoI8lnGen.translate("HEALTH_FACILITIES_HEALTH_CENTER"), // "Health Center"
    autoI8lnGen.translate("HEALTH_FACILITIES_DISPENSARY"), // "Dispensary"
    autoI8lnGen.translate("HEALTH_FACILITIES_CLINIC"), // "Clinic"
    autoI8lnGen.translate("HEALTH_FACILITIES_MEDICAL_CENTER"), // "Medical Center"
  ];

  Future<void> _submitFacility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw autoI8lnGen.translate("U_N_A");

      await FirebaseFirestore.instance.collection('health_facilities').add({
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'address': _addressController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'district': widget.userLocation, // cityValue from user's registration
        'status': false, // admin will verify & approve
        'submittedBy': user.uid,
        // Prepare for GeoPoint - admin will add this field
        'location': null, // Admin will set this as GeoPoint
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      widget.onFacilityAdded();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_S_F $e')),
      );
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: AutoText(
                          'A_H_F',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AutoText(
                    'H_O_H_F '
                    'Y_R_V',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.userFullLocation.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoText(
                              'S_F_F ${widget.userFullLocation}',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration:  InputDecoration(
                      labelText: autoI8lnGen.translate("F_NAME"),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'P_E_F_N'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration:  InputDecoration(
                      labelText: autoI8lnGen.translate("F_TYPE"),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _facilityTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration:  InputDecoration(
                      labelText: autoI8lnGen.translate("ADDRESS_2"),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    validator: (value) =>
                        value?.isEmpty ?? true ? autoI8lnGen.translate("VALIDATION_Q_16") : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration:  InputDecoration(
                      labelText: autoI8lnGen.translate("PHONE_NUMBER"),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFacility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          :  AutoText(
                              'S_O_F',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class HealthFacility {
  final String id;
  final String name;
  final String type;
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final String country;
  final String state;
  final String lga;
  final String area;
  final bool status;

  HealthFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.state,
    required this.lga,
    required this.area,
    required this.status,
  });

  factory HealthFacility.fromMap(String id, Map<String, dynamic> data) {
    double lat = 0.0;
    double lng = 0.0;

    // Check if coordinates are stored as GeoPoint (preferred for admin)
    if (data['location'] is GeoPoint) {
      GeoPoint geoPoint = data['location'] as GeoPoint;
      lat = geoPoint.latitude;
      lng = geoPoint.longitude;
    }
    // Fallback to separate latitude/longitude fields
    else {
      // Helper function to safely extract coordinate values
      double extractCoordinate(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      lat = extractCoordinate(data['latitude']);
      lng = extractCoordinate(data['longitude']);
    }

    return HealthFacility(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      latitude: lat,
      longitude: lng,
      country: data['country'] ?? '',
      state: data['state'] ?? '',
      lga: data['lga'] ?? '',
      area: data['area'] ?? '',
      status: data['status'] ?? false,
    );
  }

  // Method to check if facility has valid coordinates
  bool hasValidCoordinates() {
    return latitude != 0.0 && longitude != 0.0;
  }

  // Method for debugging - shows what coordinates are loaded
  void debugCoordinates() {
    print('Facility: $name');
    print('Latitude: $latitude, Longitude: $longitude');
    print('Valid coordinates: ${hasValidCoordinates()}');
  }
}

// import 'package:flutter/material.dart'

//     show
//         AppBar,
//         BorderRadius,
//         BorderSide,
//         BoxDecoration,
//         BuildContext,
//         Card,
//         Center,
//         CircularProgressIndicator,
//         Color,
//         Colors,
//         Column,
//         Container,
//         CrossAxisAlignment,
//         DraggableScrollableSheet,
//         DropdownButtonFormField,
//         DropdownMenuItem,
//         EdgeInsets,
//         ElevatedButton,
//         Expanded,
//         FloatingActionButton,
//         FontWeight,
//         Form,
//         FormState,
//         GlobalKey,
//         Icon,
//         IconButton,
//         IconData,
//         Icons,
//         InputDecoration,
//         Key,
//         ListView,
//         MainAxisAlignment,
//         MediaQuery,
//         Navigator,
//         OutlineInputBorder,
//         OutlinedButton,
//         Padding,
//         Radius,
//         RefreshIndicator,
//         RoundedRectangleBorder,
//         Row,
//         Scaffold,
//         ScaffoldMessenger,
//         SizedBox,
//         SnackBar,
//         State,
//         StatefulWidget,
//         StatelessWidget,
//         Text,
//         TextEditingController,
//         TextFormField,
//         TextInputType,
//         TextStyle,
//         VoidCallback,
//         Widget,
//         showModalBottomSheet,
//         TextAlign,
//         Border;


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HealthFacilitiesScreen extends StatefulWidget {
//   const HealthFacilitiesScreen({Key? key}) : super(key: key);

//   @override
//   State<HealthFacilitiesScreen> createState() => _HealthFacilitiesScreenState();
// }

// class _HealthFacilitiesScreenState extends State<HealthFacilitiesScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String userLocation = '';
//   String userFullLocation = '';
//   bool isLoading = true;
//   List<HealthFacility> facilities = [];
//   bool isHealthProvider = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserLocationAndFacilities();
//   }

//   Future<void> _loadUserLocationAndFacilities() async {
//     try {
//       // Get user's registered location from the correct collections
//       final user = _auth.currentUser;
//       if (user != null) {
//         DocumentSnapshot? userDoc;

//         // Check if user is a New Mother first
//         DocumentSnapshot newMotherDoc =
//             await _firestore.collection('New Mothers').doc(user.uid).get();

//         if (newMotherDoc.exists) {
//           userDoc = newMotherDoc;
//           isHealthProvider = false;
//         } else {
//           // Check if user is a Health Professional
//           DocumentSnapshot healthProfDoc = await _firestore
//               .collection('Health Professionals')
//               .doc(user.uid)
//               .get();
//           if (healthProfDoc.exists) {
//             userDoc = healthProfDoc;
//             isHealthProvider = true;
//           }
//         }

//         if (userDoc != null && userDoc.exists) {
//           final userData = userDoc.data() as Map<String, dynamic>?;
//           if (userData != null) {
//             // Extract location data based on the registration structure
//             String villageTown = userData['villageTown'] ?? '';
//             String cityValue = userData['cityValue'] ?? '';
//             String stateValue = userData['stateValue'] ?? '';
//             String countryValue = userData['countryValue'] ?? '';

//             setState(() {
//               // Use cityValue as the primary location for filtering (matching district)
//               userLocation = cityValue;
//               // Create a full location string for display
//               userFullLocation = _buildFullLocationString(
//                   villageTown, cityValue, stateValue, countryValue);
//             });
//             await _loadHealthFacilities();
//           }
//         }
//       }
//     } catch (e) {
//       print('Error loading user location: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading user location: $e')),
//       );
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }

//   String _buildFullLocationString(
//       String villageTown, String city, String state, String country) {
//     List<String> locationParts = [];

//     if (villageTown.isNotEmpty) locationParts.add(villageTown);
//     if (city.isNotEmpty) locationParts.add(city);
//     if (state.isNotEmpty) locationParts.add(state);
//     if (country.isNotEmpty) locationParts.add(country);

//     return locationParts.join(', ');
//   }

//   Future<void> _loadHealthFacilities() async {
//     try {
//       Query query = _firestore
//           .collection('health_facilities')
//           .where('status', isEqualTo: 'approved')
//           .orderBy('name');

//       // Filter by user location if available
//       // Using cityValue as district filter since that's likely the administrative level
//       if (userLocation.isNotEmpty) {
//         query = query.where('district', isEqualTo: userLocation);
//       }

//       final snapshot = await query.get();

//       setState(() {
//         facilities = snapshot.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return HealthFacility.fromMap(doc.id, data);
//         }).toList();
//       });
//     } catch (e) {
//       print('Error loading facilities: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading facilities: $e')),
//       );
//     }
//   }

//   Future<void> _openGoogleMaps(HealthFacility facility) async {
//     try {
//       // Option 1: Let Google Maps handle current location automatically
//       final String directionsUrl =
//           'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}';

//       if (await canLaunchUrl(Uri.parse(directionsUrl))) {
//         await launchUrl(Uri.parse(directionsUrl),
//             mode: LaunchMode.externalApplication);
//       } else {
//         // Fallback: Open facility location directly
//         final String fallbackUrl =
//             'https://www.google.com/maps/search/?api=1&query=${facility.latitude},${facility.longitude}';

//         if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
//           await launchUrl(Uri.parse(fallbackUrl),
//               mode: LaunchMode.externalApplication);
//         } else {
//           throw 'Could not open maps';
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error opening maps: $e')),
//       );
//     }
//   }

//   void _showAddFacilityDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => AddFacilityForm(
//         userLocation: userLocation,
//         userFullLocation: userFullLocation,
//         onFacilityAdded: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                   'Facility submitted for approval. Thank you for contributing!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Health Facilities'),
//         backgroundColor: Colors.teal,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Location Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.teal.shade50,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.location_on, color: Colors.teal, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Your Location',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.teal.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   userFullLocation.isNotEmpty
//                       ? userFullLocation
//                       : 'Location not set',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${facilities.length} facilities found',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Facilities List
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : facilities.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.local_hospital_outlined,
//                               size: 64,
//                               color: Colors.grey.shade400,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No health facilities found',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               userLocation.isEmpty
//                                   ? 'Please update your location in settings'
//                                   : 'Be the first to add a facility in your area!',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.shade500,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       )
//                     : RefreshIndicator(
//                         onRefresh: _loadHealthFacilities,
//                         child: ListView.builder(
//                           padding: const EdgeInsets.all(16),
//                           itemCount: facilities.length,
//                           itemBuilder: (context, index) {
//                             final facility = facilities[index];
//                             return HealthFacilityCard(
//                               facility: facility,
//                               onGetDirections: () => _openGoogleMaps(facility),
//                             );
//                           },
//                         ),
//                       ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showAddFacilityDialog,
//         backgroundColor: Colors.teal,
//         icon: const Icon(Icons.add_location_alt, color: Colors.white),
//         label: const Text(
//           'Add Facility',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

// class HealthFacilityCard extends StatelessWidget {
//   final HealthFacility facility;
//   final VoidCallback onGetDirections;

//   const HealthFacilityCard({
//     Key? key,
//     required this.facility,
//     required this.onGetDirections,
//   }) : super(key: key);

//   Color _getFacilityTypeColor(String type) {
//     switch (type.toLowerCase()) {
//       case 'hospital':
//         return Colors.red;
//       case 'health center':
//         return Colors.orange;
//       case 'dispensary':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getFacilityTypeIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'hospital':
//         return Icons.local_hospital;
//       case 'health center':
//         return Icons.medical_services;
//       case 'dispensary':
//         return Icons.medication;
//       default:
//         return Icons.healing;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color:
//                         _getFacilityTypeColor(facility.type).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     _getFacilityTypeIcon(facility.type),
//                     color: _getFacilityTypeColor(facility.type),
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         facility.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: _getFacilityTypeColor(facility.type)
//                               .withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           facility.type,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: _getFacilityTypeColor(facility.type),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             if (facility.address.isNotEmpty) ...[
//               Row(
//                 children: [
//                   Icon(Icons.location_on_outlined,
//                       size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       facility.address,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//             ],
//             if (facility.phoneNumber.isNotEmpty) ...[
//               Row(
//                 children: [
//                   Icon(Icons.phone_outlined,
//                       size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 8),
//                   Text(
//                     facility.phoneNumber,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: onGetDirections,
//                     icon: const Icon(Icons.directions),
//                     label: const Text('Get Directions'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.teal,
//                       side: const BorderSide(color: Colors.teal),
//                     ),
//                   ),
//                 ),
//                 if (facility.phoneNumber.isNotEmpty) ...[
//                   const SizedBox(width: 8),
//                   IconButton(
//                     onPressed: () async {
//                       final Uri phoneUri =
//                           Uri(scheme: 'tel', path: facility.phoneNumber);
//                       if (await canLaunchUrl(phoneUri)) {
//                         await launchUrl(phoneUri);
//                       }
//                     },
//                     icon: const Icon(Icons.phone),
//                     style: IconButton.styleFrom(
//                       backgroundColor: Colors.green.withOpacity(0.1),
//                       foregroundColor: Colors.green,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// class AddFacilityForm extends StatefulWidget {
//   final String userLocation;
//   final String userFullLocation;
//   final VoidCallback onFacilityAdded;

//   const AddFacilityForm({
//     Key? key,
//     required this.userLocation,
//     required this.userFullLocation,
//     required this.onFacilityAdded,
//   }) : super(key: key);

//   @override
//   State<AddFacilityForm> createState() => _AddFacilityFormState();
// }

// class _AddFacilityFormState extends State<AddFacilityForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _phoneController = TextEditingController();

//   String _selectedType = 'Hospital';
//   bool _isSubmitting = false;

//   final List<String> _facilityTypes = [
//     'Hospital',
//     'Health Center',
//     'Dispensary',
//     'Clinic',
//     'Medical Center',
//   ];

//   Future<void> _submitFacility() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw 'User not authenticated';

//       await FirebaseFirestore.instance.collection('health_facilities').add({
//         'name': _nameController.text.trim(),
//         'type': _selectedType,
//         'address': _addressController.text.trim(),
//         'phoneNumber': _phoneController.text.trim(),
//         'district': widget.userLocation, // cityValue from user’s registration
//         'status': false, // admin will verify & approve
//         'submittedBy': user.uid,
//         'latitude': null, // placeholder for admin
//         'longitude': null, // placeholder for admin
//         'submittedAt': FieldValue.serverTimestamp(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       widget.onFacilityAdded();
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error submitting facility: $e')),
//       );
//     }

//     setState(() {
//       _isSubmitting = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         builder: (context, scrollController) {
//           return Container(
//             padding: const EdgeInsets.all(20),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: Form(
//               key: _formKey,
//               child: ListView(
//                 controller: scrollController,
//                 children: [
//                   Row(
//                     children: [
//                       const Expanded(
//                         child: Text(
//                           'Add Health Facility',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: const Icon(Icons.close),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Help others by adding a health facility. '
//                     'Your submission will be reviewed and verified by an admin before being published.',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   if (widget.userFullLocation.isNotEmpty) ...[
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline,
//                               color: Colors.blue.shade700, size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Submitting facility for: ${widget.userFullLocation}',
//                               style: TextStyle(
//                                 color: Colors.blue.shade700,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 24),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Facility Name *',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.local_hospital),
//                     ),
//                     validator: (value) => value?.isEmpty ?? true
//                         ? 'Please enter facility name'
//                         : null,
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: _selectedType,
//                     decoration: const InputDecoration(
//                       labelText: 'Facility Type *',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.category),
//                     ),
//                     items: _facilityTypes.map((type) {
//                       return DropdownMenuItem(value: type, child: Text(type));
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedType = value!;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _addressController,
//                     decoration: const InputDecoration(
//                       labelText: 'Address *',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.location_on),
//                     ),
//                     maxLines: 2,
//                     validator: (value) =>
//                         value?.isEmpty ?? true ? 'Please enter address' : null,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _phoneController,
//                     decoration: const InputDecoration(
//                       labelText: 'Phone Number',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.phone),
//                     ),
//                     keyboardType: TextInputType.phone,
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _isSubmitting ? null : _submitFacility,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: _isSubmitting
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text(
//                               'Submit for Review',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _addressController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
// }







// class HealthFacility {
//   final String id;
//   final String name;
//   final String type;
//   final String address;
//   final String phoneNumber;
//   final double latitude;
//   final double longitude;
//   final String country;
//   final String state;
//   final String lga;
//   final String area;
//   final String status;

//   HealthFacility({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.address,
//     required this.phoneNumber,
//     required this.latitude,
//     required this.longitude,
//     required this.country,
//     required this.state,
//     required this.lga,
//     required this.area,
//     required this.status,
//   });

//   factory HealthFacility.fromMap(String id, Map<String, dynamic> data) {
//     return HealthFacility(
//       id: id,
//       name: data['name'] ?? '',
//       type: data['type'] ?? '',
//       address: data['address'] ?? '',
//       phoneNumber: data['phoneNumber'] ?? '',
//       latitude: (data['latitude'] ?? 0.0).toDouble(),
//       longitude: (data['longitude'] ?? 0.0).toDouble(),
//       country: data['country'] ?? '',
//       state: data['state'] ?? '',
//       lga: data['lga'] ?? '',
//       area: data['area'] ?? '',
//       status: data['status'] ?? '',
//     );
//   }
// }

