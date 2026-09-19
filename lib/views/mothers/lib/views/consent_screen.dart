import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

/// ConsentScreen
/// -------------
/// Shows SafeMama! data-use information and requires the user to
/// check BOTH boxes before the "Create My Account" button becomes
/// active.  When confirmed, it calls [onConsentGiven] so the
/// parent widget (LoginPage / AuthPage) can navigate to the real
/// registration form.
///
/// Usage – replace your REGISTER_NOW GestureDetector onTap with:
///
///   onTap: () {
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (_) => ConsentScreen(
///           onConsentGiven: () {
///             // your existing navigation to RegisterPage
///             widget.onTap!();
///           },
///         ),
///       ),
///     );
///   },

class ConsentScreen extends StatefulWidget {
  /// Called only after the user checks both boxes and taps
  /// "Create My Account".
  final VoidCallback onConsentGiven;

  const ConsentScreen({super.key, required this.onConsentGiven});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen>
    with SingleTickerProviderStateMixin {
  bool _agreePrivacy = false;
  bool _agreeCrossBorder = false;

  // Animation
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;

  // Your published privacy policy URL
  static const String _privacyPolicyUrl =
      'https://your-website.com/privacy-policy'; // ← replace with real URL

  bool get _canProceed => _agreePrivacy && _agreeCrossBorder;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _proceed() {
    if (_canProceed) {
      // TODO: if you want to persist consent to Firestore, do it here:
      // FirebaseFirestore.instance
      //     .collection('consent_log')
      //     .add({
      //   'timestamp': FieldValue.serverTimestamp(),
      //   'consentVersion': '1.0',
      //   'privacyAccepted': true,
      //   'crossBorderAccepted': true,
      // });
      widget.onConsentGiven();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFFB5174B)),
        title: const Text(
          'SafeMama! Nigeria',
          style: TextStyle(
            color: Color(0xFFB5174B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ─────────────────────────────────────────────
              _HeaderCard(),

              const SizedBox(height: 20),

              // ── Info sections ────────────────────────────────────────────
              _InfoSection(
                emoji: '📋',
                title: 'What we collect',
                bullets: const [
                  'Your name and phone number',
                  'Your pregnancy details and health info',
                  'Your location (to find nearby care)',
                ],
              ),
              _InfoSection(
                emoji: '🔒',
                title: 'How we protect it',
                bullets: const [
                  'Your data is encrypted and secure',
                  'Only you can access your personal info',
                  'We never sell your data to anyone',
                ],
              ),
              _InfoSection(
                emoji: '🌍',
                title: 'Where it is stored',
                bullets: const [
                  'Data is stored securely via Google Firebase, '
                      'which may be outside Nigeria',
                ],
              ),
              _InfoSection(
                emoji: '⚖️',
                title: 'Your rights (NDPA 2023)',
                bullets: const [
                  'You can request your data anytime',
                  'You can delete your account anytime',
                  'Email us: safemama@sahfanigeria.com',
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: Color(0xFFFFD6E0)),
              const SizedBox(height: 16),

              // ── Checkbox 1 ───────────────────────────────────────────────
              _ConsentCheckbox(
                value: _agreePrivacy,
                onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                richLabel: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'I have read and agree to the ',
                      style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFB5174B),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openPrivacyPolicy,
                    ),
                    const TextSpan(
                      text: ' and Terms of Use',
                      style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Checkbox 2 ───────────────────────────────────────────────
              _ConsentCheckbox(
                value: _agreeCrossBorder,
                onChanged: (v) =>
                    setState(() => _agreeCrossBorder = v ?? false),
                richLabel: const TextSpan(
                  text: 'I agree that my data may be stored outside Nigeria by '
                      'Google Firebase',
                  style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                ),
              ),

              const SizedBox(height: 32),

              // ── Create Account button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: _canProceed
                        ? const LinearGradient(
                            colors: [Color(0xFFB5174B), Color(0xFFE0517A)],
                          )
                        : null,
                    color: _canProceed ? null : const Color(0xFFDDDDDD),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _canProceed ? _proceed : null,
                      child: Center(
                        child: Text(
                          'CREATE MY ACCOUNT',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color:
                                _canProceed ? Colors.white : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Subtle note ──────────────────────────────────────────────
              Center(
                child: Text(
                  'Compliant with the Nigeria Data Protection Act 2023',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE4ED), Color(0xFFFFF0F4)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB3CC), width: 1),
      ),
      child: Column(
        children: [
          // Flower emoji as logo stand-in
          const Text('🌸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          const Text(
            'Welcome to SafeMama!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB5174B),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Before you create your account, please read and agree to '
            'how we use your data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String emoji;
  final String title;
  final List<String> bullets;

  const _InfoSection({
    required this.emoji,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5174B).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: Color(0xFFB5174B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: Color(0xFFB5174B),
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[800],
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final TextSpan richLabel;

  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.richLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFFFE4ED) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? const Color(0xFFB5174B) : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFB5174B),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 11),
                child: RichText(text: richLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
