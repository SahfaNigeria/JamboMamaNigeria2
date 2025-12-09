import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/views/mothers/guest_feeling_form.dart';
import 'package:jambomama_nigeria/views/mothers/learn_question_screen.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';
import 'package:jambomama_nigeria/views/mothers/guest_delivery_date.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Make card sizes responsive
    final cardWidth = (screenWidth - 30) / 2;
    final cardHeight = screenHeight * 0.22;

    return Scaffold(
      appBar: AppBar(
        title: AutoText('LEARN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
         
            InkWell(
              onTap: () {
            
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuestExpectedDeliveryScreen(),
                  ),
                );
                
                
               
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    AutoText(
                      'C_D_D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // First row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HomeComponents(
                      text: 'FOLLOW_YOUR_PREGNANCY',
                      icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const You()),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HomeComponents(
                      text: 'P_Q', // Periodic Questionnaire
                      icon: 'assets/svgs/perfusion-svgrepo-com.svg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuestFeelingsForm(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Second row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HomeComponents(
                      text: 'VITAL_INFO_UPDATE_2',
                      icon: 'assets/svgs/doctor-svgrepo-com.svg',
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: AutoText('CREATE_ENJOY_APP'),
                    duration: Duration(seconds: 4),
                  ),
                );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HomeComponents(
                      text: 'SOMETHING_HAPPENED',
                      icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: AutoText('CREATE_ENJOY_APP'),
                    duration: Duration(seconds: 4),
                  ),
                );
                        
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/components/home_components.dart';
// import 'package:jambomama_nigeria/views/mothers/guest_feeling_form.dart';
// import 'package:jambomama_nigeria/views/mothers/learn_question_screen.dart';
// import 'package:jambomama_nigeria/views/mothers/you.dart';

// class LearnPage extends StatefulWidget {
//   const LearnPage({super.key});

//   @override
//   State<LearnPage> createState() => _LearnPageState();
// }

// class _LearnPageState extends State<LearnPage> {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     // Make card sizes responsive
//     final cardWidth = (screenWidth - 30) / 2;
//     final cardHeight = screenHeight * 0.22;

//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('LEARN'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           children: [
//             // First row
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.blueAccent,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'FOLLOW_YOUR_PREGNANCY',
//                       icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const You()),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.purple,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'P_Q', // Periodic Questionnaire
//                       icon: 'assets/svgs/perfusion-svgrepo-com.svg',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => GuestFeelingsForm(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             // Second row
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'VITAL_INFO_UPDATE_2',
//                       icon: 'assets/svgs/doctor-svgrepo-com.svg',
//                       onTap: () {},
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade500,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'SOMETHING_HAPPENED',
//                       icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
//                       onTap: () {},
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



