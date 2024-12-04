import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer.dart';
import 'package:jambomama_nigeria/components/something.dart';
import 'package:jambomama_nigeria/midwives/views/screens/health_facilites.dart';
import 'package:jambomama_nigeria/views/mothers/report_an_event.dart';

class Warning extends StatelessWidget {
  const Warning({super.key, required this.userName}); // Assigning to the field
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Something Happened'),
        centerTitle: true,
      ),
      drawer: const HomeDrawer(),
      body: ListView(
        children: [
          const SizedBox(height: 5),
          Container(
            width: 50,
            height: 180,
            color: Colors.green,
            child: Something(
              text: 'Report An Event',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportEventForm(userName: userName),
                  ),
                );
              },
              icon: 'assets/svgs/health-medical-medical-report-svgrepo-com.svg',
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 100,
            height: 180,
            color: const Color.fromARGB(255, 248, 51, 37),
            child: Something(
              text: 'Contact Hospital',
              onTap: () {},
              icon: 'assets/svgs/doctornurse-svgrepo-com.svg',
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 100,
            height: 180,
            color: const Color.fromARGB(255, 73, 170, 250),
            child: Center(
              child: Something(
                text: 'Health Facilities',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HospitalsScreen(),
                    ),
                  );
                },
                icon: 'assets/svgs/hospital-svgrepo-com.svg',
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 100,
            height: 180,
            color: const Color.fromARGB(255, 147, 37, 167),
            child: Something(
              text: 'Ambulance',
              onTap: () {},
              icon: 'assets/svgs/ambulance-svgrepo-com.svg',
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/components/drawer.dart';
// import 'package:jambomama_nigeria/components/something.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/health_facilites.dart';
// import 'package:jambomama_nigeria/views/mothers/report_an_event.dart';


// class Warning extends StatelessWidget {

//    final String userName;

//  const Warning({super.key, required this.userName});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Something Happened'),
//         centerTitle: true,
//       ),
//       drawer: const HomeDrawer(),
//       body: ListView(
//         children: [
//           const SizedBox(
//             height: 5,
//           ),
//           Container(
//             width: 50,
//             height: 180,
//             color: Colors.green,
//             child: Something(
//               text: 'Report An Event',
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ReportEventForm(userName: userName),
//                   ),
//                 );
//               },
//               icon: 'assets/svgs/health-medical-medical-report-svgrepo-com.svg',
//             ),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Container(
//             width: 100,
//             height: 180,
//             color: const Color.fromARGB(255, 248, 51, 37),
//             child: Something(
//               text: 'Contact Hospital',
//               onTap: () {},
//               icon: 'assets/svgs/doctornurse-svgrepo-com.svg',
//             ),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Container(
//             width: 100,
//             height: 180,
//             color: const Color.fromARGB(255, 73, 170, 250),
//             child: Center(
//               child: Something(
//                 text: 'Health Facilties',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => HospitalsScreen(),
//                     ),
//                   );
//                 },
//                 icon: 'assets/svgs/hospital-svgrepo-com.svg',
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Container(
//             width: 100,
//             height: 180,
//             color: const Color.fromARGB(255, 147, 37, 167),
//             child: Something(
//               text: 'Ambulance',
//               onTap: () {},
//               icon: 'assets/svgs/ambulance-svgrepo-com.svg',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
