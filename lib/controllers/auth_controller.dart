import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  Future<String> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          // Check user type and approval status
          await _checkUserTypeAndNavigate(user, context);
          res = 'success';
        } else {
          res = 'User not found';
        }
      } else {
        res = 'Please, fields must not be empty';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<void> _checkUserTypeAndNavigate(
      User user, BuildContext context) async {
    try {
      DocumentSnapshot newMotherDoc =
          await _firestore.collection('New Mothers').doc(user.uid).get();
      DocumentSnapshot healthProfessionalDoc = await _firestore
          .collection('Health Professionals')
          .doc(user.uid)
          .get();

      if (newMotherDoc.exists) {
        Navigator.pushReplacementNamed(context, '/HomePage');
      } else if (healthProfessionalDoc.exists) {
        bool isApproved = healthProfessionalDoc.get('approved') ?? false;
        if (isApproved) {
          Navigator.pushReplacementNamed(context, '/MidWifeHomePage');
        } else {
          print("Health Professional not approved");
          // Show message or handle unapproved professionals
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Health Professional not approved yet")),
          );
        }
      } else {
        print("User not found in either collection");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not found")),
        );
      }
    } catch (e) {
      print("Error checking user type: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking user type: $e")),
      );
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in');
    }

    // Check if the user is a Health Professional
    DocumentSnapshot healthDoc =
        await _firestore.collection('Health Professionals').doc(user.uid).get();

    if (healthDoc.exists) {
      return {
        'isHealthProvider': true,
        'userData': healthDoc.data(),
      };
    }

    // Check if the user is a Pregnant Woman
    DocumentSnapshot motherDoc =
        await _firestore.collection('New Mothers').doc(user.uid).get();

    if (motherDoc.exists) {
      return {
        'isHealthProvider': false,
        'userData': motherDoc.data(),
      };
    }

    // If no matching document is found
    throw Exception('User data not found');
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}
