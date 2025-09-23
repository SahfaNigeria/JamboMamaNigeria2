import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PractitionerContentScreen extends StatefulWidget {
  const PractitionerContentScreen({super.key});

  @override
  State<PractitionerContentScreen> createState() => _PractitionerContentScreenState();
}

class _PractitionerContentScreenState extends State<PractitionerContentScreen> {
  List<Map<String, dynamic>> healthProviderContent = [];
  bool isLoading = true;
  String errorMessage = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  @override
  void initState() {
    super.initState();
    _loadHealthProviderContent();
  }

  Future<List<Map<String, dynamic>>> getHealthProviderContent() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('content')
          .where('type', isEqualTo: 'educative')
          .where('subType', isEqualTo: 'health_tips')
          .where('module', isEqualTo: 'health_providers')
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> result = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      // Sort by createdAt if available, otherwise by displayOrder
      result.sort((a, b) {
        if (a['createdAt'] != null && b['createdAt'] != null) {
          Timestamp timestampA = a['createdAt'] as Timestamp;
          Timestamp timestampB = b['createdAt'] as Timestamp;
          return timestampB.compareTo(timestampA); // descending order (newest first)
        }
        // Fallback to displayOrder if createdAt is not available
        int orderA = a['displayOrder'] ?? 0;
        int orderB = b['displayOrder'] ?? 0;
        return orderA.compareTo(orderB);
      });

      return result;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _loadHealthProviderContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final content = await getHealthProviderContent();

      setState(() {
        healthProviderContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = autoI8lnGen.translate('F_L_C ${e.toString()}');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoText("LEARN_2"),
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
                        onPressed: _loadHealthProviderContent,
                        child: const AutoText('RETRY'),
                      ),
                    ],
                  ),
                )
              : healthProviderContent.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          AutoText(
                            'N_P_CONTENT',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: healthProviderContent.length,
                      itemBuilder: (context, index) {
                        final data = healthProviderContent[index];
                        final title = data['title'] ?? autoI8lnGen.translate("UNTITLED");
                        final description = data['firstParagraph'] ?? autoI8lnGen.translate("N_D_E");
                        final secDescription = data['secParagraph'] ?? "";
                        final thirdDescription = data['thirdParagraph'] ?? "";
                        final imageUrl = data['imageUrl']; // uploaded image if available
                        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PractitionerDetailScreen(
                                    title: title,
                                    description: description,
                                    secDescription: secDescription,
                                    thirdDescription: thirdDescription,
                                    imageUrl: imageUrl,
                                    createdAt: createdAt,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // show uploaded image if exists, otherwise placeholder
                                if (imageUrl != null && imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 180,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                else
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),

                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      if (createdAt != null)
                                        AutoText(
                                          "P_ON ${createdAt.day}-${createdAt.month}-${createdAt.year}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class PractitionerDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String secDescription;
  final String thirdDescription;
  final String? imageUrl;
  final DateTime? createdAt;

  const PractitionerDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.secDescription,
    required this.thirdDescription,
    this.imageUrl,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_not_supported,
                size: 80,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(secDescription, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(thirdDescription, style: const TextStyle(fontSize: 16)),
          if (createdAt != null) ...[
            const SizedBox(height: 12),
            AutoText(
              "P_ON_2 ${createdAt!.day}-${createdAt!.month}-${createdAt!.year}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ]
        ],
      ),
    );
  }
}


