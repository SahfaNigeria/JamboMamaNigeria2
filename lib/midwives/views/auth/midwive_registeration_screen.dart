import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:image_picker/image_picker.dart';
import 'package:jambomama_nigeria/midwives/contollers/controllers.dart';

class MidwiveResgisteratioScreen extends StatefulWidget {
  const MidwiveResgisteratioScreen({super.key});

  @override
  State<MidwiveResgisteratioScreen> createState() =>
      _MidwiveResgisteratioScreenState();
}

class _MidwiveResgisteratioScreenState
    extends State<MidwiveResgisteratioScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MidwifeController _controller = MidwifeController();
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
  Uint8List? image;

  selectImageFromGallery() async {
    Uint8List im = await _controller.pickMidwifeImage(ImageSource.gallery);
    setState(() {
      image = im;
    });
  }

  _saveMidwifeData() async {
    EasyLoading.show(status: 'loading...');
    if (_formKey.currentState!.validate()) {
      await _controller
          .saveMidWife(
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
                          hintText: 'Where you work'),
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
                          hintText: 'Are you a Doctor, Nurse or a Midwife'),
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
                          return 'Please, Fill the Qualification Number field';
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
      ),
    );
  }
}
