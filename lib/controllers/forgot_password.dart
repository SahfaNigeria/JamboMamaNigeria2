import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jambomama_nigeria/utils/showsnackbar.dart'; // Assuming you have a showSnackMessage function for showing snackbars

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        setLoading(true);
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text.trim());
        setLoading(false);

        showSnackMessage(
            context, 'RESET_SENT');
      } on FirebaseAuthException catch (e) {
        print(e);
        setLoading(false);
        showSnackMessage(context, e.message ?? 'ERROR_16');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  AutoText('FORGOT_P'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AutoText(
                  'ENTER_EMAIL',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                    labelText: autoI8lnGen.translate("Email"),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return autoI8lnGen.translate("ENTER_EMAIL_2");
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return autoI8lnGen.translate("LOGIN_VALIDATION_2");
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: sendPasswordResetEmail,
                        child: const AutoText('SEND_RESET'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
