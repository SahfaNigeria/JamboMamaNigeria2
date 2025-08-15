import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';

import '../components/m_auth_textfield.dart';
import '../components/m_custom_button.dart';
import '../service/m_auth_service.dart';

class MidWiveSignUpPage extends StatefulWidget {
  @override
  _MidWiveSignUpPageState createState() => _MidWiveSignUpPageState();
}

class _MidWiveSignUpPageState extends State<MidWiveSignUpPage> {


  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = MAuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (mounted) {
      if (!_formKey.currentState!.validate()) return;
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoText('R_M_S')),
        );
        //
        // Navigator.pushReplacementNamed(context, '/signin');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 150),
                  AutoText(
                    'REGISTER',
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
                        "AHAC ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/mid_wife_sign_in_screen'),
                        child: AutoText(
                          'SI',
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
                  SizedBox(height: 20),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'C_P',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return autoI8lnGen.translate("P_C_Y_P");
                      }
                      if (value != _passwordController.text) {
                        return autoI8lnGen.translate("PDNM");
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),
                  CustomButton(
                    text: 'REGISTER',
                    onPressed: _isLoading ? null : _register,
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