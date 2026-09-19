import 'dart:typed_data';
import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jambomama_nigeria/components/button.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:provider/provider.dart';

class MotherRegisterPage extends StatefulWidget {
  @override
  State<MotherRegisterPage> createState() => _MotherRegisterPageState();
}

class _MotherRegisterPageState extends State<MotherRegisterPage> {
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'NG');
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String email;
  late String fullName;
  late String password;
  late String confirmPassword;
  late String villageTown;
  late String address;
  late String hospital;
  String lga = '';

  bool isLoading = false;

  String? countryValue = 'Nigeria';
  String? cityValue;
  String? stateValue;

  // Health facility selection
  List<String> facilityOptions = [];
  String? selectedFacility;
  bool _facilitiesLoading = false;
  bool _showOtherHospitalField = false;
  final TextEditingController _hospitalController = TextEditingController();

  Uint8List? image;
  Uint8List? imageData;

  String selectedImageType = 'default';
  final Map<String, String> profileImageOptions = {
    'default': 'assets/images/default.jpg',
    'headscarf': 'assets/images/headscarf.jpg',
    'hijab': 'assets/images/hijab.jpg',
  };

  DateTime? _selectedDate;
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Phone validation state ---
  // Tracks whether the intl_phone_number_input package considers the
  // current number valid for its detected region. Wired via
  // onInputValidated below and enforced in _signUpUser since the
  // package doesn't expose a synchronous FormField validator.
  bool _phoneValidated = false;
  bool _phoneTouched = false;

  // --- Professional connection state ---
  List<DocumentSnapshot> _professionals = [];
  bool _professionalsLoading = false;
  // Single selection only — one provider per mother
  String? _selectedProfessionalId;

  @override
  void dispose() {
    _dobController.dispose();
    phoneNumber.dispose();
    _hospitalController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Pick custom image
  selectingImage() async {
    Uint8List? im = await _authController.pickProfileImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        image = im;
        selectedImageType = 'custom';
      });
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Load preregistered health facilities for the selected city
  Future<void> _loadFacilitiesForLocation() async {
    if (cityValue == null || cityValue!.isEmpty) {
      setState(() {
        facilityOptions = [];
        selectedFacility = null;
        _showOtherHospitalField = false;
        hospital = '';
        _hospitalController.clear();
      });
      return;
    }

    setState(() => _facilitiesLoading = true);

    try {
      final snapshot = await _firestore
          .collection('health_facilities')
          .where('status', isEqualTo: true)
          .where('district', isEqualTo: cityValue)
          .orderBy('name')
          .get();

      setState(() {
        facilityOptions = snapshot.docs
            .map((doc) => (doc.data()['name'] as String?) ?? '')
            .where((name) => name.isNotEmpty)
            .toList();

        selectedFacility = null;
        _showOtherHospitalField = false;
        hospital = '';
        _hospitalController.clear();
      });
    } catch (e) {
      showSnackMessage(context, 'E_L_F');
    }

    setState(() => _facilitiesLoading = false);
  }

  // Load health professionals for the selected city
  Future<void> _loadProfessionalsForLocation() async {
    if (cityValue == null || cityValue!.isEmpty) {
      setState(() {
        _professionals = [];
        _selectedProfessionalId = null;
      });
      return;
    }

    setState(() {
      _professionalsLoading = true;
      _professionals = [];
      _selectedProfessionalId = null;
    });

    try {
      final snapshot = await _firestore
          .collection('Health Professionals')
          .where('professional', isEqualTo: 'professional')
          .where('cityValue', isEqualTo: cityValue)
          .where('approved', isEqualTo: true)
          .get();

      setState(() {
        _professionals = snapshot.docs;
      });
    } catch (e) {
      // Silently fail — empty state message handles this
    }

    setState(() => _professionalsLoading = false);
  }

  // Send single deferred connection request after signup succeeds
  Future<void> _sendDeferredConnectionRequests(
      String userId, String userFullName) async {
    if (_selectedProfessionalId == null) return;

    final connectionStateModel =
        Provider.of<ConnectionStateModel>(context, listen: false);

    try {
      await connectionStateModel.sendConnectionRequest(
        requesterId: userId,
        professionalId: _selectedProfessionalId!,
        requesterName: userFullName,
      );
    } catch (_) {
      // Best-effort
    }
  }

  Widget _buildImageOption(String label, String type) {
    bool isSelected = selectedImageType == type;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              selectedImageType = type;
              if (type != 'custom') image = null;
            });
          },
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(profileImageOptions[type]!),
            ),
          ),
        ),
        SizedBox(height: 5),
        AutoText(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Show confirmation dialog before switching to a different provider
  void _showSwitchProviderWarning(String newProfessionalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            AutoText('CHANGE_PROVIDER'),
          ],
        ),
        content: AutoText('CHANGE_PROVIDER_WARNING'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AutoText('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _selectedProfessionalId = newProfessionalId);
              Navigator.pop(context);
            },
            child: AutoText('YES_CHANGE'),
          ),
        ],
      ),
    );
  }

  // Inline professional card — single select
  Widget _buildProfessionalCard(DocumentSnapshot professional) {
    final String professionalId = professional['midWifeId'];
    final bool isSelected = _selectedProfessionalId == professionalId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.red : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.red.shade50 : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: professional['midWifeImage'] != null &&
                      (professional['midWifeImage'] as String).isNotEmpty
                  ? Image.network(
                      professional['midWifeImage'],
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(),
                    )
                  : _defaultAvatar(),
            ),
            SizedBox(width: 12),

            // Name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professional['fullName'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${professional['position'] ?? ''}, ${professional['healthFacility'] ?? ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),

            // Select / deselect toggle — single selection enforced
            GestureDetector(
              onTap: () {
                if (isSelected) {
                  // Tap selected card to deselect
                  setState(() => _selectedProfessionalId = null);
                } else if (_selectedProfessionalId != null) {
                  // Another card already selected — warn before switching
                  _showSwitchProviderWarning(professionalId);
                } else {
                  setState(() => _selectedProfessionalId = professionalId);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isSelected
                      ? autoI8lnGen.translate('SELECTED')
                      : autoI8lnGen.translate('SELECT'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.grey.shade400, size: 28),
    );
  }

  // The full professionals section rendered inside the form
  Widget _buildProfessionalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Divider(color: Colors.grey.shade300),
        SizedBox(height: 16),

        // Section header
        Row(
          children: [
            Icon(Icons.people_outline, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: AutoText(
                'CONNECT_ANC_PROVIDER_TITLE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),

        // Subtitle — instructs her to only pick someone she knows
        AutoText(
          'CONNECT_ANC_PROVIDER_SUBTITLE',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        SizedBox(height: 12),

        // Warning banner — visible whenever the list is shown
        if (_professionals.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.amber.shade800, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: AutoText(
                    'CONNECT_ANC_PROVIDER_WARNING',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 12),

        // Green confirmation badge — shown once a provider is selected
        if (_selectedProfessionalId != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green.shade700, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: AutoText(
                    'ONE_PROVIDER_SELECTED',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Body: hint / loading / empty / list
        if (cityValue == null || cityValue!.isEmpty)
          _buildProfessionalsHint()
        else if (_professionalsLoading)
          _buildProfessionalsLoading()
        else if (_professionals.isEmpty)
          _buildProfessionalsEmpty()
        else
          _buildProfessionalsList(),

        // Skip link — only shown when list exists and nothing selected yet
        if (_professionals.isNotEmpty && _selectedProfessionalId == null)
          Center(
            child: TextButton(
              onPressed: () {
                setState(() => _selectedProfessionalId = null);
                showSnackMessage(context, 'SKIP_PROVIDER_NOTE');
              },
              child: AutoText(
                'CONNECT_ANC_PROVIDER_SKIP',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

        SizedBox(height: 8),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildProfessionalsHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade500, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: AutoText(
              'SELECT_CITY_TO_SEE_PROVIDERS',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalsLoading() {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
        ),
        SizedBox(width: 10),
        AutoText(
          'LOADING_PROFESSIONALS',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProfessionalsEmpty() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoText(
                  'NO_PROVIDERS_IN_CITY',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                AutoText(
                  'PROCEED_REGISTRATION_NO_PROFESSIONAL',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _professionals.map((prof) => _buildProfessionalCard(prof)).toList(),
    );
  }

  _signUpUser() async {
    // Phone number was entered but the package's own validation flagged it
    // as not matching a valid format for the detected region. We block here
    // rather than via a FormField validator because
    // InternationalPhoneNumberInput reports validity asynchronously through
    // onInputValidated instead of a synchronous validator callback.
    if (phoneNumber.text.trim().isNotEmpty && !_phoneValidated) {
      setState(() => _phoneTouched = true);
      showSnackMessage(context, 'INVALID_PHONE_NUMBER');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      String dob = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      Uint8List? uploadData = selectedImageType == 'custom' ? image : null;
      String? assetUrl = selectedImageType != 'custom'
          ? profileImageOptions[selectedImageType]
          : null;

      String result = await _authController.signUpUser(
        email,
        phoneNumber.text,
        fullName,
        password,
        uploadData,
        assetUrl,
        selectedImageType,
        dob,
        villageTown,
        countryValue ?? '',
        cityValue ?? '',
        stateValue ?? '',
        address,
        hospital,
        // NOTE: `lga` is captured below but the AuthController.signUpUser
        // signature will need a matching parameter added before this reaches
        // Firestore. Flagging here rather than guessing at that file.
      );

      if (result == 'success') {
        // Fire deferred connection request now that we have a valid UID
        final userId = _authController.currentUserId;
        if (userId != null && _selectedProfessionalId != null) {
          await _sendDeferredConnectionRequests(userId, fullName);
        }

        showSnackMessage(context, 'ACCOUNT_CREATED');
        _formKey.currentState!.reset();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
        );
      } else {
        showSnackMessage(context, result);
      }

      setState(() => isLoading = false);
    } else {
      showSnackMessage(context, 'POPULATE_FIELDS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isTablet = constraints.maxWidth > 600;
      double horizontalPadding = isTablet ? 60 : 15;
      double maxFieldWidth = isTablet ? 500 : double.infinity;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFieldWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AutoText(
                      "VALIDATION_Q_3",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 22 : 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),

                    /// PROFILE IMAGE
                    Column(
                      children: [
                        Stack(
                          children: [
                            selectedImageType == 'custom' && image != null
                                ? CircleAvatar(
                                    radius: isTablet ? 80 : 64,
                                    backgroundImage: MemoryImage(image!),
                                  )
                                : CircleAvatar(
                                    radius: isTablet ? 80 : 64,
                                    backgroundImage: AssetImage(
                                      profileImageOptions[selectedImageType]!,
                                    ),
                                  ),
                            Positioned(
                              right: 0,
                              top: 5,
                              child: IconButton(
                                onPressed: selectingImage,
                                icon: Icon(CupertinoIcons.photo),
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        AutoText(
                          'CHOOSE_PROFILE_STYLE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageOption('STANDARD', 'default'),
                            _buildImageOption('SCARF', 'headscarf'),
                            _buildImageOption('HIJAB', 'hijab'),
                          ],
                        ),
                        SizedBox(height: 10),
                        AutoText(
                          'OR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: selectingImage,
                          icon: Icon(Icons.add_a_photo),
                          label: AutoText('UPLOAD_PHOTO'),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    /// EMAIL
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("LOGIN_VALIDATION_4"),
                      ),
                      validator: (value) => value!.isEmpty
                          ? autoI8lnGen.translate("P_E_M")
                          : null,
                      onChanged: (v) => email = v,
                    ),
                    SizedBox(height: 15),

                    /// FULL NAME
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("E_F_N"),
                      ),
                      validator: (value) => value!.isEmpty
                          ? autoI8lnGen.translate("P_FF_E")
                          : null,
                      onChanged: (v) => fullName = v,
                    ),
                    SizedBox(height: 15),

                    /// DOB
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dobController,
                          decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("DOB"),
                            hintText: autoI8lnGen.translate("S_D_A"),
                          ),
                          validator: (value) => _selectedDate == null
                              ? autoI8lnGen.translate("P_S_DOB")
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    /// PHONE
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber value) {
                        number = value;
                      },
                      onInputValidated: (bool isValid) {
                        setState(() => _phoneValidated = isValid);
                      },
                      initialValue: number,
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      textFieldController: phoneNumber,
                      keyboardType: TextInputType.number,
                      inputBorder: OutlineInputBorder(),
                      formatInput: true,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      errorMessage:
                          autoI8lnGen.translate("INVALID_PHONE_NUMBER"),
                      onSaved: (PhoneNumber value) {
                        number = value;
                      },
                    ),
                    if (_phoneTouched && !_phoneValidated)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          autoI8lnGen.translate("INVALID_PHONE_NUMBER"),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),

                    SizedBox(height: 25),

                    /// LOCATION TITLE
                    AutoText(
                      'LOCATION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),

                    SizedBox(height: 15),

                    /// CSC PICKER
                    CSCPickerPlus(
                      defaultCountry: CscCountry.Nigeria,
                      onCountryChanged: (v) {
                        setState(() => countryValue = v);
                      },
                      onStateChanged: (v) {
                        setState(() => stateValue = v);
                      },
                      onCityChanged: (v) {
                        setState(() => cityValue = v);
                        _loadFacilitiesForLocation();
                        _loadProfessionalsForLocation();
                      },
                    ),
                    SizedBox(height: 15),

                    /// LGA (Local Government Area)
                    /// Sits between State and City/Village since LGAs are the
                    /// administrative unit through which Primary Health Care
                    /// is coordinated in Nigeria.
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("LGA"),
                        hintText: autoI8lnGen.translate("LGA_HINT"),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? autoI8lnGen.translate("LGA_VALIDATION")
                          : null,
                      onChanged: (v) => lga = v,
                    ),
                    SizedBox(height: 15),

                    /// TOWN
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("VALIDATION_Q"),
                      ),
                      validator: (v) => v!.isEmpty
                          ? autoI8lnGen.translate("VALIDATION_2")
                          : null,
                      onChanged: (v) => villageTown = v,
                    ),
                    SizedBox(height: 15),

                    /// ADDRESS
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("STREET"),
                      ),
                      validator: (v) => v!.isEmpty
                          ? autoI8lnGen.translate("VALIDATION_1")
                          : null,
                      onChanged: (v) => address = v,
                    ),
                    SizedBox(height: 15),

                    /// HEALTH FACILITY
                    if (_facilitiesLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            AutoText('LOADING_FACILITIES'),
                          ],
                        ),
                      ),

                    if (!_facilitiesLoading &&
                        cityValue != null &&
                        cityValue!.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: selectedFacility,
                        decoration: InputDecoration(
                          labelText: autoI8lnGen.translate("HOSPITAL"),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          ...facilityOptions.map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: '__other__',
                            child: AutoText('FACILITY_NOT_LISTED'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null) {
                            return autoI8lnGen.translate("VALIDATION_Q_2");
                          }
                          if (value == '__other__' &&
                              _hospitalController.text.trim().isEmpty) {
                            return autoI8lnGen.translate("VALIDATION_Q_2");
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedFacility = value;
                            _showOtherHospitalField = value == '__other__';
                            if (value != '__other__') {
                              hospital = value ?? '';
                              _hospitalController.clear();
                            } else {
                              hospital = _hospitalController.text;
                            }
                          });
                        },
                      ),
                      if (_showOtherHospitalField) ...[
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _hospitalController,
                          decoration: InputDecoration(
                            labelText:
                                autoI8lnGen.translate("ENTER_HOSPITAL_NAME"),
                          ),
                          validator: (value) {
                            if (_showOtherHospitalField &&
                                (value == null || value.isEmpty)) {
                              return autoI8lnGen.translate("VALIDATION_Q_2");
                            }
                            return null;
                          },
                          onChanged: (v) => hospital = v,
                        ),
                      ],
                    ] else if (!_facilitiesLoading) ...[
                      TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: autoI8lnGen.translate("HOSPITAL"),
                          hintText:
                              autoI8lnGen.translate("SELECT_LOCATION_FIRST"),
                        ),
                      ),
                    ],

                    /// CONNECT TO PROFESSIONALS SECTION
                    _buildProfessionalsSection(),

                    SizedBox(height: 15),

                    /// PASSWORD
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("PASSWORD"),
                        helperText: autoI8lnGen.translate("PASSWORD_V"),
                        helperMaxLines: 2,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return autoI8lnGen.translate("P_E_P");
                        }
                        if (value.length < 6) {
                          return autoI8lnGen.translate("P_E_6_H");
                        }
                        if (RegExp(r'^\d+$').hasMatch(value) &&
                            value.length < 8) {
                          return autoI8lnGen.translate("N_P_8");
                        }
                        if (!RegExp(r'[A-Z]').hasMatch(value) ||
                            !RegExp(r'[a-z]').hasMatch(value) ||
                            !RegExp(r'[0-9]').hasMatch(value)) {
                          return autoI8lnGen.translate("P_S_C_U");
                        }
                        return null;
                      },
                      onChanged: (v) => password = v,
                    ),
                    SizedBox(height: 15),

                    /// CONFIRM PASSWORD
                    TextFormField(
                      obscureText: _obscureConfirmText,
                      decoration: InputDecoration(
                        labelText: autoI8lnGen.translate("CONFIRM_PASSWORD"),
                        helperText:
                            autoI8lnGen.translate("CONFIRM_PASSWORD_HELPER"),
                        helperMaxLines: 2,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmText = !_obscureConfirmText),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return autoI8lnGen.translate("P_E_CONFIRM_P");
                        }
                        if (value != _passwordController.text) {
                          return autoI8lnGen
                              .translate("PASSWORDS_DO_NOT_MATCH");
                        }
                        return null;
                      },
                      onChanged: (v) => confirmPassword = v,
                    ),

                    SizedBox(height: 25),

                    /// REGISTER BUTTON
                    GestureDetector(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Sbuttons(
                              onTap: _signUpUser,
                              text: 'REGISTER',
                            ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// import 'dart:typed_data';
// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csc_picker_plus/csc_picker_plus.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:jambomama_nigeria/components/button.dart';
// import 'package:jambomama_nigeria/controllers/auth_controller.dart';
// import 'package:jambomama_nigeria/utils/showsnackbar.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:jambomama_nigeria/views/mothers/auth/login.dart';
// import 'package:jambomama_nigeria/providers/connection_provider.dart';
// import 'package:provider/provider.dart';

// class MotherRegisterPage extends StatefulWidget {
//   @override
//   State<MotherRegisterPage> createState() => _MotherRegisterPageState();
// }

// class _MotherRegisterPageState extends State<MotherRegisterPage> {
//   String initialCountry = 'NG';
//   PhoneNumber number = PhoneNumber(isoCode: 'NG');
//   bool _obscureText = true;

//   final AuthController _authController = AuthController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late String email;
//   late String fullName;
//   late String password;
//   late String villageTown;
//   late String address;
//   late String hospital;

//   bool isLoading = false;

//   String? countryValue;
//   String? cityValue;
//   String? stateValue;

//   // Health facility selection
//   List<String> facilityOptions = [];
//   String? selectedFacility;
//   bool _facilitiesLoading = false;
//   bool _showOtherHospitalField = false;
//   final TextEditingController _hospitalController = TextEditingController();

//   Uint8List? image;
//   Uint8List? imageData;

//   String selectedImageType = 'default';
//   final Map<String, String> profileImageOptions = {
//     'default': 'assets/images/default.jpg',
//     'headscarf': 'assets/images/headscarf.jpg',
//     'hijab': 'assets/images/hijab.jpg',
//   };

//   DateTime? _selectedDate;
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController phoneNumber = TextEditingController();

//   // --- Professional connection state ---
//   List<DocumentSnapshot> _professionals = [];
//   bool _professionalsLoading = false;
//   // Single selection only — one provider per mother
//   String? _selectedProfessionalId;

//   @override
//   void dispose() {
//     _dobController.dispose();
//     phoneNumber.dispose();
//     _hospitalController.dispose();
//     super.dispose();
//   }

//   // Pick custom image
//   selectingImage() async {
//     Uint8List? im = await _authController.pickProfileImage(ImageSource.gallery);
//     if (im != null) {
//       setState(() {
//         image = im;
//         selectedImageType = 'custom';
//       });
//     }
//   }

//   _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }

//   // Load preregistered health facilities for the selected city
//   Future<void> _loadFacilitiesForLocation() async {
//     if (cityValue == null || cityValue!.isEmpty) {
//       setState(() {
//         facilityOptions = [];
//         selectedFacility = null;
//         _showOtherHospitalField = false;
//         hospital = '';
//         _hospitalController.clear();
//       });
//       return;
//     }

//     setState(() => _facilitiesLoading = true);

//     try {
//       final snapshot = await _firestore
//           .collection('health_facilities')
//           .where('status', isEqualTo: true)
//           .where('district', isEqualTo: cityValue)
//           .orderBy('name')
//           .get();

//       setState(() {
//         facilityOptions = snapshot.docs
//             .map((doc) => (doc.data()['name'] as String?) ?? '')
//             .where((name) => name.isNotEmpty)
//             .toList();

//         selectedFacility = null;
//         _showOtherHospitalField = false;
//         hospital = '';
//         _hospitalController.clear();
//       });
//     } catch (e) {
//       showSnackMessage(context, 'E_L_F');
//     }

//     setState(() => _facilitiesLoading = false);
//   }

//   // Load health professionals for the selected city
//   Future<void> _loadProfessionalsForLocation() async {
//     if (cityValue == null || cityValue!.isEmpty) {
//       setState(() {
//         _professionals = [];
//         _selectedProfessionalId = null;
//       });
//       return;
//     }

//     setState(() {
//       _professionalsLoading = true;
//       _professionals = [];
//       _selectedProfessionalId = null;
//     });

//     try {
//       final snapshot = await _firestore
//           .collection('Health Professionals')
//           .where('professional', isEqualTo: 'professional')
//           .where('cityValue', isEqualTo: cityValue)
//           .where('approved', isEqualTo: true)
//           .get();

//       setState(() {
//         _professionals = snapshot.docs;
//       });
//     } catch (e) {
//       // Silently fail — empty state message handles this
//     }

//     setState(() => _professionalsLoading = false);
//   }

//   // Send single deferred connection request after signup succeeds
//   Future<void> _sendDeferredConnectionRequests(
//       String userId, String userFullName) async {
//     if (_selectedProfessionalId == null) return;

//     final connectionStateModel =
//         Provider.of<ConnectionStateModel>(context, listen: false);

//     try {
//       await connectionStateModel.sendConnectionRequest(
//         requesterId: userId,
//         professionalId: _selectedProfessionalId!,
//         requesterName: userFullName,
//       );
//     } catch (_) {
//       // Best-effort
//     }
//   }

//   Widget _buildImageOption(String label, String type) {
//     bool isSelected = selectedImageType == type;

//     return Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedImageType = type;
//               if (type != 'custom') image = null;
//             });
//           },
//           child: Container(
//             padding: EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: isSelected ? Colors.blue : Colors.transparent,
//                 width: 2,
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: CircleAvatar(
//               radius: 30,
//               backgroundImage: AssetImage(profileImageOptions[type]!),
//             ),
//           ),
//         ),
//         SizedBox(height: 5),
//         AutoText(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   // Show confirmation dialog before switching to a different provider
//   void _showSwitchProviderWarning(String newProfessionalId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
//             SizedBox(width: 8),
//             AutoText('CHANGE_PROVIDER'),
//           ],
//         ),
//         content: AutoText('CHANGE_PROVIDER_WARNING'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: AutoText('CANCEL'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               setState(() => _selectedProfessionalId = newProfessionalId);
//               Navigator.pop(context);
//             },
//             child: AutoText('YES_CHANGE'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Inline professional card — single select
//   Widget _buildProfessionalCard(DocumentSnapshot professional) {
//     final String professionalId = professional['midWifeId'];
//     final bool isSelected = _selectedProfessionalId == professionalId;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: isSelected ? Colors.red : Colors.grey.shade300,
//           width: isSelected ? 1.5 : 1,
//         ),
//         borderRadius: BorderRadius.circular(10),
//         color: isSelected ? Colors.red.shade50 : Colors.white,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         child: Row(
//           children: [
//             // Avatar
//             ClipRRect(
//               borderRadius: BorderRadius.circular(50),
//               child: professional['midWifeImage'] != null &&
//                       (professional['midWifeImage'] as String).isNotEmpty
//                   ? Image.network(
//                       professional['midWifeImage'],
//                       height: 48,
//                       width: 48,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _defaultAvatar(),
//                     )
//                   : _defaultAvatar(),
//             ),
//             SizedBox(width: 12),

//             // Name + role
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     professional['fullName'] ?? '',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     '${professional['position'] ?? ''}, ${professional['healthFacility'] ?? ''}',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(width: 8),

//             // Select / deselect toggle — single selection enforced
//             GestureDetector(
//               onTap: () {
//                 if (isSelected) {
//                   // Tap selected card to deselect
//                   setState(() => _selectedProfessionalId = null);
//                 } else if (_selectedProfessionalId != null) {
//                   // Another card already selected — warn before switching
//                   _showSwitchProviderWarning(professionalId);
//                 } else {
//                   setState(() => _selectedProfessionalId = professionalId);
//                 }
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: isSelected ? Colors.red : Colors.transparent,
//                   border: Border.all(
//                     color: isSelected ? Colors.red : Colors.grey.shade400,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   isSelected
//                       ? autoI8lnGen.translate('SELECTED')
//                       : autoI8lnGen.translate('SELECT'),
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected ? Colors.white : Colors.grey.shade700,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _defaultAvatar() {
//     return Container(
//       height: 48,
//       width: 48,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         shape: BoxShape.circle,
//       ),
//       child: Icon(Icons.person, color: Colors.grey.shade400, size: 28),
//     );
//   }

//   // The full professionals section rendered inside the form
//   Widget _buildProfessionalsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 24),
//         Divider(color: Colors.grey.shade300),
//         SizedBox(height: 16),

//         // Section header
//         Row(
//           children: [
//             Icon(Icons.people_outline, color: Colors.red, size: 22),
//             SizedBox(width: 8),
//             Expanded(
//               child: AutoText(
//                 'CONNECT_ANC_PROVIDER_TITLE',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 6),

//         // Subtitle — instructs her to only pick someone she knows
//         AutoText(
//           'CONNECT_ANC_PROVIDER_SUBTITLE',
//           style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//         ),
//         SizedBox(height: 12),

//         // Warning banner — visible whenever the list is shown
//         if (_professionals.isNotEmpty)
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade50,
//               border: Border.all(color: Colors.amber.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.info_outline,
//                     color: Colors.amber.shade800, size: 18),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: AutoText(
//                     'CONNECT_ANC_PROVIDER_WARNING',
//                     style: TextStyle(
//                       color: Colors.amber.shade900,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         SizedBox(height: 12),

//         // Green confirmation badge — shown once a provider is selected
//         if (_selectedProfessionalId != null)
//           Container(
//             margin: const EdgeInsets.only(bottom: 12),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               border: Border.all(color: Colors.green.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle,
//                     color: Colors.green.shade700, size: 18),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: AutoText(
//                     'ONE_PROVIDER_SELECTED',
//                     style: TextStyle(
//                       color: Colors.green.shade800,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//         // Body: hint / loading / empty / list
//         if (cityValue == null || cityValue!.isEmpty)
//           _buildProfessionalsHint()
//         else if (_professionalsLoading)
//           _buildProfessionalsLoading()
//         else if (_professionals.isEmpty)
//           _buildProfessionalsEmpty()
//         else
//           _buildProfessionalsList(),

//         // Skip link — only shown when list exists and nothing selected yet
//         if (_professionals.isNotEmpty && _selectedProfessionalId == null)
//           Center(
//             child: TextButton(
//               onPressed: () {
//                 setState(() => _selectedProfessionalId = null);
//                 showSnackMessage(context, 'SKIP_PROVIDER_NOTE');
//               },
//               child: AutoText(
//                 'CONNECT_ANC_PROVIDER_SKIP',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 13,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ),

//         SizedBox(height: 8),
//         Divider(color: Colors.grey.shade300),
//       ],
//     );
//   }

//   Widget _buildProfessionalsHint() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.info_outline, color: Colors.grey.shade500, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: AutoText(
//               'SELECT_CITY_TO_SEE_PROVIDERS',
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalsLoading() {
//     return Row(
//       children: [
//         SizedBox(
//           width: 16,
//           height: 16,
//           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
//         ),
//         SizedBox(width: 10),
//         AutoText(
//           'LOADING_PROFESSIONALS',
//           style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _buildProfessionalsEmpty() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         border: Border.all(color: Colors.orange.shade200),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
//           SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AutoText(
//                   'NO_PROVIDERS_IN_CITY',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.orange.shade800,
//                     fontSize: 13,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 AutoText(
//                   'PROCEED_REGISTRATION_NO_PROFESSIONAL',
//                   style: TextStyle(
//                     color: Colors.orange.shade700,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfessionalsList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children:
//           _professionals.map((prof) => _buildProfessionalCard(prof)).toList(),
//     );
//   }

//   _signUpUser() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => isLoading = true);

//       String dob = _selectedDate != null
//           ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
//           : '';

//       Uint8List? uploadData = selectedImageType == 'custom' ? image : null;
//       String? assetUrl = selectedImageType != 'custom'
//           ? profileImageOptions[selectedImageType]
//           : null;

//       String result = await _authController.signUpUser(
//         email,
//         phoneNumber.text,
//         fullName,
//         password,
//         uploadData,
//         assetUrl,
//         selectedImageType,
//         dob,
//         villageTown,
//         countryValue ?? '',
//         cityValue ?? '',
//         stateValue ?? '',
//         address,
//         hospital,
//       );

//       if (result == 'success') {
//         // Fire deferred connection request now that we have a valid UID
//         final userId = _authController.currentUserId;
//         if (userId != null && _selectedProfessionalId != null) {
//           await _sendDeferredConnectionRequests(userId, fullName);
//         }

//         showSnackMessage(context, 'ACCOUNT_CREATED');
//         _formKey.currentState!.reset();

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})),
//         );
//       } else {
//         showSnackMessage(context, result);
//       }

//       setState(() => isLoading = false);
//     } else {
//       showSnackMessage(context, 'POPULATE_FIELDS');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       bool isTablet = constraints.maxWidth > 600;
//       double horizontalPadding = isTablet ? 60 : 15;
//       double maxFieldWidth = isTablet ? 500 : double.infinity;

//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//         ),
//         body: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//             child: Form(
//               key: _formKey,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: maxFieldWidth),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     AutoText(
//                       "VALIDATION_Q_3",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isTablet ? 22 : 18,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     /// PROFILE IMAGE
//                     Column(
//                       children: [
//                         Stack(
//                           children: [
//                             selectedImageType == 'custom' && image != null
//                                 ? CircleAvatar(
//                                     radius: isTablet ? 80 : 64,
//                                     backgroundImage: MemoryImage(image!),
//                                   )
//                                 : CircleAvatar(
//                                     radius: isTablet ? 80 : 64,
//                                     backgroundImage: AssetImage(
//                                       profileImageOptions[selectedImageType]!,
//                                     ),
//                                   ),
//                             Positioned(
//                               right: 0,
//                               top: 5,
//                               child: IconButton(
//                                 onPressed: selectingImage,
//                                 icon: Icon(CupertinoIcons.photo),
//                                 color: Colors.red,
//                               ),
//                             )
//                           ],
//                         ),
//                         SizedBox(height: 15),
//                         AutoText(
//                           'CHOOSE_PROFILE_STYLE',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: isTablet ? 18 : 16,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             _buildImageOption('STANDARD', 'default'),
//                             _buildImageOption('SCARF', 'headscarf'),
//                             _buildImageOption('HIJAB', 'hijab'),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         AutoText(
//                           'OR',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         TextButton.icon(
//                           onPressed: selectingImage,
//                           icon: Icon(Icons.add_a_photo),
//                           label: AutoText('UPLOAD_PHOTO'),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 20),

//                     /// EMAIL
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: autoI8lnGen.translate("LOGIN_VALIDATION_4"),
//                       ),
//                       validator: (value) => value!.isEmpty
//                           ? autoI8lnGen.translate("P_E_M")
//                           : null,
//                       onChanged: (v) => email = v,
//                     ),
//                     SizedBox(height: 15),

//                     /// FULL NAME
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: autoI8lnGen.translate("E_F_N"),
//                       ),
//                       validator: (value) => value!.isEmpty
//                           ? autoI8lnGen.translate("P_FF_E")
//                           : null,
//                       onChanged: (v) => fullName = v,
//                     ),
//                     SizedBox(height: 15),

//                     /// DOB
//                     GestureDetector(
//                       onTap: () => _selectDate(context),
//                       child: AbsorbPointer(
//                         child: TextFormField(
//                           controller: _dobController,
//                           decoration: InputDecoration(
//                             labelText: autoI8lnGen.translate("DOB"),
//                             hintText: autoI8lnGen.translate("S_D_A"),
//                           ),
//                           validator: (value) => _selectedDate == null
//                               ? autoI8lnGen.translate("P_S_DOB")
//                               : null,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 15),

//                     /// PHONE
//                     InternationalPhoneNumberInput(
//                       onInputChanged: (PhoneNumber number) {},
//                       initialValue: number,
//                       selectorConfig: SelectorConfig(
//                         selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
//                       ),
//                       textFieldController: phoneNumber,
//                       keyboardType: TextInputType.number,
//                       inputBorder: OutlineInputBorder(),
//                     ),

//                     SizedBox(height: 25),

//                     /// LOCATION TITLE
//                     AutoText(
//                       'LOCATION',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isTablet ? 18 : 16,
//                       ),
//                     ),

//                     SizedBox(height: 15),

//                     /// CSC PICKER
//                     CSCPickerPlus(
//                       onCountryChanged: (v) {
//                         setState(() => countryValue = v);
//                       },
//                       onStateChanged: (v) {
//                         setState(() => stateValue = v);
//                       },
//                       onCityChanged: (v) {
//                         setState(() => cityValue = v);
//                         _loadFacilitiesForLocation();
//                         _loadProfessionalsForLocation();
//                       },
//                     ),
//                     SizedBox(height: 15),

//                     /// TOWN
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: autoI8lnGen.translate("VALIDATION_Q"),
//                       ),
//                       validator: (v) => v!.isEmpty
//                           ? autoI8lnGen.translate("VALIDATION_2")
//                           : null,
//                       onChanged: (v) => villageTown = v,
//                     ),
//                     SizedBox(height: 15),

//                     /// ADDRESS
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: autoI8lnGen.translate("STREET"),
//                       ),
//                       validator: (v) => v!.isEmpty
//                           ? autoI8lnGen.translate("VALIDATION_1")
//                           : null,
//                       onChanged: (v) => address = v,
//                     ),
//                     SizedBox(height: 15),

//                     /// HEALTH FACILITY
//                     if (_facilitiesLoading)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Row(
//                           children: [
//                             SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                             SizedBox(width: 10),
//                             AutoText('LOADING_FACILITIES'),
//                           ],
//                         ),
//                       ),

//                     if (!_facilitiesLoading &&
//                         cityValue != null &&
//                         cityValue!.isNotEmpty) ...[
//                       DropdownButtonFormField<String>(
//                         value: selectedFacility,
//                         decoration: InputDecoration(
//                           labelText: autoI8lnGen.translate("HOSPITAL"),
//                           border: OutlineInputBorder(),
//                         ),
//                         items: [
//                           ...facilityOptions.map(
//                             (name) => DropdownMenuItem(
//                               value: name,
//                               child: Text(
//                                 name,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                           DropdownMenuItem(
//                             value: '__other__',
//                             child: AutoText('FACILITY_NOT_LISTED'),
//                           ),
//                         ],
//                         validator: (value) {
//                           if (value == null) {
//                             return autoI8lnGen.translate("VALIDATION_Q_2");
//                           }
//                           if (value == '__other__' &&
//                               _hospitalController.text.trim().isEmpty) {
//                             return autoI8lnGen.translate("VALIDATION_Q_2");
//                           }
//                           return null;
//                         },
//                         onChanged: (value) {
//                           setState(() {
//                             selectedFacility = value;
//                             _showOtherHospitalField = value == '__other__';
//                             if (value != '__other__') {
//                               hospital = value ?? '';
//                               _hospitalController.clear();
//                             } else {
//                               hospital = _hospitalController.text;
//                             }
//                           });
//                         },
//                       ),
//                       if (_showOtherHospitalField) ...[
//                         SizedBox(height: 15),
//                         TextFormField(
//                           controller: _hospitalController,
//                           decoration: InputDecoration(
//                             labelText:
//                                 autoI8lnGen.translate("ENTER_HOSPITAL_NAME"),
//                           ),
//                           validator: (value) {
//                             if (_showOtherHospitalField &&
//                                 (value == null || value.isEmpty)) {
//                               return autoI8lnGen.translate("VALIDATION_Q_2");
//                             }
//                             return null;
//                           },
//                           onChanged: (v) => hospital = v,
//                         ),
//                       ],
//                     ] else if (!_facilitiesLoading) ...[
//                       TextFormField(
//                         enabled: false,
//                         decoration: InputDecoration(
//                           labelText: autoI8lnGen.translate("HOSPITAL"),
//                           hintText:
//                               autoI8lnGen.translate("SELECT_LOCATION_FIRST"),
//                         ),
//                       ),
//                     ],

//                     /// CONNECT TO PROFESSIONALS SECTION
//                     _buildProfessionalsSection(),

//                     SizedBox(height: 15),

//                     /// PASSWORD
//                     TextFormField(
//                       obscureText: _obscureText,
//                       decoration: InputDecoration(
//                         labelText: autoI8lnGen.translate("PASSWORD"),
//                         helperText: autoI8lnGen.translate("PASSWORD_V"),
//                         helperMaxLines: 2,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () =>
//                               setState(() => _obscureText = !_obscureText),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return autoI8lnGen.translate("P_E_P");
//                         }
//                         if (value.length < 6) {
//                           return autoI8lnGen.translate("P_E_6_H");
//                         }
//                         if (RegExp(r'^\d+$').hasMatch(value) &&
//                             value.length < 8) {
//                           return autoI8lnGen.translate("N_P_8");
//                         }
//                         if (!RegExp(r'[A-Z]').hasMatch(value) ||
//                             !RegExp(r'[a-z]').hasMatch(value) ||
//                             !RegExp(r'[0-9]').hasMatch(value)) {
//                           return autoI8lnGen.translate("P_S_C_U");
//                         }
//                         return null;
//                       },
//                       onChanged: (v) => password = v,
//                     ),

//                     SizedBox(height: 25),

//                     /// REGISTER BUTTON
//                     GestureDetector(
//                       child: isLoading
//                           ? CircularProgressIndicator()
//                           : Sbuttons(
//                               onTap: _signUpUser,
//                               text: 'REGISTER',
//                             ),
//                     ),
//                     SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
