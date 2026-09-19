import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jambomama_nigeria/components/button.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/controllers/forgot_password.dart';
import 'package:jambomama_nigeria/midwives/views/components/drop_down_button.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart';
import 'package:jambomama_nigeria/views/mothers/learn.dart';
import 'package:jambomama_nigeria/views/mothers/consent_privacy_screen.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthController _auth = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String email;
  late String password;
  bool isLoading = false;
  bool _isObscure = true;

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  login() async {
    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      String res = await _auth.loginUser(email, password, context, (value) {
        setState(() {
          isLoading = value;
        });
      });

      if (res != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoText(res),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackMessage(context, "LOGIN_VALIDATION_1");
    }
  }

  void notReadytoJoin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LearnPage()),
    );
  }

  void showInfo() {
    const String message = 'LOGIN_VALIDATION_2';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: AutoText(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AutoText('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWebsite(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        showSnackMessage(context, "Could not open the website");
      }
    }
  }

  void showAppDescriptionModal() {
    const String websiteUrl = 'https://jambomama.com';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoText('APP_DESCRIPTION_TITLE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoText(
              'APP_DESCRIPTION_FULL',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _launchWebsite(websiteUrl),
              child: Text(
                websiteUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AutoText('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigate to the ConsentScreen first.
  /// Only after the user agrees to BOTH checkboxes does the
  /// ConsentScreen call [onConsentGiven], which runs widget.onTap()
  /// — your existing registration flow — unchanged.
  void _goToConsentThenRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsentScreen(
          onConsentGiven: () {
            // Pop consent screen, then open registration
            Navigator.pop(context);
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          DropDownButton(width: 200),
        ],
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 15),

                // Logo
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/images/logo.png'),
                ),

                const SizedBox(height: 8),

                // App description (tap to see full description + website link)
                GestureDetector(
                  onTap: showAppDescriptionModal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AutoText(
                      'APP_DESCRIPTION',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 108, 107, 107),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Email field
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 85,
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return autoI8lnGen
                                  .translate("LOGIN_VALIDATION_3");
                            }
                            return null;
                          },
                          onChanged: (value) => email = value,
                          decoration: InputDecoration(
                            labelText:
                                autoI8lnGen.translate("LOGIN_VALIDATION_4"),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        iconSize: 20,
                        onPressed: showInfo,
                      ),
                    ],
                  ),
                ),

                // Password field
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 85,
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return autoI8lnGen
                                  .translate("LOGIN_VALIDATION_5");
                            }
                            return null;
                          },
                          onChanged: (value) => password = value,
                          decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("ENTER_PASSWORD"),
                          ),
                          obscureText: _isObscure,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          setState(() => _isObscure = !_isObscure);
                        },
                      ),
                    ],
                  ),
                ),

                // Forgot password
                Container(
                  alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: AutoText(
                      'FORGOT_PASSWORD',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 108, 107, 107),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // Sign In button
                GestureDetector(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Sbuttons(
                          onTap: login,
                          text: 'LOGIN_TEXT',
                        ),
                ),

                const SizedBox(height: 5),

                // Not a member → goes to ConsentScreen first
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoText(
                      "NOT_A_MEMBER",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      // ← Changed: now opens ConsentScreen before registration
                      onTap: _goToConsentThenRegister,
                      child: AutoText(
                        "REGISTER_NOW",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Not ready to join
                Center(
                  child: GestureDetector(
                    onTap: notReadytoJoin,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: AutoText(
                        'NOT_READY_TO_JOIN',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 220, 9, 9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';




// import 'package:jambomama_nigeria/components/button.dart';
// import 'package:jambomama_nigeria/controllers/auth_controller.dart';
// import 'package:jambomama_nigeria/controllers/forgot_password.dart';
// import 'package:jambomama_nigeria/midwives/views/components/drop_down_button.dart';
// import 'package:jambomama_nigeria/utils/showsnackbar.dart';
// import 'package:jambomama_nigeria/views/mothers/learn.dart';
// import 'package:jambomama_nigeria/views/mothers/consent_privacy_screen.dart';

// class LoginPage extends StatefulWidget {
//   final void Function()? onTap;

//   const LoginPage({super.key, required this.onTap});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   AuthController _auth = AuthController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late String email;
//   late String password;
//   bool isLoading = false;
//   bool _isObscure = true;

//   void setLoading(bool value) {
//     setState(() {
//       isLoading = value;
//     });
//   }

//   login() async {
//     setState(() {
//       isLoading = true;
//     });

//     if (_formKey.currentState!.validate()) {
//       String res = await _auth.loginUser(email, password, context, (value) {
//         setState(() {
//           isLoading = value;
//         });
//       });

//       if (res != 'success') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: AutoText(res),
//             backgroundColor: Colors.red.shade700,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       showSnackMessage(context, "LOGIN_VALIDATION_1");
//     }
//   }

//   void notReadytoJoin() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const LearnPage()),
//     );
//   }

//   void showInfo() {
//     const String message = 'LOGIN_VALIDATION_2';
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: AutoText(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const AutoText('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Navigate to the ConsentScreen first.
//   /// Only after the user agrees to BOTH checkboxes does the
//   /// ConsentScreen call [onConsentGiven], which runs widget.onTap()
//   /// — your existing registration flow — unchanged.
//   void _goToConsentThenRegister() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ConsentScreen(
//           onConsentGiven: () {
//             // Pop consent screen, then open registration
//             Navigator.pop(context);
//             if (widget.onTap != null) {
//               widget.onTap!();
//             }
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         actions: [
//           DropDownButton(width: 200),
//         ],
//       ),
//       body: Center(
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 15),

//                 // Logo
//                 SizedBox(
//                   height: 100,
//                   width: 100,
//                   child: Image.asset('assets/images/logo.png'),
//                 ),

//                 const SizedBox(height: 8),

//                 // App description
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: AutoText(
//                     'APP_DESCRIPTION',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color.fromARGB(255, 108, 107, 107),
//                       height: 1.4,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // Email field
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 85,
//                         child: TextFormField(
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return autoI8lnGen
//                                   .translate("LOGIN_VALIDATION_3");
//                             }
//                             return null;
//                           },
//                           onChanged: (value) => email = value,
//                           decoration: InputDecoration(
//                             labelText:
//                                 autoI8lnGen.translate("LOGIN_VALIDATION_4"),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.help_outline),
//                         iconSize: 20,
//                         onPressed: showInfo,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Password field
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 85,
//                         child: TextFormField(
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return autoI8lnGen
//                                   .translate("LOGIN_VALIDATION_5");
//                             }
//                             return null;
//                           },
//                           onChanged: (value) => password = value,
//                           decoration: InputDecoration(
//                             labelText: autoI8lnGen.translate("ENTER_PASSWORD"),
//                           ),
//                           obscureText: _isObscure,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           _isObscure ? Icons.visibility_off : Icons.visibility,
//                         ),
//                         iconSize: 20,
//                         onPressed: () {
//                           setState(() => _isObscure = !_isObscure);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Forgot password
//                 Container(
//                   alignment: Alignment.bottomRight,
//                   margin: const EdgeInsets.all(10),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ForgotPasswordScreen(),
//                         ),
//                       );
//                     },
//                     child: AutoText(
//                       'FORGOT_PASSWORD',
//                       style: const TextStyle(
//                         color: Color.fromARGB(255, 108, 107, 107),
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Sign In button
//                 GestureDetector(
//                   child: isLoading
//                       ? const CircularProgressIndicator()
//                       : Sbuttons(
//                           onTap: login,
//                           text: 'LOGIN_TEXT',
//                         ),
//                 ),

//                 const SizedBox(height: 5),

//                 // Not a member → goes to ConsentScreen first
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     AutoText(
//                       "NOT_A_MEMBER",
//                       style: const TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     const SizedBox(width: 10),
//                     GestureDetector(
//                       // ← Changed: now opens ConsentScreen before registration
//                       onTap: _goToConsentThenRegister,
//                       child: AutoText(
//                         "REGISTER_NOW",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Not ready to join
//                 Center(
//                   child: GestureDetector(
//                     onTap: notReadytoJoin,
//                     child: Container(
//                       margin: const EdgeInsets.all(10),
//                       child: AutoText(
//                         'NOT_READY_TO_JOIN',
//                         style: const TextStyle(
//                           color: Color.fromARGB(255, 220, 9, 9),
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
