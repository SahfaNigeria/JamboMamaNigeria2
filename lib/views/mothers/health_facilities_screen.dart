import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart'
    show
        AppBar,
        BorderRadius,
        BorderSide,
        BoxDecoration,
        BuildContext,
        Card,
        Center,
        CircularProgressIndicator,
        Color,
        Colors,
        Column,
        Container,
        CrossAxisAlignment,
        DraggableScrollableSheet,
        DropdownButtonFormField,
        DropdownMenuItem,
        EdgeInsets,
        ElevatedButton,
        Expanded,
        FloatingActionButton,
        FontWeight,
        Form,
        FormState,
        GlobalKey,
        Icon,
        IconButton,
        IconData,
        Icons,
        InputDecoration,
        Key,
        ListView,
        MainAxisAlignment,
        MediaQuery,
        Navigator,
        OutlineInputBorder,
        OutlinedButton,
        Padding,
        Radius,
        RefreshIndicator,
        RoundedRectangleBorder,
        Row,
        Scaffold,
        ScaffoldMessenger,
        SizedBox,
        SnackBar,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextFormField,
        TextInputType,
        TextStyle,
        VoidCallback,
        Widget,
        showModalBottomSheet,
        TextAlign,
        Border,
        showDialog,
        AlertDialog,
        TextButton,
        MainAxisSize,
        Dialog,
        LinearProgressIndicator,
        Divider,
        ListTile,
        Chip,
        Wrap,
        GestureDetector,
        BoxShadow,
        Offset,
        Animation,
        AnimationController,
        CurvedAnimation,
        Curves,
        FadeTransition,
        SlideTransition,
        TickerProviderStateMixin,
        TextDecoration,
        BoxShape,
        Tween;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Risk level derived from the patient's background document
// ─────────────────────────────────────────────────────────────────────────────

enum _RiskLevel { unknown, routine, elevated }

class _PatientRiskProfile {
  final _RiskLevel level;
  final List<String> reasons; // plain-language reasons for elevation

  const _PatientRiskProfile({required this.level, required this.reasons});

  bool get isElevated => level == _RiskLevel.elevated;
  bool get isRoutine => level == _RiskLevel.routine;
  bool get isUnknown => level == _RiskLevel.unknown;
}

/// Derives a risk profile from the raw Firestore background document.
_PatientRiskProfile _deriveRiskProfile(Map<String, dynamic>? data) {
  if (data == null)
    return const _PatientRiskProfile(level: _RiskLevel.unknown, reasons: []);

  final List<String> reasons = [];

  // Stored alerts from PatientBackgroundScreen._checkHighRiskFactors()
  final storedAlerts = data['alerts'];
  if (storedAlerts is List && storedAlerts.isNotEmpty) {
    reasons.addAll(storedAlerts.cast<String>());
  }

  // Hard clinical flags — check even if alerts list is stale
  final genotype = data['genotype'] as String?;
  if (genotype == 'SS' || genotype == 'SC') {
    if (!reasons.any((r) => r.toLowerCase().contains('sickle'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_SICKLE_CELL'));
    }
  }

  if (data['on_art'] == true) {
    if (!reasons.any((r) =>
        r.toLowerCase().contains('hiv') || r.toLowerCase().contains('art'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_20'));
    }
  }

  if (data['currently_on_tb_treatment'] == true) {
    if (!reasons.any((r) => r.toLowerCase().contains('tb'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_21'));
    }
  }

  if (data['had_cesarean'] == true) {
    if (!reasons.any((r) =>
        r.toLowerCase().contains('cesarean') ||
        r.toLowerCase().contains('caesar'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_18'));
    }
  }

  if (data['had_heavy_bleeding'] == 'Yes') {
    if (!reasons.any((r) => r.toLowerCase().contains('bleed'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_19'));
    }
  }

  final systolic = data['systolic_bp'] as int?;
  final diastolic = data['diastolic_bp'] as int?;
  if (systolic != null && diastolic != null) {
    if (systolic >= 140 || diastolic >= 90) {
      if (!reasons.any((r) =>
          r.toLowerCase().contains('blood pressure') ||
          r.toLowerCase().contains('bp'))) {
        reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_3'));
      }
    }
  }

  final pcv = data['pcv'] as double?;
  if (pcv != null && pcv < 30) {
    if (!reasons.any((r) =>
        r.toLowerCase().contains('pcv') ||
        r.toLowerCase().contains('anaemia') ||
        r.toLowerCase().contains('anemia'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_5'));
    }
  }

  final glucose = data['glucose'] as double?;
  if (glucose != null && glucose >= 11.0) {
    if (!reasons.any((r) =>
        r.toLowerCase().contains('glucose') ||
        r.toLowerCase().contains('diabetes'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_12'));
    }
  }

  final age = data['age'] as int?;
  if (age != null && (age < 20 || age > 39)) {
    if (!reasons.any((r) => r.toLowerCase().contains('age'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_14'));
    }
  }

  final miscarriages = data['miscarriages'] as int?;
  if (miscarriages != null && miscarriages > 0) {
    if (!reasons.any((r) => r.toLowerCase().contains('miscarriage'))) {
      reasons.add(autoI8lnGen.translate('HEALTH_ISSUE_16'));
    }
  }

  if (reasons.isEmpty) {
    return const _PatientRiskProfile(level: _RiskLevel.routine, reasons: []);
  }
  return _PatientRiskProfile(level: _RiskLevel.elevated, reasons: reasons);
}

// ─────────────────────────────────────────────────────────────────────────────
// Facility tier classification
// ─────────────────────────────────────────────────────────────────────────────

enum _FacilityTier { community, hospital }

_FacilityTier _tierOf(HealthFacility f) {
  final t = f.type.toLowerCase();
  if (t.contains('hospital')) return _FacilityTier.hospital;
  return _FacilityTier.community; // dispensary, health center, clinic, etc.
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

class HealthFacilitiesScreen extends StatefulWidget {
  const HealthFacilitiesScreen({Key? key}) : super(key: key);

  @override
  State<HealthFacilitiesScreen> createState() => _HealthFacilitiesScreenState();
}

class _HealthFacilitiesScreenState extends State<HealthFacilitiesScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userLocation = '';
  String userFullLocation = '';
  bool isLoading = true;
  List<HealthFacility> facilities = [];
  bool isHealthProvider = false;

  // Risk profile — loaded from patient background doc
  _PatientRiskProfile _riskProfile =
      const _PatientRiskProfile(level: _RiskLevel.unknown, reasons: []);

  late AnimationController _bannerAnimController;
  late Animation<double> _bannerFadeAnim;
  late Animation<Offset> _bannerSlideAnim;

  @override
  void initState() {
    super.initState();
    _bannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _bannerFadeAnim = CurvedAnimation(
      parent: _bannerAnimController,
      curve: Curves.easeOut,
    );
    _bannerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bannerAnimController,
      curve: Curves.easeOut,
    ));

    _loadAll();
  }

  @override
  void dispose() {
    _bannerAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadUserLocationAndFacilities(),
      _loadRiskProfile(),
    ]);
    setState(() => isLoading = false);
    _bannerAnimController.forward();
  }

  // ── Risk profile ──────────────────────────────────────────────────────────

  Future<void> _loadRiskProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('patients')
          .doc(user.uid)
          .collection('background')
          .doc('patient_background')
          .get();

      if (doc.exists) {
        setState(() {
          _riskProfile = _deriveRiskProfile(doc.data());
        });
      }
      // If the doc doesn't exist yet (background not filled), risk stays unknown
    } catch (_) {
      // Silently ignore — we just won't show personalised guidance
    }
  }

  // ── Location + facilities ─────────────────────────────────────────────────

  Future<void> _loadUserLocationAndFacilities() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot? userDoc;

        DocumentSnapshot newMotherDoc =
            await _firestore.collection('New Mothers').doc(user.uid).get();

        if (newMotherDoc.exists) {
          userDoc = newMotherDoc;
          isHealthProvider = false;
        } else {
          DocumentSnapshot healthProfDoc = await _firestore
              .collection('Health Professionals')
              .doc(user.uid)
              .get();
          if (healthProfDoc.exists) {
            userDoc = healthProfDoc;
            isHealthProvider = true;
          }
        }

        if (userDoc != null && userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          if (userData != null) {
            final villageTown = userData['villageTown'] ?? '';
            final cityValue = userData['cityValue'] ?? '';
            final stateValue = userData['stateValue'] ?? '';
            final countryValue = userData['countryValue'] ?? '';

            setState(() {
              userLocation = cityValue;
              userFullLocation = _buildFullLocationString(
                  villageTown, cityValue, stateValue, countryValue);
            });

            await _loadHealthFacilities();
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_L_U_S $e')),
      );
    }
  }

  String _buildFullLocationString(
      String villageTown, String city, String state, String country) {
    return [villageTown, city, state, country]
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  Future<void> _loadHealthFacilities() async {
    try {
      Query query = _firestore
          .collection('health_facilities')
          .where('status', isEqualTo: true)
          .orderBy('name');

      if (userLocation.isNotEmpty) {
        query = query.where('district', isEqualTo: userLocation);
      }

      final snapshot = await query.get();
      setState(() {
        facilities = snapshot.docs.map((doc) {
          return HealthFacility.fromMap(
              doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_L_F $e')),
      );
    }
  }

  // ── Facility sorting ──────────────────────────────────────────────────────

  /// Returns [recommended, secondary] facility lists based on risk.
  /// - Routine / unknown → community facilities first, hospitals secondary
  /// - Elevated           → hospitals first, community secondary
  (List<HealthFacility>, List<HealthFacility>) _splitFacilities() {
    final community =
        facilities.where((f) => _tierOf(f) == _FacilityTier.community).toList();
    final hospitals =
        facilities.where((f) => _tierOf(f) == _FacilityTier.hospital).toList();

    if (_riskProfile.isElevated) {
      return (hospitals, community);
    }
    return (community, hospitals);
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  void _showChangeLocationDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: AutoText(
                    'CHANGE_LOCATION',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const AutoText('LOCATION_EXPLANATION',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AutoText(
                          'CURRENT_LOCATION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userFullLocation.isNotEmpty
                        ? userFullLocation
                        : autoI8lnGen.translate('LOCATION_NOT_SET'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(HealthFacility facility) async {
    final Uri directionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}',
    );
    try {
      await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_O_G_P $e')),
      );
    }
  }

  /// For routine patients trying to navigate to a hospital, show a gentle
  /// one-tap confirmation so the choice is deliberate.
  Future<void> _openGoogleMapsWithFriction(HealthFacility facility) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: AutoText(
                'HOSP_FRICTION_TITLE',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: AutoText(
          'HOSP_FRICTION_BODY',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: AutoText('GO_BACK'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: AutoText('YES_CONTINUE'),
          ),
        ],
      ),
    );

    if (confirmed == true) _openGoogleMaps(facility);
  }

  void _showAddFacilityDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFacilityForm(
        userLocation: userLocation,
        userFullLocation: userFullLocation,
        onFacilityAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AutoText('FACILITY_SUBMITTED_APPROV'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showRiskReasonsSheet() {
    if (_riskProfile.reasons.isEmpty) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red.shade700, size: 22),
                const SizedBox(width: 8),
                AutoText(
                  'WHY_HOSPITAL_TITLE',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AutoText(
              'WHY_HOSPITAL_INTRO',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ..._riskProfile.reasons.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 7, color: Colors.red.shade400),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(r,
                          style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_outlined,
                      color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AutoText(
                      'WHY_HOSPITAL_TIP',
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Guidance banner
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGuidanceBanner() {
    if (isHealthProvider) return const SizedBox.shrink();

    final Color bgColor;
    final Color borderColor;
    final Color iconColor;
    final Color textColor;
    final IconData icon;
    final String titleKey;
    final String subtitleKey;
    final bool showLearnMore;

    if (_riskProfile.isUnknown) {
      bgColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade300;
      iconColor = Colors.grey.shade600;
      textColor = Colors.grey.shade700;
      icon = Icons.info_outline;
      titleKey = 'GUIDANCE_UNKNOWN_TITLE';
      subtitleKey = 'GUIDANCE_UNKNOWN_BODY';
      showLearnMore = false;
    } else if (_riskProfile.isRoutine) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade200;
      iconColor = Colors.green.shade700;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle_outline;
      titleKey = 'GUIDANCE_ROUTINE_TITLE';
      subtitleKey = 'GUIDANCE_ROUTINE_BODY';
      showLearnMore = false;
    } else {
      // Elevated
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      iconColor = Colors.red.shade700;
      textColor = Colors.red.shade900;
      icon = Icons.warning_amber_rounded;
      titleKey = 'GUIDANCE_ELEVATED_TITLE';
      subtitleKey = 'GUIDANCE_ELEVATED_BODY';
      showLearnMore = true;
    }

    return FadeTransition(
      opacity: _bannerFadeAnim,
      child: SlideTransition(
        position: _bannerSlideAnim,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoText(
                      titleKey,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AutoText(
                      subtitleKey,
                      style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.85),
                          height: 1.4),
                    ),
                    if (showLearnMore) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showRiskReasonsSheet,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              autoI8lnGen.translate('SEE_REASONS'),
                              style: TextStyle(
                                fontSize: 12,
                                color: iconColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_forward_ios,
                                size: 10, color: iconColor),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Facility list with tiers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFacilityList() {
    if (isHealthProvider) {
      // Health providers see a flat, unfiltered list — no guidance applied
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: facilities.length,
        itemBuilder: (context, index) {
          final facility = facilities[index];
          return HealthFacilityCard(
            facility: facility,
            isRecommended: false,
            onGetDirections: () => _openGoogleMaps(facility),
          );
        },
      );
    }

    final (recommended, secondary) = _splitFacilities();

    // Labels depend on risk level
    final String recommendedHeaderKey = _riskProfile.isElevated
        ? 'SECTION_HOSPITALS' // "Hospitals — recommended for your situation"
        : 'SECTION_COMMUNITY'; // "Dispensaries & health centres — right for you"

    final String secondaryHeaderKey = _riskProfile.isElevated
        ? 'SECTION_COMMUNITY_ALT' // "Other nearby facilities"
        : 'SECTION_HOSPITALS_ALT'; // "Hospitals — for complex cases"

    final String secondarySubtitleKey = _riskProfile.isElevated
        ? 'SECTION_COMMUNITY_ALT_SUB'
        : 'SECTION_HOSPITALS_ALT_SUB'; // "Most pregnancies don't need this level of care"

    final items = <Widget>[];

    // ── Recommended group ────────────────────────────────────────────────
    if (recommended.isNotEmpty) {
      items.add(_buildSectionHeader(
        key: recommendedHeaderKey,
        isRecommended: true,
        riskLevel: _riskProfile.level,
      ));
      for (final f in recommended) {
        items.add(HealthFacilityCard(
          facility: f,
          isRecommended: true,
          onGetDirections: () => _openGoogleMaps(f),
        ));
      }
    }

    // ── Secondary group ──────────────────────────────────────────────────
    if (secondary.isNotEmpty) {
      items.add(_buildSectionDivider(
        headerKey: secondaryHeaderKey,
        subtitleKey: secondarySubtitleKey,
        riskLevel: _riskProfile.level,
      ));
      for (final f in secondary) {
        final isHospitalForRoutine =
            _tierOf(f) == _FacilityTier.hospital && !_riskProfile.isElevated;
        items.add(HealthFacilityCard(
          facility: f,
          isRecommended: false,
          onGetDirections: isHospitalForRoutine
              ? () => _openGoogleMapsWithFriction(f)
              : () => _openGoogleMaps(f),
        ));
      }
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: items,
    );
  }

  Widget _buildSectionHeader({
    required String key,
    required bool isRecommended,
    required _RiskLevel riskLevel,
  }) {
    final Color accent = riskLevel == _RiskLevel.elevated
        ? Colors.red.shade700
        : Colors.teal.shade700;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AutoText(
              key,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: accent,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withOpacity(0.3)),
              ),
              child: AutoText(
                'RECOMMENDED_TAG',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold, color: accent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider({
    required String headerKey,
    required String subtitleKey,
    required _RiskLevel riskLevel,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),
          AutoText(
            headerKey,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          AutoText(
            subtitleKey,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_hospital_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          AutoText(
            'N_O_FF',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          AutoText(
            userLocation.isEmpty ? 'PULS' : 'B_T_F',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoText('HEALTH_FACILITIES'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Location header ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        AutoText(
                          'YL',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _showChangeLocationDialog,
                      icon: const Icon(Icons.edit_location_alt, size: 18),
                      label: const AutoText('CHANGE'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                AutoText(
                  userFullLocation.isNotEmpty ? userFullLocation : 'LNS',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                AutoText(
                  '${facilities.length} FF',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // ── Risk guidance banner ───────────────────────────────────────
          if (!isLoading) _buildGuidanceBanner(),

          // ── Facilities ─────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : facilities.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            _loadHealthFacilities(),
                            _loadRiskProfile(),
                          ]);
                        },
                        child: _buildFacilityList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFacilityDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const AutoText(
          'A_FCI',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Facility card — updated to show recommended badge
// ─────────────────────────────────────────────────────────────────────────────

class HealthFacilityCard extends StatelessWidget {
  final HealthFacility facility;
  final bool isRecommended;
  final VoidCallback onGetDirections;

  const HealthFacilityCard({
    Key? key,
    required this.facility,
    required this.isRecommended,
    required this.onGetDirections,
  }) : super(key: key);

  Color _getFacilityTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('hospital')) return Colors.red;
    if (t.contains('health center') ||
        t == autoI8lnGen.translate('H_C_2').toLowerCase()) return Colors.orange;
    if (t.contains('dispensary') ||
        t == autoI8lnGen.translate('DISPENSARY_2').toLowerCase()) {
      return Colors.teal;
    }
    return Colors.grey;
  }

  IconData _getFacilityTypeIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('hospital')) return Icons.local_hospital;
    if (t.contains('health center')) return Icons.medical_services;
    if (t.contains('dispensary')) return Icons.medication;
    return Icons.healing;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getFacilityTypeColor(facility.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isRecommended ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? BorderSide(color: typeColor.withOpacity(0.35), width: 1.4)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFacilityTypeIcon(facility.type),
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              facility.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: AutoText(
                                'RECOMMENDED_TAG',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: typeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          facility.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (facility.address.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      facility.address,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ],
            if (facility.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 15, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    facility.phoneNumber,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGetDirections,
                    icon: const Icon(Icons.directions, size: 16),
                    label: const AutoText('G_D'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (facility.phoneNumber.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final Uri phoneUri =
                          Uri(scheme: 'tel', path: facility.phoneNumber);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AddFacilityForm — unchanged from original
// ─────────────────────────────────────────────────────────────────────────────

class AddFacilityForm extends StatefulWidget {
  final String userLocation;
  final String userFullLocation;
  final VoidCallback onFacilityAdded;

  const AddFacilityForm({
    Key? key,
    required this.userLocation,
    required this.userFullLocation,
    required this.onFacilityAdded,
  }) : super(key: key);

  @override
  State<AddFacilityForm> createState() => _AddFacilityFormState();
}

class _AddFacilityFormState extends State<AddFacilityForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedType = autoI8lnGen.translate('HOSPITAL');
  bool _isSubmitting = false;

  final List<String> _facilityTypes = [
    autoI8lnGen.translate('HEALTH_FACILITIES_HOSPITAL'),
    autoI8lnGen.translate('HEALTH_FACILITIES_HEALTH_CENTER'),
    autoI8lnGen.translate('HEALTH_FACILITIES_DISPENSARY'),
    autoI8lnGen.translate('HEALTH_FACILITIES_CLINIC'),
    autoI8lnGen.translate('HEALTH_FACILITIES_MEDICAL_CENTER'),
  ];

  Future<void> _submitFacility() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw autoI8lnGen.translate('U_N_A');

      await FirebaseFirestore.instance.collection('health_facilities').add({
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'address': _addressController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'district': widget.userLocation,
        'status': false,
        'submittedBy': user.uid,
        'location': null,
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      widget.onFacilityAdded();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoText('E_S_F $e')),
      );
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: AutoText(
                          'A_H_F',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AutoText(
                    'H_O_H_F Y_R_V',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  if (widget.userFullLocation.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AutoText(
                              'S_F_F ${widget.userFullLocation}',
                              style: TextStyle(
                                  color: Colors.blue.shade700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate('F_NAME'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.local_hospital),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'P_E_F_N' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate('F_TYPE'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _facilityTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate('ADDRESS_2'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    validator: (value) => value?.isEmpty ?? true
                        ? autoI8lnGen.translate('VALIDATION_Q_16')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: autoI8lnGen.translate('PHONE_NUMBER'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFacility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : AutoText('S_O_F',
                              style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HealthFacility model — unchanged
// ─────────────────────────────────────────────────────────────────────────────

class HealthFacility {
  final String id;
  final String name;
  final String type;
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final String country;
  final String state;
  final String lga;
  final String area;
  final bool status;

  HealthFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.state,
    required this.lga,
    required this.area,
    required this.status,
  });

  factory HealthFacility.fromMap(String id, Map<String, dynamic> data) {
    double lat = 0.0;
    double lng = 0.0;

    if (data['location'] is GeoPoint) {
      final geoPoint = data['location'] as GeoPoint;
      lat = geoPoint.latitude;
      lng = geoPoint.longitude;
    } else {
      double extract(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      lat = extract(data['latitude']);
      lng = extract(data['longitude']);
    }

    return HealthFacility(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      latitude: lat,
      longitude: lng,
      country: data['country'] ?? '',
      state: data['state'] ?? '',
      lga: data['lga'] ?? '',
      area: data['area'] ?? '',
      status: data['status'] ?? false,
    );
  }

  bool hasValidCoordinates() => latitude != 0.0 && longitude != 0.0;
  void debugCoordinates() {}
}
