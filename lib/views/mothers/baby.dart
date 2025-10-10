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
        errorMessage = 'Failed to load content: ${e.toString()}';
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
                        child: const Text('Retry'),
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
                          const Text(
                            'No content available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadBabyDevelopmentContent,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
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
                          baby: 'Baby',
                          you: 'You',
                          onTap: () {},
                          onClick: navToYouPage,
                        );
                      },
                    ),
    );
  }
}
