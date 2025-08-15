import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';

import '../../../controllers/auth_controller.dart' show AuthController;
import '../components/m_auth_textfield.dart';
import '../components/m_custom_button.dart';
import '../service/m_auth_service.dart';

class MidWiveSignInPage extends StatefulWidget {
  @override
  _MidWiveSignInPageState createState() => _MidWiveSignInPageState();
}

class _MidWiveSignInPageState extends State<MidWiveSignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = MAuthService();
  final _authService2 = AuthController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void isLoading(bool value) {}

  Future<void> _signIn() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _authService2.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
        context,
            (bool isLoading) {
          if (mounted) {
            setState(() {
              _isLoading = isLoading;
            });
          }
        },
      );

      if (res == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoText('Login successful')),
        );

        // Navigate to home page or wherever
        // Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = res;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 150),
                  AutoText(
                    'SI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      AutoText(
                        "DAHC ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: AutoText(
                          'REGISTER',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'EMAIL',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return autoI8lnGen.translate("ENTER_EMAIL_2");
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return autoI8lnGen.translate("LOGIN_VALIDATION_2");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'PASSWORD',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return autoI8lnGen.translate("P_E_P_2");
                      }
                      if (value.length < 6) {
                        return autoI8lnGen.translate("PASSWORD_V");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, '/midwive_password_reset_page'),
                      child: AutoText(
                        'F_P_2',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  CustomButton(
                    text: 'SI',
                    onPressed: _isLoading ? null : _signIn,
                    isLoading: _isLoading,
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
