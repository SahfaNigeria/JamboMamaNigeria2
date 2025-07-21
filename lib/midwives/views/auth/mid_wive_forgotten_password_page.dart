import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/service/m_auth_service.dart';
import '../components/m_auth_textfield.dart';
import '../components/m_custom_button.dart';

class MidWiveForgottenPasswordPage extends StatefulWidget {
  @override
  _MidWiveForgottenPasswordPageState createState() => _MidWiveForgottenPasswordPageState();
}

class _MidWiveForgottenPasswordPageState extends State<MidWiveForgottenPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = MAuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _emailSent = true;
      });
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
                  Text(
                    'Forgotten password',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _emailSent
                        ? 'Password reset email sent! Check your inbox.'
                        : 'Provide your email and we will send you a link to reset your password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 40),
                  if (!_emailSent) ...[
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                      text: 'Reset password',
                      onPressed: _isLoading ? null : _resetPassword,
                      isLoading: _isLoading,
                    ),
                  ] else ...[
                    SizedBox(height: 40),
                    CustomButton(
                      text: 'Back to Sign in',
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/mid_wife_reg_screen',
                            (route) => false,
                      ),
                      isLoading: false,
                    ),
                  ],
                  SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Go back',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
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
