// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/components/button.dart';
// import 'package:jambomama_nigeria/components/login_text_field.dart';

// import 'package:jambomama_nigeria/views/mothers/home.dart';
// import 'package:jambomama_nigeria/views/mothers/learn.dart';

// class LoginPage extends StatefulWidget {
//   final void Function()? onTap;

//   const LoginPage({super.key, required this.onTap});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   void login() {
//     /*

//     authentication

//     */

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const HomePage()),
//     );
//   }

//   void notReadytoJoin() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const LearnPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: Center(
//         child: ListView(
//           children: [
//             const SizedBox(
//               height: 15,
//             ),
//             // insert jambo mama logo
//             SizedBox(
//               height: 200,
//               width: 140,
//               child: Image.asset(
//                 'assets/images/logo-jambo mama.jpg',
//               ),
//             ),

//             // email text field

//             // password textfield
//             LoginTextField(
//                 controller: emailController,
//                 hintText: 'Email',
//                 obscureText: false),

//             SizedBox(
//               height: 10,
//             ),

//             LoginTextField(
//                 controller: passwordController,
//                 hintText: 'Password',
//                 obscureText: true),

//             //forgot password

//             Container(
//               alignment: Alignment.bottomRight,
//               margin: EdgeInsets.all(10),
//               child: GestureDetector(
//                 onTap: () {},
//                 child: const Text(
//                   'Forgot password?',
//                   style: TextStyle(
//                     color: Color.fromARGB(255, 108, 107, 107),
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ),

//             // Sign In Button

//             Sbuttons(
//               onTap: login,
//               text: 'Sign In',
//             ),

//             // Not a member
//             const SizedBox(
//               height: 5,
//             ),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Not a member?",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 GestureDetector(
//                   onTap: widget.onTap,
//                   child: const Text(
//                     "Register now",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: Colors.grey),
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(
//               height: 20,
//             ),

//             // Not ready to join

//             Center(
//               child: GestureDetector(
//                 onTap: notReadytoJoin,
//                 child: Container(
//                   margin: const EdgeInsets.all(10),
//                   child: const Text(
//                     'Not ready to Join?',
//                     style: TextStyle(
//                       color: Color.fromARGB(255, 220, 9, 9),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
