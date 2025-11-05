import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:jambomama_nigeria/components/fyp_component.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';
import 'package:jambomama_nigeria/utils/language_helper.dart';

class Baby extends StatefulWidget {
  const Baby({super.key});

  @override
  State<Baby> createState() => _BabyState();
}

class _BabyState extends State<Baby> {
  List<Map<String, dynamic>> babyDevelopmentContent = [];
  bool isLoading = true;
  String errorMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadBabyDevelopmentContent();
  }

  Future<List<Map<String, dynamic>>> getBabyDevelopmentContent() async {
    try {
      // Get selected language
      String userLanguage = await LanguageHelper.getCurrentLanguage();

      // Fetch from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('content')
          .where('type', isEqualTo: 'educative')
          .where('subType', isEqualTo: 'baby_development')
          .where('module', isEqualTo: 'mothers')
          .where('isActive', isEqualTo: true)
          .get();

      // Extract data in user’s language
      List<Map<String, dynamic>> result = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'imageUrl': data['imageUrl'] ?? '',
          'displayOrder': data['displayOrder'] ?? 0,
          'timeText':
              LanguageHelper.getTranslatedText(data['timeText'], userLanguage),
          'title':
              LanguageHelper.getTranslatedText(data['title'], userLanguage),
          'firstParagraph': LanguageHelper.getTranslatedText(
              data['firstParagraph'], userLanguage),
          'secParagraph': LanguageHelper.getTranslatedText(
              data['secParagraph'], userLanguage),
          'thirdParagraph': LanguageHelper.getTranslatedText(
              data['thirdParagraph'], userLanguage),
        };
      }).toList();

      // Sort by display order
      result.sort((a, b) {
        int orderA = a['displayOrder'] ?? 0;
        int orderB = b['displayOrder'] ?? 0;
        return orderA.compareTo(orderB);
      });

      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _loadBabyDevelopmentContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final content = await getBabyDevelopmentContent();

      setState(() {
        babyDevelopmentContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = autoI8lnGen.translate('FAILED_L_C ${e.toString()}');
        isLoading = false;
      });
    }
  }

  void navToYouPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const You()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoText(
          "FOLLOW_PREGNANCY",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red[600], fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBabyDevelopmentContent,
                        child: const AutoText('RETRY'),
                      ),
                    ],
                  ),
                )
              : babyDevelopmentContent.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.baby_changing_station,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const AutoText('N_B_D_A'),
                          // const Text(
                          //   'No content available',
                          //   style: TextStyle(fontSize: 16, color: Colors.grey),
                          // ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadBabyDevelopmentContent,
                            icon: const Icon(Icons.refresh),
                            label: const AutoText('RETRY'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const PageScrollPhysics(),
                      itemCount: babyDevelopmentContent.length,
                      itemBuilder: (context, index) {
                        final content = babyDevelopmentContent[index];
                        return Fypcomponent(
                          timetext: content['timeText'] ?? '',
                          title: content['title'] ?? '',
                          imagePath: content['imageUrl'] ?? '',
                          firstparagraph: content['firstParagraph'] ?? '',
                          secparagraph: content['secParagraph'] ?? '',
                          thirdparagraph: content['thirdParagraph'] ?? '',
                          baby: 'BABY',
                          you: 'YOU',
                          onTap: () {},
                          onClick: navToYouPage,
                        );
                      },
                    ),
    );
  }
}


// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jambomama_nigeria/components/fyp_component.dart';
// import 'package:jambomama_nigeria/views/mothers/you.dart';

// class Baby extends StatefulWidget {
//   const Baby({super.key});

//   @override
//   State<Baby> createState() => _BabyState();
// }

// class _BabyState extends State<Baby> {
//   List<Map<String, dynamic>> babyDevelopmentContent = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     print('Baby widget initState called');
//     _loadBabyDevelopmentContent();
//   }

//   Future<List<Map<String, dynamic>>> getBabyDevelopmentContent() async {
//     try {
//       print('Fetching baby development content...');

//       // First, try to get ANY document from the content collection
//       QuerySnapshot testSnapshot =
//           await _firestore.collection('content').limit(5).get();
//       print(
//           'Test query - Found ${testSnapshot.docs.length} total documents in content collection');

//       for (var doc in testSnapshot.docs) {
//         print('Document ${doc.id}: ${doc.data()}');
//       }

//       // Try the query without orderBy first to see if we get data
//       QuerySnapshot snapshot = await _firestore
//           .collection('content')
//           .where('type', isEqualTo: 'educative')
//           .where('subType', isEqualTo: 'baby_development')
//           .where('module', isEqualTo: 'mothers')
//           .where('isActive', isEqualTo: true)
//           .get();

//       print('Query without orderBy - Found ${snapshot.docs.length} documents');

//       List<Map<String, dynamic>> result = snapshot.docs.map((doc) {
//         Map<String, dynamic> data = {
//           'id': doc.id,
//           ...doc.data() as Map<String, dynamic>
//         };
//         print('Document data: $data');
//         return data;
//       }).toList();

//       // Sort manually by displayOrder
//       result.sort((a, b) {
//         int orderA = a['displayOrder'] ?? 0;
//         int orderB = b['displayOrder'] ?? 0;
//         return orderA.compareTo(orderB);
//       });

//       print('Sorted ${result.length} documents by displayOrder');
//       return result;
//     } catch (e) {
//       print('Error fetching baby development content: $e');
//       throw e; // Re-throw to be caught by the calling method
//     }
//   }

//   Future<void> _loadBabyDevelopmentContent() async {
//     print('_loadBabyDevelopmentContent called');
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = '';
//       });

//       print('About to call getBabyDevelopmentContent');
//       final content = await getBabyDevelopmentContent();
//       print('getBabyDevelopmentContent returned ${content.length} items');

//       setState(() {
//         babyDevelopmentContent = content;
//         isLoading = false;
//       });

//       print(
//           'State updated - isLoading: $isLoading, content length: ${babyDevelopmentContent.length}');
//     } catch (e) {
//       print('Error in _loadBabyDevelopmentContent: $e');
//       setState(() {
//         errorMessage = autoI8lnGen.translate('FAILED_L_C ${e.toString()}');
//         isLoading = false;
//       });
//     }
//   }

//   void navToYouPage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const You()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(
//         'Baby widget build called - isLoading: $isLoading, errorMessage: $errorMessage, content length: ${babyDevelopmentContent.length}');

//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText(
//           "FOLLOW_PREGNANCY",
//           style: TextStyle(fontSize: 16),
//         ),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : errorMessage.isNotEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64,
//                         color: Colors.red[400],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         errorMessage,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.red[600],
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadBabyDevelopmentContent,
//                         child: const AutoText('RETRY'),
//                       ),
//                     ],
//                   ),
//                 )
//               : babyDevelopmentContent.isEmpty
//                   ? const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.baby_changing_station,
//                             size: 64,
//                             color: Colors.grey,
//                           ),
//                           SizedBox(height: 16),
//                           AutoText(
//                             'N_B_D_A',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       physics: const PageScrollPhysics(),
//                       itemCount: babyDevelopmentContent.length,
//                       itemBuilder: (context, index) {
//                         final content = babyDevelopmentContent[index];

//                         return Fypcomponent(
//                           timetext: content['timeText'] ?? '',
//                           imagePath: content['imageUrl'] ?? '',
//                           firstparagraph: content['firstParagraph'] ?? '',
//                           secparagraph: content['secParagraph'] ?? '',
//                           thirdparagraph: content['thirdParagraph'] ?? '',
//                           baby: 'BABY',
//                           you: 'YOU',
//                           onTap: () {
//                             // Handle baby tab tap if needed
//                           },
//                           onClick: navToYouPage,
//                         );
//                       },
//                     ),
//     );
//   }
// }
