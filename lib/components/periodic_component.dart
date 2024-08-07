// import 'package:flutter/material.dart';

// class PeriodicQuestionaire extends StatelessWidget {
//   final void Function()? onTap;
//   final String text;

//   const PeriodicQuestionaire(
//       {super.key, required this.onTap, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
      
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: Colors.grey, // Border color
//           width: 2.0, // Border width
//         ),
//         borderRadius: BorderRadius.circular(10.0), // Optional: Border radius
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'How are you feeling today?',
//             style: TextStyle(fontSize: 16),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () {},
//                 child: Text('Yes'),
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     // _response =
//                     //    'Not so good.'; Update response when "No" is clicked
//                   });
//                   // _showResponseDialog();
//                 },
//                 child: Text('No'),
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     // _response =
//                     // 'Same as before.'; // Update response when "Same as before" is clicked
//                   });
//                   // _showResponseDialog();
//                 },
//                 child: Text('Same as before'),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
