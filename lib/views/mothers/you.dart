import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/components/fyp_component.dart';
import 'package:jambomama_nigeria/views/mothers/baby.dart';

class You extends StatefulWidget {
  const You({super.key});

  @override
  State<You> createState() => _YouState();
}

class _YouState extends State<You> {
  List<Map<String, dynamic>> pregnancyJourneyContent = [];
  bool isLoading = true;
  String errorMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print('You widget initState called');
    _loadPregnancyJourneyContent();
  }

  Future<List<Map<String, dynamic>>> getPregnancyJourneyContent() async {
    try {
      print('Fetching pregnancy journey content...');

      QuerySnapshot testSnapshot =
          await _firestore.collection('content').limit(5).get();
      print(
          'Test query - Found ${testSnapshot.docs.length} total documents in content collection');
      for (var doc in testSnapshot.docs) {
        print('Document ${doc.id}: ${doc.data()}');
      }

      QuerySnapshot snapshot = await _firestore
          .collection('content')
          .where('type', isEqualTo: 'educative')
          .where('subType', isEqualTo: 'pregnancy_journey')
          .where('module', isEqualTo: 'mothers')
          .where('isActive', isEqualTo: true)
          .get();

      print('Query without orderBy - Found ${snapshot.docs.length} documents');

      List<Map<String, dynamic>> result = snapshot.docs.map((doc) {
        Map<String, dynamic> data = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
        print('Document data: $data');
        return data;
      }).toList();

      result.sort((a, b) {
        int orderA = a['displayOrder'] ?? 0;
        int orderB = b['displayOrder'] ?? 0;
        return orderA.compareTo(orderB);
      });

      print('Sorted ${result.length} documents by displayOrder');
      return result;
    } catch (e) {
      print('Error fetching pregnancy journey content: $e');
      throw e;
    }
  }

  Future<void> _loadPregnancyJourneyContent() async {
    print('_loadPregnancyJourneyContent called');
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('About to call getPregnancyJourneyContent');
      final content = await getPregnancyJourneyContent();
      print('getPregnancyJourneyContent returned ${content.length} items');

      setState(() {
        pregnancyJourneyContent = content;
        isLoading = false;
      });

      print(
          'State updated - isLoading: $isLoading, content length: ${pregnancyJourneyContent.length}');
    } catch (e) {
      print('Error in _loadPregnancyJourneyContent: $e');
      setState(() {
        errorMessage = 'Failed to load content: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void navToBabyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Baby()),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'You widget build called - isLoading: $isLoading, errorMessage: $errorMessage, content length: ${pregnancyJourneyContent.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Follow your Pregnancy ",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPregnancyJourneyContent,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPregnancyJourneyContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : pregnancyJourneyContent.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pregnant_woman,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No pregnancy journey content available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const PageScrollPhysics(),
                      itemCount: pregnancyJourneyContent.length,
                      itemBuilder: (context, index) {
                        final content = pregnancyJourneyContent[index];

                        return Fypcomponent(
                          timetext: content['timeText'] ?? '',
                          imagePath: content['imageUrl'] ?? '',
                          firstparagraph: content['firstParagraph'] ?? '',
                          secparagraph: content['secParagraph'] ?? '',
                          thirdparagraph: content['thirdParagraph'] ?? '',
                          baby: 'Baby',
                          you: 'You',
                          onTap: navToBabyPage,
                          onClick: () {
                            // Handle "You" tab tap if needed
                          },
                        );
                      },
                    ),
    );
  }
}
