import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/registration_button.dart';
import 'package:jambomama_nigeria/views/mothers/auth/mother_registration_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  void signUpMothers() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: ListView(
          children: [
            const SizedBox(
              height: 15,
            ),
            // insert jambo mama logo
            SizedBox(
              height: 100,
              width: 70,
              child: Image.asset(
                'assets/images/logo-jambo mama.jpg',
              ),
            ),

            // Space

            const SizedBox(
              height: 45,
            ),

            // Registeration text like a Notice board

            const Center(
                child: Text(
              "Registration",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            )),

            // Space

            const SizedBox(
              height: 15,
            ),

            // Button Container

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: RegistrationButton(
                    text: "Register as a Mother",
                    icon: Icons.woman,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MotherRegisterPage(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: RegistrationButton(
                    text: "Register as a Nurse",
                    icon: Icons.medical_services,
                    onTap: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: RegistrationButton(
                    text: "Register as a C H W",
                    icon: Icons.medication,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            // Not a member
            const SizedBox(
              height: 35,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already a member?",
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
                    "Sign In",
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

            //Not ready to join
            Center(
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
          ],
        ),
      ),
    );
  }
}
