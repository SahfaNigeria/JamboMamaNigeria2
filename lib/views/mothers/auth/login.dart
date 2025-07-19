import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/button.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/controllers/forgot_password.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart';
import 'package:jambomama_nigeria/views/mothers/learn.dart';

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
  String seePassword = '';

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
      String res = await _auth.loginUser(email, password, context, setLoading);

      if (res != 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackMessage(
        context,
        "LOGIN_VALIDATION_1",
      );
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const AutoText('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15,
                ),
                // insert jambo mama logo
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),

                // email text field

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Email field with IconButton
                      Expanded(
                        flex: 85, // 85% width for the email field
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return autoI8lnGen
                                  .translate("LOGIN_VALIDATION_3");
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            email = value;
                          },
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

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Password field, reduced by 15%
                      Expanded(
                        flex: 85, // 85% width for the password field
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return autoI8lnGen
                                  .translate("LOGIN_VALIDATION_5");
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            password = value;
                          },
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
                          setState(() {
                            _isObscure = !_isObscure; // Toggle the state
                          });
                          // Add toggle logic if needed
                        },
                      ),
                    ],
                  ),
                ),

                //forgot password

                // Inside your login screen
                Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.all(10),
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
                      style: TextStyle(
                        color: Color.fromARGB(255, 108, 107, 107),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // Sign In Button
                GestureDetector(
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Sbuttons(
                          onTap: login,
                          text: 'LOGIN_TEXT',
                        ),
                ),

                // Not a member
                const SizedBox(
                  height: 5,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoText(
                      "NOT_A_MEMBER",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!();
                        } else {
                          print('onTap is null!');
                        }
                      },
                      child: AutoText(
                        "REGISTER_NOW",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 20,
                ),

                // Not ready to join

                Center(
                  child: GestureDetector(
                    onTap: notReadytoJoin,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: AutoText(
                        'NOT_READY_TO_JOIN',
                        style: TextStyle(
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
