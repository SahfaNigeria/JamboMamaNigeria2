// import 'dart:typed_data';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jambomama_nigeria/utils/session_manager.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // --- IMAGE HELPERS (Maintained logic) ---

  Future<String> uploadProfileImageToStorage(Uint8List image) async {
    Reference ref = _firebaseStorage
        .ref()
        .child('ProfilePictures')
        .child(_auth.currentUser!.uid);

    UploadTask uploadTask = ref.putData(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<Uint8List?> pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file == null) return null;

    return _file.readAsBytes();
  }

  // --- NOTIFICATION HELPERS ---

  Future<void> subscribeToRoleTopic(String role) async {
    if (role == 'health_provider') {
      await FirebaseMessaging.instance.subscribeToTopic('health_provider');
    } else if (role == 'mother') {
      await FirebaseMessaging.instance.subscribeToTopic('mother');
    }
  }

  /// Saves FCM token to the correct collection for this user.
  /// Uses merge: true so it never overwrites other user fields.
  Future<void> saveFcmToken(String collectionName) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final userId = _auth.currentUser?.uid;

      if (token == null || userId == null) return;

      await _firestore.collection(collectionName).doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently log — never block auth flow over a token write failure
      debugPrint('[FCM] saveFcmToken error: $e');
    }
  }

  Future<void> clearFcmToken(String collectionName, String userId) async {
    try {
      await _firestore.collection(collectionName).doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('[FCM] clearFcmToken error: $e');
    }
  }

  /// FIX 3: Call this once at app startup (in main.dart or root widget).
  /// Listens for FCM token rotations and keeps Firestore in sync automatically.
  void initTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Determine which collection this user belongs to, then update
      for (final collection in ['New Mothers', 'Health Professionals']) {
        try {
          final doc = await _firestore.collection(collection).doc(userId).get();
          if (doc.exists) {
            await _firestore.collection(collection).doc(userId).set({
              'fcmToken': newToken,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            debugPrint('[FCM] Token refreshed and saved to $collection');
            break;
          }
        } catch (e) {
          debugPrint('[FCM] onTokenRefresh error for $collection: $e');
        }
      }
    });
  }

  // --- SIGN UP ---

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
    String res = 'ERROR_OCCURRED';

    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    try {
      if (cleanEmail.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          fullName.isNotEmpty &&
          cleanPassword.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: cleanEmail, password: cleanPassword);

        String profileImageURL;
        if (imageType == 'custom' && imageData != null) {
          profileImageURL = await uploadProfileImageToStorage(imageData);
        } else if (imageUrl != null && imageType != 'custom') {
          profileImageURL = imageUrl;
        } else {
          profileImageURL =
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKoG2KJEveyKK8EKskB-dCbipr_Qs3xGLhx90LQgs9sg&s';
        }

        await _firestore.collection('New Mothers').doc(cred.user!.uid).set({
          'email': cleanEmail,
          'phone number': phoneNumber.trim(),
          'address': address,
          'hospital': hospital,
          'full name': fullName,
          'motherId': cred.user!.uid,
          'profileImage': profileImageURL,
          'profileImageType': imageType,
          'dateOfBirth': dob,
          'villageTown': villageTown,
          'countryValue': countryValue,
          'stateValue': stateValue,
          'cityValue': cityValue,
        });

        // FIX 2: Save FCM token immediately on sign up (was missing before)
        await saveFcmToken('New Mothers');
        await subscribeToRoleTopic('mother');

        await SessionManager.saveSession(
          isHealthProfessional: false,
          profileComplete: true,
        );

        res = 'success';
      } else {
        res = 'FIELDS_EMPTY';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = "AUTH_EMAIL_EXISTS";
      } else if (e.code == 'weak-password') {
        res = "AUTH_WEAK_PASSWORD";
      } else if (e.code == 'network-request-failed') {
        res = "CONNECTION_ERROR";
      } else {
        res = "AUTH_FAILED";
      }
    } catch (e) {
      debugPrint('[SignUp] Unexpected error: $e');
      res = "UNEXPECTED_ERROR";
    }
    return res;
  }

  // --- LOGIN ---

  Future<String> loginUser(
    String email,
    String password,
    BuildContext context,
    Function setLoading,
  ) async {
    String res = 'ERROR_OCCURRED';
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    try {
      if (cleanEmail.isNotEmpty && cleanPassword.isNotEmpty) {
        setLoading(true);

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );

        User? user = userCredential.user;
        if (user != null) {
          try {
            final results = await Future.wait([
              _firestore.collection('New Mothers').doc(user.uid).get(),
              _firestore.collection('Health Professionals').doc(user.uid).get(),
            ]).timeout(const Duration(seconds: 15));

            DocumentSnapshot newMotherDoc = results[0];
            DocumentSnapshot healthProfessionalDoc = results[1];
            if (newMotherDoc.exists) {
              // FIX 1: Added await — token must finish saving before navigation
              await saveFcmToken('New Mothers');
              await subscribeToRoleTopic('mother');
              await SessionManager.saveSession(
                isHealthProfessional: false,
                profileComplete: true,
              );
              res = 'success';
              Navigator.pushReplacementNamed(context, '/HomePage');
            } else if (healthProfessionalDoc.exists) {
              bool isApproved = healthProfessionalDoc.get('approved') ?? false;
              if (isApproved) {
                // FIX 1: Added await here too
                await saveFcmToken('Health Professionals');
                await subscribeToRoleTopic('health_provider');
                await SessionManager.saveSession(
                  isHealthProfessional: true,
                  profileComplete: true,
                );
                res = 'success';
                Navigator.pushReplacementNamed(context, '/MidWifeHomePage');
              } else {
                res = "PRO_NOT_APPROVED";
                setLoading(false);
              }
            } else {
              res = "USER_NOT_FOUND_DB";
              setLoading(false);
            }
          } on FirebaseException catch (e) {
            res = (e.code == 'unavailable')
                ? "CONNECTION_ERROR"
                : "DATABASE_ERROR";
            setLoading(false);
          }
        }
      } else {
        res = 'FIELDS_EMPTY';
        setLoading(false);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          res = "AUTH_USER_NOT_FOUND";
          break;
        case 'wrong-password':
          res = "AUTH_WRONG_PASSWORD";
          break;
        case 'network-request-failed':
          res = "CONNECTION_ERROR";
          break;
        case 'invalid-email':
          res = "AUTH_INVALID_EMAIL";
          break;
        default:
          res = "AUTH_FAILED";
      }
      setLoading(false);
    } catch (e) {
      debugPrint('[Login] Unexpected error: $e');
      res = "UNEXPECTED_ERROR";
      setLoading(false);
    }
    return res;
  }

  // --- FETCH DATA (Maintained all original logic) ---

  Future<Map<String, dynamic>> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in');
    }

    DocumentSnapshot healthDoc =
        await _firestore.collection('Health Professionals').doc(user.uid).get();

    if (healthDoc.exists) {
      return {
        'isHealthProvider': true,
        'userData': healthDoc.data(),
      };
    }

    DocumentSnapshot motherDoc =
        await _firestore.collection('New Mothers').doc(user.uid).get();

    if (motherDoc.exists) {
      return {
        'isHealthProvider': false,
        'userData': motherDoc.data(),
      };
    }

    throw Exception('User data not found');
  }

  Future<void> signOutUser() async {
    await SessionManager.clearSession();
    await _auth.signOut();
  }

  // Expose current user UID for post-signup operations
  String? get currentUserId => _auth.currentUser?.uid;
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

//   // --- IMAGE HELPERS (Maintained logic) ---

//   uploadProfileImageToStorage(Uint8List image) async {
//     Reference ref = _firebaseStorage
//         .ref()
//         .child('ProfilePictures')
//         .child(_auth.currentUser!.uid);

//     UploadTask uploadTask = ref.putData(image);
//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();
//     return downloadUrl;
//   }

//   pickProfileImage(ImageSource source) async {
//     final ImagePicker _imagePicker = ImagePicker();
//     XFile? _file = await _imagePicker.pickImage(source: source);

//     if (_file != null) {
//       return await _file.readAsBytes();
//     } else {
     
//     }
//   }

//   // --- NOTIFICATION HELPERS ---

//   Future<void> subscribeToRoleTopic(String role) async {
//     if (role == 'health_provider') {
//       await FirebaseMessaging.instance.subscribeToTopic('health_provider');
//     } else if (role == 'mother') {
//       await FirebaseMessaging.instance.subscribeToTopic('mother');
//     }
//   }

//   /// FIXED: Saves token to the SPECIFIC collection to prevent duplicates
//   Future<void> saveFcmToken(String collectionName) async {
//     try {
//       final token = await FirebaseMessaging.instance.getToken();
//       final userId = _auth.currentUser?.uid;
//       if (token == null || userId == null) return;

//       await _firestore.collection(collectionName).doc(userId).set({
//         'fcmToken': token,
//         'lastLogin': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
    
//     } catch (e) {
    
//     }
//   }

//   // --- SIGN UP (Maintained all your variable names) ---


//   Future<String> signUpUser(
//       String email,
//       String phoneNumber,
//       String fullName,
//       String password,
//       Uint8List? imageData,
//       String? imageUrl,
//       String imageType,
//       String dob,
//       String villageTown,
//       String countryValue,
//       String cityValue,
//       String stateValue,
//       String address,
//       String hospital) async {
    
//     String res = 'ERROR_OCCURRED'; // Default localized key

//     // 1. TRIM inputs to handle accidental spaces
//     final cleanEmail = email.trim();
//     final cleanPassword = password.trim();

//     try {
//       if (cleanEmail.isNotEmpty &&
//           phoneNumber.isNotEmpty &&
//           fullName.isNotEmpty &&
//           cleanPassword.isNotEmpty) {
        
//         UserCredential cred = await _auth.createUserWithEmailAndPassword(
//             email: cleanEmail, password: cleanPassword);

//         String profileImageURL;
//         if (imageType == 'custom' && imageData != null) {
//           profileImageURL = await uploadProfileImageToStorage(imageData);
//         } else if (imageUrl != null && imageType != 'custom') {
//           profileImageURL = imageUrl;
//         } else {
//           profileImageURL =
//               'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKoG2KJEveyKK8EKskB-dCbipr_Qs3xGLhx90LQgs9sg&s';
//         }

//         await _firestore.collection('New Mothers').doc(cred.user!.uid).set({
//           'email': cleanEmail,
//           'phone number': phoneNumber.trim(),
//           'address': address,
//           'hospital': hospital,
//           'full name': fullName,
//           'motherId': cred.user!.uid,
//           'profileImage': profileImageURL,
//           'profileImageType': imageType,
//           'dateOfBirth': dob,
//           'villageTown': villageTown,
//           'countryValue': countryValue,
//           'stateValue': stateValue,
//           'cityValue': cityValue,
//         });

//         await subscribeToRoleTopic('mother');
//         res = 'success'; // UI logic checks for this exact string
//       } else {
//         res = 'FIELDS_EMPTY'; // Key for "Please, fields must not be empty"
//       }
//     } on FirebaseAuthException catch (e) {
//       // Map Firebase Auth errors to your translation keys
//       if (e.code == 'email-already-in-use') {
//         res = "AUTH_EMAIL_EXISTS"; 
//       } else if (e.code == 'weak-password') {
//         res = "AUTH_WEAK_PASSWORD";
//       } else if (e.code == 'network-request-failed') {
//         res = "CONNECTION_ERROR";
//       } else {
//         res = "AUTH_FAILED";
//       }
//     } catch (e) {
  
//       res = "UNEXPECTED_ERROR";
//     }
//     return res;
//   }



//   // --- LOGIN (Optimized flow, Maintained names) ---

//   Future<String> loginUser(
//     String email,
//     String password,
//     BuildContext context,
//     Function setLoading,
//   ) async {
//     // Default error key
//     String res = 'ERROR_OCCURRED'; 
//     final cleanEmail = email.trim();
//     final cleanPassword = password.trim();
    
//     try {
//      if (cleanEmail.isNotEmpty && cleanPassword.isNotEmpty) {
//         setLoading(true);

//         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: cleanEmail, // Use trimmed version
//           password: cleanPassword, // Use trimmed version
//         );

//         User? user = userCredential.user;
//         if (user != null) {
//           try {
//             final results = await Future.wait([
//               _firestore.collection('New Mothers').doc(user.uid).get(),
//               _firestore.collection('Health Professionals').doc(user.uid).get(),
//             ]).timeout(const Duration(seconds: 15));

//             DocumentSnapshot newMotherDoc = results[0];
//             DocumentSnapshot healthProfessionalDoc = results[1];
//             final SharedPreferences prefs = await SharedPreferences.getInstance();

//             if (newMotherDoc.exists) {
//               saveFcmToken('New Mothers');
//               await subscribeToRoleTopic('mother');
//               prefs.setBool("isHealthProffessional", false);
//               res = 'success';
//               Navigator.pushReplacementNamed(context, '/HomePage');
//             } else if (healthProfessionalDoc.exists) {
//               bool isApproved = healthProfessionalDoc.get('approved') ?? false;
//               if (isApproved) {
//                 saveFcmToken('Health Professionals');
//                 await subscribeToRoleTopic('health_provider');
//                 prefs.setBool("isHealthProffessional", true);
//                 res = 'success';
//                 Navigator.pushReplacementNamed(context, '/MidWifeHomePage');
//               } else {
//                 res = "PRO_NOT_APPROVED"; // Key for "Health Professional not approved yet"
//                 setLoading(false);
//               }
//             } else {
//               res = "USER_NOT_FOUND_DB"; // Key for "User record not found in database"
//               setLoading(false);
//             }
//           } on FirebaseException catch (e) {
//             // Handle Firestore specific connection errors
//             res = (e.code == 'unavailable') ? "CONNECTION_ERROR" : "DATABASE_ERROR";
//             setLoading(false);
//           }
//         }
//       } else {
//         res = 'FIELDS_EMPTY'; // Key for "Please, fields must not be empty"
//         setLoading(false);
//       }
//     } on FirebaseAuthException catch (e) {
//       // Handle Auth specific errors mapping to your translation keys
//       switch (e.code) {
//         case 'user-not-found':
//           res = "AUTH_USER_NOT_FOUND";
//           break;
//         case 'wrong-password':
//           res = "AUTH_WRONG_PASSWORD";
//           break;
//         case 'network-request-failed':
//           res = "CONNECTION_ERROR";
//           break;
//         case 'invalid-email':
//           res = "AUTH_INVALID_EMAIL";
//           break;
//         default:
//           res = "AUTH_FAILED";
//       }
//       setLoading(false);
//     } catch (e) {
//       res = "UNEXPECTED_ERROR";
//       setLoading(false);
//     }
//     return res;
//   }

//   // --- FETCH DATA (Maintained all your original logic) ---

//   Future<Map<String, dynamic>> fetchUserData() async {
//     User? user = _auth.currentUser;
//     if (user == null) {
//       throw Exception('No user is currently logged in');
//     }

//     DocumentSnapshot healthDoc =
//         await _firestore.collection('Health Professionals').doc(user.uid).get();

//     if (healthDoc.exists) {
//       return {
//         'isHealthProvider': true,
//         'userData': healthDoc.data(),
//       };
//     }

//     DocumentSnapshot motherDoc =
//         await _firestore.collection('New Mothers').doc(user.uid).get();

//     if (motherDoc.exists) {
//       return {
//         'isHealthProvider': false,
//         'userData': motherDoc.data(),
//       };
//     }

//     throw Exception('User data not found');
//   }

//   Future<void> signOutUser() async {
//     await _auth.signOut();
//   }
// }


