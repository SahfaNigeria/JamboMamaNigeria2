import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Something extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String icon;

  const Something(
      {Key? key, required this.text, required this.onTap, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation of the Something widget
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: SvgPicture.asset(
                icon,
                width: 80,
                height: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
              ),
            )),
            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}
