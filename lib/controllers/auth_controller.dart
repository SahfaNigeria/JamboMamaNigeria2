import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  Future<void> subscribeToRoleTopic(String role) async {
    if (role == 'health_provider') {
      await FirebaseMessaging.instance.subscribeToTopic('health_provider');
    } else if (role == 'mother') {
      await FirebaseMessaging.instance.subscribeToTopic('mother');
    }
  }

  Future<String> signUpUser(
      String email,
      String phoneNumber,
      String fullName,
      String password,
      Uint8List? imageData,
      String? imageUrl,
      String imageType,
      String dob,
      String villageTown,
      String countryValue,
      String cityValue,
      String stateValue,
      String address,
      String hospital) async {
    String res = 'Something went wrong';

    try {
      if (email.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          fullName.isNotEmpty &&
          password.isNotEmpty) {
        //Create User
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // Handle profile image based on type
        String profileImageURL;
        
        if (imageType == 'custom' && imageData != null) {
          // Upload custom image
          profileImageURL = await uploadProfileImageToStorage(imageData);
        } else if (imageUrl != null && imageType != 'custom') {
          // Use provided URL for predefined image types
          profileImageURL = imageUrl;
        } else {
          // Fallback to default image
          profileImageURL = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKoG2KJEveyKK8EKskB-dCbipr_Qs3xGLhx90LQgs9sg&s';
        }

        await _firestore.collection('New Mothers').doc(cred.user!.uid).set({
          'email': email,
          'phone number': phoneNumber,
          'address': address,
          'hospital': hospital,
          'full name': fullName,
          'motherId': cred.user!.uid,
          'profileImage': profileImageURL,
          'profileImageType': imageType, // Save the image type selection
          'dateOfBirth': dob,
          'villageTown': villageTown,
          'countryValue': countryValue,
          'stateValue': stateValue,
          'cityValue': cityValue,
        });

        // Subscribe the user to the 'mother' topic
        await subscribeToRoleTopic('mother');
        res = ' success';
      } else {
        res = ' Field(s) Must not be empty ';
      }
    } catch (e) {
      print('Error in signUpUser: $e');
      res = e.toString();
    }

    return res;
  }

  Future<String> loginUser(
    String email,
    String password,
    BuildContext context,
    Function setLoading,
  ) async {
    String res = 'Some error occurred';

    print("Login Attempt: Email -> $email, Password -> (hidden)");

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        print("Fields are not empty, proceeding with login...");

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          print("Login successful for user: ${user.uid}");

          // Check user type and navigate
          await _checkUserTypeAndNavigate(user, context, setLoading);

          // Fetch user role from Firestore
          DocumentSnapshot newMotherDoc =
              await _firestore.collection('New Mothers').doc(user.uid).get();
          DocumentSnapshot healthProfessionalDoc = await _firestore
              .collection('Health Professionals')
              .doc(user.uid)
              .get();

          if (newMotherDoc.exists) {
            print("User is a Mother, subscribing to 'mother' topic.");
            await subscribeToRoleTopic('mother');
          } else if (healthProfessionalDoc.exists) {
            print(
                "User is a Health Provider, subscribing to 'health_provider' topic.");
            await subscribeToRoleTopic('health_provider');
          } else {
            print(
                "User not found in 'New Mothers' or 'Health Professionals' collections.");
          }

          // Save FCM token
          print("Saving FCM token...");
          await saveFcmToken();
          print("FCM token saved successfully.");

          res = 'success';
        } else {
          print("Login failed: User not found.");
          res = 'User not found';
          setLoading(false);
        }
      } else {
        print("Login failed: One or more fields are empty.");
        res = 'Please, fields must not be empty';
        setLoading(false);
      }
    } catch (e) {
      print("Error during login: $e");
      res = e.toString();
      setLoading(false);
    }

    return res;
  }

  // Save FCM token function
  Future<void> saveFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      if (token != null && userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ FCM token saved successfully: $token');
      } else {
        print('❌ Failed to save FCM token: token or userId is null');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }


  Future<void> _checkUserTypeAndNavigate(
      User user, BuildContext context, Function setLoading) async {
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
          // After showing the snackbar, set isLoading to false
          setLoading(false);
        }
      } else {
        print("User not found in either collection");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not found")),
        );
        setLoading(false);
      }
    } catch (e) {
      print("Error checking user type: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking user type: $e")),
      );
      setLoading(false);
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