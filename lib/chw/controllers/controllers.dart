import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';

class CwhController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Function that picks images from device

  pickCwhImage(ImageSource source) async {
    // This Function  picks images from device
    final ImagePicker _imagePicker = ImagePicker();

    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print(' You did not select any image');
    }
  }

  //Function that picks images from device ends

  saveCwhImageToStorage(Uint8List image) async {
    // This Function saves  the image to firestore STORAGE

    Reference ref = _storage
        .ref()
        .child(
          'StoreCwhImages',
        )
        .child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }
  //Function that saves  the image to firestore STORAGE, ends

  //Function that Saves  Community Health Workers Data

  Future<String> saveCwh(
      String fullName,
      String email,
      String phoneNumber,
      String healthFacility,
      String position,
      String qualificationNumber,
      String countryValue,
      String stateValue,
      String cityValue,
      String villageTown,
      Uint8List? image) async {
    String res = 'some error occured';
    try {
      // This function Saves Registering Community Health Workers To FireStore
      String cwhImage = await saveCwhImageToStorage(image!);
      await _firestore
          .collection('Community Health Workers')
          .doc(_auth.currentUser!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'healthFacility': healthFacility,
        'position': position,
        'qualificationNumber': qualificationNumber,
        'countryValue': countryValue,
        'stateValue': stateValue,
        'cityValue': cityValue,
        'villageTown': villageTown,
        'cwhImage': cwhImage,
        'approved': false,
        'cwhId': _auth.currentUser!.uid
      });

      ;
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
  //Function that saves  Health Practitioners Info, Ends.
}
