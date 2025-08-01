import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PractitionerContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Practitioner Content'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('content') // or your collection name
            .where('targetAudience',
                whereIn: ['Practitioner', 'Both']).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No content available.'));
          }

          final contentDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contentDocs.length,
            itemBuilder: (context, index) {
              final doc = contentDocs[index];
              final title = doc['title'] ?? 'Untitled';
              final description = doc['description'] ?? '';
              final imageUrl = doc['imageUrl'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.article),
                  title: Text(title),
                  subtitle: Text(description),
                  onTap: () {
                    // optional: navigate to detailed screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class PregnancyCareModulesPage extends StatelessWidget {
//   const PregnancyCareModulesPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Pregnancy Care Instructions',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.teal[700],
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.teal[600]!, Colors.teal[400]!],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.teal.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Clinical Assessment Modules',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Comprehensive pregnancy care instructions for healthcare providers',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Modules Grid
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 1.1,
//                   physics: const BouncingScrollPhysics(),
//                   children: [
//                     _buildModuleCard(
//                       context,
//                       'Blood Pressure',
//                       Icons.favorite,
//                       Colors.red[400]!,
//                       () => _navigateToModule(context, 'Blood Pressure'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Heart Rate',
//                       Icons.monitor_heart,
//                       Colors.pink[400]!,
//                       () => _navigateToModule(context, 'Heart Rate'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Urinalysis',
//                       Icons.science,
//                       Colors.amber[600]!,
//                       () => _navigateToModule(context, 'Urine Test - Urinalysis'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Urine: Glucose',
//                       Icons.water_drop,
//                       Colors.orange[500]!,
//                       () => _navigateToModule(context, 'Urine Test - Glucose'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Urine: Albumin',
//                       Icons.opacity,
//                       Colors.blue[400]!,
//                       () => _navigateToModule(context, 'Urine Test - Albumin'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'BMI',
//                       Icons.monitor_weight,
//                       Colors.green[500]!,
//                       () => _navigateToModule(context, 'BMI & Weight Gain'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Haemoglobin',
//                       Icons.bloodtype,
//                       Colors.deepOrange[400]!,
//                       () => _navigateToModule(context, 'Haemoglobin'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Discharge',
//                       Icons.health_and_safety,
//                       Colors.purple[400]!,
//                       () => _navigateToModule(context, 'Vaginal Discharge'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       'Fundal Height',
//                       Icons.straighten,
//                       Colors.teal[400]!,
//                       () => _navigateToModule(context, 'Fundal Height'),
//                     ),
//                     _buildModuleCard(
//                       context,
//                       "Baby's Heart",
//                       Icons.child_care,
//                       Colors.indigo[400]!,
//                       () => _navigateToModule(context, "Baby's Heart Beat"),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Footer
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   'Select a module to view detailed instructions',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildModuleCard(
//     BuildContext context,
//     String title,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             gradient: LinearGradient(
//               colors: [
//                 color.withOpacity(0.1),
//                 color.withOpacity(0.05),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 32,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _navigateToModule(BuildContext context, String moduleName) {
//     // Navigate to specific module instruction page
//     // Replace this with your actual navigation logic
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Opening $moduleName module...'),
//         backgroundColor: Colors.teal[600],
//         duration: const Duration(seconds: 2),
//       ),
//     );
    
//     // Example navigation (uncomment and modify as needed):
//     // Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) => ModuleInstructionPage(moduleName: moduleName),
//     //   ),
//     // );
//   }
// }