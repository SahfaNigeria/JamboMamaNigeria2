import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/button.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart';
import 'package:jambomama_nigeria/views/mothers/home.dart';
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

  Future login() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      String res = await _auth.loginUser(email, password);

      if (res == 'success') {
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return HomePage();
          }),
        );
      } else {
        return showSnackMessage(context, res);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackMessage(context, 'Field(s) must not be empty');
    }
  }

  void notReadytoJoin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LearnPage()),
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

                // password textfield
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email Field must not be empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Email',
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password Field must not be empty';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Password',
                    ),
                    obscureText: true,
                  ),
                ),

                //forgot password

                Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot password?',
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
                          text: 'Log In',
                        ),
                ),

                // Not a member
                const SizedBox(
                  height: 5,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Not a member?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Register now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey),
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
                      child: const Text(
                        'Not ready to Join?',
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
