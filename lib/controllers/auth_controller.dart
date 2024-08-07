import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  uploadProfileImageToStorage(Uint8List image) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('ProfilePictures')
        .child(_auth.currentUser!.uid);

    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();

    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print('No Image Selected');
    }
  }

  Future<String> signUpUser(String email, String phoneNumber, String fullName,
      String password, Uint8List? image) async {
    String res = 'Something went wrong';

    try {
      if (email.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          fullName.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        //Create User
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String profileImageURL = await uploadProfileImageToStorage(image);

        await _firestore.collection('New Mothers').doc(cred.user!.uid).set({
          'email': email,
          'phone number': phoneNumber,
          'full name': fullName,
          'motherId': cred.user!.uid,
          'address': '',
          'profileImage': profileImageURL,
        });
        res = ' success';
      } else {
        res = ' Field(s) Must not be empty ';
      }
    } catch (e) {}

    return res;
  }

  loginUser(String email, String password) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please, field must not be empty';
      }
      ;
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }

  
}
