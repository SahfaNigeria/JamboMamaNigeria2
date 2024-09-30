import 'dart:typed_data';
import 'package:intl/intl.dart'; // For formatting the date
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jambomama_nigeria/components/button.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart';
import 'package:csc_picker/csc_picker.dart';
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

  late String confirmPassword;

  bool isLoading = false;

  late String villageTown;

  String? countryValue;

  String? cityValue;

  String? stateValue;

  late String address;

  late String hospital;

  Uint8List? image;

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
      await _authController
          .signUpUser(
              email,
              phoneNumber.text,
              fullName,
              password,
              image,
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
      showSnackMessage(context, 'Your account has been created');

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
      return showSnackMessage(context, 'Please, populate the field(s)');
    }
  }

  selectingImage() async {
    Uint8List im = await _authController.pickProfileImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
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
                  child: Text(
                    "Mother's Registration",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey,
                        letterSpacing: 1),
                  ),
                ),
                Stack(
                  children: [
                    image != null
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
                            backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKoG2KJEveyKK8EKskB-dCbipr_Qs3xGLhx90LQgs9sg&s'),
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
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'You can optionally add a profile picture',
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
                        return 'Please Email field is empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please Fullname field is empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      fullName = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Full Name',
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
                          labelText: 'Date of Birth',
                          hintText: _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Select Date',
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Please select your Date of Birth';
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
                        return 'Please Hospital field is empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      hospital = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Hosptal',
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
                Text(
                  'Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CSCPicker(
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
                            return 'Please, Fill the Town & Village field';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          label: Text(
                            'Town or Village',
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
                            return 'Please, Fill the Address field';
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          label: Text(
                            'Street',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(10.0),
                      //   child: TextFormField(
                      //     obscureText: true,
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
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          obscureText: _obscureText, // Use the state variable
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please Password field is empty';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            password = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons
                                        .visibility // Show eye icon when text is obscured
                                    : Icons
                                        .visibility_off, // Show crossed eye icon when text is visible
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText =
                                      !_obscureText; // Toggle the obscure text state
                                });
                              },
                            ),
                          ),
                        ),
                      ),
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
                          text: 'Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
