import 'dart:typed_data';
import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jambomama_nigeria/components/button.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login.dart';

class MotherRegisterPage extends StatefulWidget {
  @override
  State<MotherRegisterPage> createState() => _MotherRegisterPageState();
}

class _MotherRegisterPageState extends State<MotherRegisterPage> {
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'NG');
  bool _obscureText = true;

  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;

  late String fullName;
  final TextEditingController phoneNumber = TextEditingController();

  late String password;

  bool isLoading = false;

  late String villageTown;

  String? countryValue;

  String? cityValue;

  String? stateValue;

  late String address;

  late String hospital;

  Uint8List? image;

  Uint8List? imageData;

  // New fields for profile picture selection
  String selectedImageType =
      'default'; // 'default', 'headscarf', 'hijab', 'custom'
  final Map<String, String> profileImageOptions = {
    'default': 'assets/images/default.jpg',
    'headscarf': 'assets/images/headscarf.jpg',
    'hijab': 'assets/images/hijab.jpg',
  };

  DateTime? _selectedDate;
  final TextEditingController _dobController = TextEditingController();

  _signUpUser() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      // Format the date as needed (e.g., "yyyy-MM-dd")
      String dob = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '';

      // For predefined images, we'll need to pass the URL instead of the Uint8List
      // Your AuthController would need to be modified to handle this case

      image = selectedImageType == 'custom' ? image : null;
      var imageUrl = selectedImageType != 'custom'
          ? profileImageOptions[selectedImageType]
          : null;

      await _authController
          .signUpUser(
              email,
              phoneNumber.text,
              fullName,
              password,
              imageData,
              imageUrl,
              selectedImageType,
              dob,
              villageTown,
              countryValue!,
              cityValue!,
              stateValue!,
              address,
              hospital)
          .whenComplete(() {
        setState(() {
          _formKey.currentState!.reset();
          isLoading = false;
        });
      });
      showSnackMessage(context, 'ACCOUNT_CREATED');

      // Navigate to the sign-in screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  onTap: () {},
                )),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      return showSnackMessage(context, 'POPULATE_FIELDS');
    }
  }

  selectingImage() async {
    Uint8List? im = await _authController.pickProfileImage(ImageSource.gallery);
    if (im !=null) {
      setState(() {
        image = im;
        selectedImageType = 'custom';
      });
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: AutoText(
                    "VALIDATION_Q_3",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey,
                        letterSpacing: 1),
                  ),
                ),
                // Modified profile picture section
                Column(
                  children: [
                    Stack(
                      children: [
                        selectedImageType == 'custom' && image != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundImage: MemoryImage(image!),
                              )
                            : CircleAvatar(
                                radius: 64,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundImage: AssetImage(
                                    profileImageOptions[selectedImageType]!),
                              ),
                        Positioned(
                          right: 0,
                          top: 5,
                          child: IconButton(
                            onPressed: () {
                              selectingImage();
                            },
                            icon: Icon(CupertinoIcons.photo),
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    AutoText(
                      'CHOOSE_PROFILE_STYLE',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      onPressed: () {
                        selectingImage();
                      },
                      icon: Icon(Icons.add_a_photo),
                      label: AutoText('UPLOAD_PHOTO'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: AutoText(
                        'SELECT_SAMPLES',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return autoI8lnGen.translate("P_E_M");
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("LOGIN_VALIDATION_4"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return autoI8lnGen.translate("P_FF_E");
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      fullName = value;
                    },
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("E_F_N"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: autoI8lnGen.translate("DOB"),
                          hintText: _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : autoI8lnGen.translate("S_D_A"),
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return autoI8lnGen.translate("P_S_DOB");
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return autoI8lnGen.translate("VALIDATION_Q_2");
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      hospital = value;
                    },
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate("HOSPITAL"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      print(number.phoneNumber);
                    },
                    onInputValidated: (bool value) {
                      print(value);
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    initialValue: number,
                    textFieldController: phoneNumber,
                    formatInput: true,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(),
                    onSaved: (PhoneNumber number) {
                      print('On Saved: $number');
                    },
                  ),
                ),
                AutoText(
                  'LOCATION',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CSCPickerPlus(

                        onCountryChanged: (value) {
                          setState(() {
                            countryValue = value;
                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            stateValue = value;
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            cityValue = value;
                          });
                        },
                      ),
                      TextFormField(
                        onChanged: (value) {
                          villageTown = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return autoI8lnGen.translate("VALIDATION_2");
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          label: AutoText(
                            "VALIDATION_Q",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      TextFormField(
                        onChanged: (value) {
                          address = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return autoI8lnGen.translate("VALIDATION_1");
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          label: AutoText(
                            'STREET',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      Padding(
                        padding:  EdgeInsets.all(10.0),
                        child: TextFormField(
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return autoI8lnGen.translate("P_E_P");
                            }
                            // Check password length - minimum 6 characters
                            if (value.length < 6) {
                              return autoI8lnGen.translate("P_E_6_H");
                            }
                            // Check if password is only numbers
                            if (RegExp(r'^\d+$').hasMatch(value) &&
                                value.length < 8) {
                              return autoI8lnGen.translate("N_P_8");
                            }
                            // Optional: Check for password strength
                            if (!RegExp(r'[A-Z]').hasMatch(value) ||
                                !RegExp(r'[a-z]').hasMatch(value) ||
                                !RegExp(r'[0-9]').hasMatch(value)) {
                              return autoI8lnGen.translate("P_S_C_U");
                            }
                            return null;
                          },
                          onChanged: (value) {
                            password = value;
                          },
                          decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("PASSWORD"),
                            helperText:
                            autoI8lnGen.translate("PASSWORD_V"),
                            helperMaxLines: 2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      )
                      // Padding(
                      //   padding: const EdgeInsets.all(10.0),
                      //   child: TextFormField(
                      //     obscureText: _obscureText, // Use the state variable
                      //     validator: (value) {
                      //       if (value!.isEmpty) {
                      //         return 'Please Password field is empty';
                      //       } else {
                      //         return null;
                      //       }
                      //     },
                      //     onChanged: (value) {
                      //       password = value;
                      //     },
                      //     decoration: InputDecoration(
                      //       labelText: 'Password',
                      //       suffixIcon: IconButton(
                      //         icon: Icon(
                      //           _obscureText
                      //               ? Icons
                      //                   .visibility // Show eye icon when text is obscured
                      //               : Icons
                      //                   .visibility_off, // Show crossed eye icon when text is visible
                      //         ),
                      //         onPressed: () {
                      //           setState(() {
                      //             _obscureText =
                      //                 !_obscureText; // Toggle the obscure text state
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                GestureDetector(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Sbuttons(
                          onTap: () {
                            _signUpUser();
                          },
                          text: 'REGISTER'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
