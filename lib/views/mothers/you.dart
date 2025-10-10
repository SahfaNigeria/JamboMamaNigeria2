import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/components/fyp_component.dart';
import 'package:jambomama_nigeria/views/mothers/baby.dart';
import 'package:jambomama_nigeria/utils/language_helper.dart';

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
    _loadPregnancyJourneyContent();
  }

  Future<List<Map<String, dynamic>>> getPregnancyJourneyContent() async {
    try {
      // Get what language user selected
      String userLanguage = await LanguageHelper.getCurrentLanguage();

      // Get data from Firebase
      QuerySnapshot snapshot = await _firestore
          .collection('content')
          .where('type', isEqualTo: 'educative')
          .where('subType', isEqualTo: 'pregnancy_journey')
          .where('module', isEqualTo: 'mothers')
          .where('isActive', isEqualTo: true)
          .get();

      // Process each document to extract correct language
      List<Map<String, dynamic>> result = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Extract text in user's language using the helper
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

  Future<void> _loadPregnancyJourneyContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final content = await getPregnancyJourneyContent();

      setState(() {
        pregnancyJourneyContent = content;
        isLoading = false;
      });
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: AutoText(
          "FOLLOW_YOUR_PREGNANCY",
          style: const TextStyle(fontSize: 16),
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
                        onPressed: _loadPregnancyJourneyContent,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : pregnancyJourneyContent.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pregnant_woman,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          AutoText(
                            'NO_CONTENT_AVAILABLE',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadPregnancyJourneyContent,
                            icon: const Icon(Icons.refresh),
                            label: AutoText('RETRY'),
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
                          title: content['title'] ?? '',
                          imagePath: content['imageUrl'] ?? '',
                          firstparagraph: content['firstParagraph'] ?? '',
                          secparagraph: content['secParagraph'] ?? '',
                          thirdparagraph: content['thirdParagraph'] ?? '',
                          baby: "BABY",
                          you: "YOU",
                          onTap: navToBabyPage,
                          onClick: () {},
                        );
                      },
                    ),
    );
  }
}
