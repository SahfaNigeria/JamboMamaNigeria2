import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Map<String, String> kNavigableScreens = {
  'birth_plan': '/BirthPlanScreen',
  // 'home': '/HomePage',
  // 'connection': '/ConnectionScreen',
  // add more as you build them
};

class LinkedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? defaultStyle;

  const LinkedTextWidget({
    Key? key,
    required this.text,
    this.defaultStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: defaultStyle ?? TextStyle(fontSize: 14, color: Colors.black87),
        children: _buildSpans(context),
      ),
    );
  }

  List<TextSpan> _buildSpans(BuildContext context) {
    final List<TextSpan> spans = [];
    final RegExp pattern = RegExp(r'\{([^|]+)\|([^}]+)\}');
    int lastIndex = 0;

    for (final match in pattern.allMatches(text)) {
      // Plain text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final label = match.group(1)!;
      final routeKey = match.group(2)!.trim();

      spans.add(TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _handleNavigation(context, routeKey),
      ));

      lastIndex = match.end;
    }

    // Remaining plain text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return spans;
  }

  // ── All navigation logic lives here ──
  void _handleNavigation(BuildContext context, String routeKey) {
    switch (routeKey) {
      // Routes that need arguments
      case 'birth_plan':
        final patientId = FirebaseAuth.instance.currentUser?.uid;
        if (patientId == null) return;
        Navigator.pushNamed(
          context,
          '/BirthPlanScreen',
          arguments: {'patientId': patientId},
        );
        break;

      // Add other argument-requiring routes here the same way
      // case 'chat':
      //   Navigator.pushNamed(
      //     context,
      //     '/ChatScreen',
      //     arguments: {'chatId': 'xxx', ...},
      //   );
      //   break;

      // Routes that need NO arguments
      default:
        final route = kNavigableScreens[routeKey];
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else {
          debugPrint('LinkedTextWidget: unknown routeKey "$routeKey"');
        }
    }
  }
}

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';

// const Map<String, String> kNavigableScreens = {
//   'birth_plan_screen': '/BirthPlanScreen',
//   // 'contact_doctor': '/ContactDoctorScreen',
//   // 'appointments': '/AppointmentsScreen',
//   // add all your screen routes here
// };

// class LinkedTextWidget extends StatelessWidget {
//   final String text;
//   final TextStyle? defaultStyle;

//   const LinkedTextWidget({
//     Key? key,
//     required this.text,
//     this.defaultStyle,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return RichText(
//       text: TextSpan(
//         style: defaultStyle ?? TextStyle(fontSize: 14, color: Colors.black87),
//         children: _buildSpans(context),
//       ),
//     );
//   }

//   List<TextSpan> _buildSpans(BuildContext context) {
//     final List<TextSpan> spans = [];
//     final RegExp pattern = RegExp(r'\{([^|]+)\|([^}]+)\}');
//     int lastIndex = 0;

//     for (final match in pattern.allMatches(text)) {
//       if (match.start > lastIndex) {
//         spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
//       }

//       final label = match.group(1)!;
//       final routeKey = match.group(2)!.trim();
//       final route = kNavigableScreens[routeKey];

//       spans.add(TextSpan(
//         text: label,
//         style: TextStyle(
//           color: Colors.blue,
//           fontWeight: FontWeight.bold,
//           decoration: TextDecoration.underline,
//         ),
//         recognizer: TapGestureRecognizer()
//           ..onTap = () {
//             if (route != null) {
//               Navigator.pushNamed(context, route);
//             }
//           },
//       ));

//       lastIndex = match.end;
//     }

//     if (lastIndex < text.length) {
//       spans.add(TextSpan(text: text.substring(lastIndex)));
//     }

//     return spans;
//   }
// }
