// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jambomama_midwives/midwives/models/midwife_user_models.dart';

// class GetMidwifeDataFromFireStore {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // Stream to fetch a single user document by ID
//   Stream<MidWifeUserModels?> getUserById(String userId) {
//     return _db.collection('users').doc(userId).snapshots().map((snapshot) {
//       if (snapshot.exists) {
//         return MidWifeUserModels.fromFirestore(snapshot);
//       }
//       return null;
//     });
//   }
// }
