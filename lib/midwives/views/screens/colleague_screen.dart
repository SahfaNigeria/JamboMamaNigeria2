import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/screens/practitioners_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ColleagueList extends StatefulWidget {
  final String location;

  ColleagueList({required this.location});

  @override
  _ColleagueListState createState() => _ColleagueListState();
}

class _ColleagueListState extends State<ColleagueList> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _allProfessionals = [];
  List<DocumentSnapshot> _filteredProfessionals = [];

  @override
  void initState() {
    super.initState();
    fetchHealthcareProfessionals(widget.location);
    _searchController.addListener(_filterProfessionals);
  }

  Future<void> fetchHealthcareProfessionals(String location) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Health Professionals')
        .where('professional', isEqualTo: 'professional')
        .where('cityValue', isEqualTo: location)
        .where('approved', isEqualTo: true)
        .get();

    setState(() {
      // Filter out the current user from the results
      _allProfessionals = querySnapshot.docs.where((doc) {
        return doc['midWifeId'] != currentUserId;
      }).toList();
      _filteredProfessionals = _allProfessionals;
    });
  }

  void _filterProfessionals() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProfessionals = _allProfessionals.where((doc) {
        String fullName = (doc['fullName'] as String).toLowerCase();
        String position = (doc['position'] as String).toLowerCase();
        return fullName.contains(query) || position.contains(query);
      }).toList();
    });
  }

  String generateChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('COLLEAGUES'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: autoI8lnGen.translate("SEARCHBYNAMEORPOSITION"),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProfessionals.isEmpty
                ? Center(child: AutoText('ERROR_3'))
                : ListView.builder(
                    itemCount: _filteredProfessionals.length,
                    itemBuilder: (context, index) {
                      var professional = _filteredProfessionals[index];
                      String professionalId = professional['midWifeId'];

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: professional['midWifeImage'] != null &&
                                        professional['midWifeImage'].isNotEmpty
                                    ? Image.network(
                                        professional['midWifeImage'],
                                        height: 50.0,
                                        width: 50.0,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text(
                                        professional['fullName'],
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            professional['position'],
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        Text(','),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            professional['healthFacility'],
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 183, 164, 164)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.chat, color: Colors.red),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfessionalChatScreen(
                                        chatId: generateChatId(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            professionalId),
                                        recipientName: professional['fullName'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/practitioners_chat_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ColleagueList extends StatefulWidget {
//   final String location;

//   ColleagueList({required this.location});

//   @override
//   _ColleagueListState createState() => _ColleagueListState();
// }

// class _ColleagueListState extends State<ColleagueList> {
//   TextEditingController _searchController = TextEditingController();
//   List<DocumentSnapshot> _allProfessionals = [];
//   List<DocumentSnapshot> _filteredProfessionals = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchHealthcareProfessionals(widget.location);
//     _searchController.addListener(_filterProfessionals);
//   }

//   Future<void> fetchHealthcareProfessionals(String location) async {
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('Health Professionals')
//         .where('professional', isEqualTo: 'professional')
//         .where('cityValue', isEqualTo: location)
//         .where('approved', isEqualTo: true)
//         .get();

//     setState(() {
//       _allProfessionals = querySnapshot.docs;
//       _filteredProfessionals = _allProfessionals;
//     });
//   }

//   void _filterProfessionals() {
//     String query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredProfessionals = _allProfessionals.where((doc) {
//         String fullName = (doc['fullName'] as String).toLowerCase();
//         String position = (doc['position'] as String).toLowerCase();
//         return fullName.contains(query) || position.contains(query);
//       }).toList();
//     });
//   }

//   String generateChatId(String userId1, String userId2) {
//     return userId1.hashCode <= userId2.hashCode
//         ? '${userId1}_$userId2'
//         : '${userId2}_$userId1';
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('COLLEAGUES'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: autoI8lnGen.translate("SEARCHBYNAMEORPOSITION"),
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _filteredProfessionals.isEmpty
//                 ? Center(child: AutoText('ERROR_3'))
//                 : ListView.builder(
//                     itemCount: _filteredProfessionals.length,
//                     itemBuilder: (context, index) {
//                       var professional = _filteredProfessionals[index];
//                       String professionalId = professional['midWifeId'];

//                       return Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Container(
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(50),
//                                 child: professional['midWifeImage'] != null &&
//                                         professional['midWifeImage'].isNotEmpty
//                                     ? Image.network(
//                                         professional['midWifeImage'],
//                                         height: 50.0,
//                                         width: 50.0,
//                                         fit: BoxFit.cover,
//                                       )
//                                     : Icon(
//                                         Icons.person,
//                                         size: 40,
//                                         color: Colors.grey.shade400,
//                                       ),
//                               ),
//                               SizedBox(width: 20),
//                               Expanded(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(1.0),
//                                       child: Text(
//                                         professional['fullName'],
//                                         style: TextStyle(color: Colors.grey),
//                                       ),
//                                     ),
//                                     Row(
//                                       children: [
//                                         Flexible(
//                                           child: Text(
//                                             professional['position'],
//                                             style:
//                                                 TextStyle(color: Colors.grey),
//                                           ),
//                                         ),
//                                         Text(','),
//                                         SizedBox(width: 5),
//                                         Expanded(
//                                           child: Text(
//                                             professional['healthFacility'],
//                                             style: TextStyle(
//                                                 color: Color.fromARGB(
//                                                     255, 183, 164, 164)),
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.chat, color: Colors.red),
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           ProfessionalChatScreen(
//                                         chatId: generateChatId(
//                                             FirebaseAuth
//                                                 .instance.currentUser!.uid,
//                                             professionalId),
//                                         recipientName: professional['fullName'],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
