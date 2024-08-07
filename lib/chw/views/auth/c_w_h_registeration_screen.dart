import 'dart:typed_data';

import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jambomama_nigeria/chw/controllers/controllers.dart';

class C_W_H_Registration_Screen extends StatefulWidget {
  const C_W_H_Registration_Screen({super.key});

  @override
  State<C_W_H_Registration_Screen> createState() =>
      _C_W_H_Registration_ScreenState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class _C_W_H_Registration_ScreenState extends State<C_W_H_Registration_Screen> {
  final CwhController _controller = CwhController();
  Uint8List? image;
  late String fullName;
  late String email;
  late String phoneNumber;
  late String healthFacility;
  late String position;
  late String qualificationNumber;
  late String villageTown;
  late String countryValue;
  late String cityValue;
  late String stateValue;

  selectImageFromGallery() async {
    Uint8List im = await _controller.pickCwhImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
    print('Clicked');
  }

  _saveCwhData() async {
    EasyLoading.show(status: 'loading...');
    if (_formKey.currentState!.validate()) {
      await _controller
          .saveCwh(
              fullName,
              email,
              phoneNumber,
              healthFacility,
              position,
              qualificationNumber,
              countryValue,
              stateValue,
              cityValue,
              villageTown,
              image)
          .whenComplete(() {
        EasyLoading.dismiss();
      });

      setState(() {
        _formKey.currentState!.reset();
        image = null;
      });
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
          toolbarHeight: 200,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              return FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: image != null
                              ? Image.memory(
                                  image!,
                                  fit: BoxFit.cover,
                                )
                              : IconButton(
                                  onPressed: () {
                                    selectImageFromGallery();
                                  },
                                  icon: Icon(CupertinoIcons.photo),
                                ),
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )
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
                  Text(
                    'Personal Info',
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
                        return 'Please, Fill the name field';
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text('Full Name'),
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
                        return 'Please, Fill the email field';
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: Text('Email'),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please, Fill the Phone Number field';
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text('Phone Number'),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      healthFacility = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please, Fill the Health Facility field';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        label: Text('Health Facility'),
                        hintText: 'Where do you work? '),
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
                        return 'Please, Fill the Position field';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        label: Text('Position'),
                        hintText: 'Community Health Provider'),
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
                        return 'Please, fill the Qualification Number field';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      label: Text('Qualification Number'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Location of Service',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SelectState(
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
                        'Village and Town',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  InkWell(
                    onTap: () {
                      _saveCwhData();
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Save',
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
    ));
  }
}
