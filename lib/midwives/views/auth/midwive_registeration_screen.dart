import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jambomama_nigeria/midwives/contollers/controllers.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class MidwiveResgisteratioScreen extends StatefulWidget {
  const MidwiveResgisteratioScreen({super.key});

  @override
  State<MidwiveResgisteratioScreen> createState() =>
      _MidwiveResgisteratioScreenState();
}

class _MidwiveResgisteratioScreenState
    extends State<MidwiveResgisteratioScreen> {
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'NG');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MidwifeController _controller = MidwifeController();
  late String fullName;
  late String email;
  final TextEditingController phoneNumber = TextEditingController();
  late String healthFacility;
  late String position;
  late String qualificationNumber;
  String? countryValue;

  String? cityValue;

  String? stateValue;
  late String villageTown;

  Uint8List? image;
  bool _isImageSelected = false;

  selectImageFromGallery() async {
    final Uint8List? im = await _controller.pickMidwifeImage(ImageSource.gallery);

    if (im != null) {
      setState(() {
        image = im;
        _isImageSelected = true;
      });
    } else {
      // Optional: handle if user cancelled the image picker
      print("No image selected.");
    }
  }

  _saveMidwifeData() async {
    EasyLoading.show(status: autoI8lnGen.translate("LOADING_TEXT"),);
    if (_formKey.currentState!.validate()) {
      if (!_isImageSelected) {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoText("SELECT_PICTURE")),
        );
        return;
      }
      await _controller
          .saveMidWife(
              fullName,
              email,
              phoneNumber.text,
              healthFacility,
              position,
              qualificationNumber,
              countryValue!,
              stateValue!,
              cityValue!,
              villageTown,
              image)
          .whenComplete(() {
        EasyLoading.dismiss();
      });

      _formKey.currentState?.reset();
      image = null;
      _isImageSelected = false;
      print('Clicked');
    } else {
      print('Not so good');
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.red,
            toolbarHeight: 200,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraint) {
                return FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey, Colors.red, Colors.grey],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: image != null
                                ? Image.memory(
                                    image!,
                                    fit: BoxFit.cover,
                                  )
                                : IconButton(
                                    onPressed: () {
                                      selectImageFromGallery();
                                    },
                                    icon: Icon(Icons.photo),
                                  ),
                          ),
                          if (!_isImageSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: AutoText(
                                'PP_REQUIRED',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AutoText(
                      'P_INFO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        fullName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return autoI8lnGen.translate("VALIDATION_Q_9");
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        label: AutoText('VALIDATION_Q_10'),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return autoI8lnGen.translate("VALIDATION_Q_11");
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        label: AutoText('EMAIL'),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        healthFacility = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return autoI8lnGen.translate("VALIDATION_Q_12");
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: AutoText("VALIDATION_Q_13"),
                          hintText: autoI8lnGen.translate("VALIDATION_Q_14")),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        position = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return autoI8lnGen.translate("VALIDATION_Q_8");
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: AutoText('VALIDATION_Q_6'),
                          hintText: autoI8lnGen.translate("VALIDATION_Q_7")),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        qualificationNumber = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return autoI8lnGen.translate("VALIDATION_Q_5");
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: AutoText('QUALIFICATION_TXT'),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    AutoText(
                      'L_SERVICE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                          return autoI8lnGen.translate("VALIDATION_Q_4");
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        label: AutoText(
                          'VILLAGE_TOWN',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        _saveMidwifeData();
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: AutoText(
                            'SAVE',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
