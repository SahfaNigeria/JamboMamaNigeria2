import 'package:cloud_firestore/cloud_firestore.dart';

// Future<String> getUserName(
//     String userId, String collection, String nameField) async {
//   DocumentSnapshot doc =
//       await FirebaseFirestore.instance.collection(collection).doc(userId).get();

//   return doc[nameField]; // Use the field name provided
// }

// Future<String> getUserName(String userId, String collection, String nameField) async {
//   try {
//     DocumentSnapshot doc = await FirebaseFirestore.instance
//         .collection(collection)
//         .doc(userId)
//         .get();

//     if (doc.exists && doc.data()!.containsKey(nameField)) {
//       return doc[nameField];
//     } else {
//       return 'Name could not be fetched';
//     }
//   } catch (e) {
//     print('Error fetching user name: $e');
//     return 'Name could not be fetched';
//   }
// }

Future<String> getUserName(
    String userId, String collection, String nameField) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .get();

    // Cast doc.data() to Map<String, dynamic> before accessing the fields
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data.containsKey(nameField)) {
      return data[nameField];
    } else {
      return 'Name could not be fetched';
    }
  } catch (e) {
    print('Error fetching user name: $e');
    return 'Name could not be fetched';
  }
}
