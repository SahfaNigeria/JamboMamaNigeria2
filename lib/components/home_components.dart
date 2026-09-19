import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeComponents extends StatelessWidget {
  final String text;
  final String icon;
  final void Function()? onTap;

  const HomeComponents({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // Use InkWell for better touch feedback
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        // This horizontal padding ensures text NEVER touches the card edges
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers icon and text vertically
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Icon Section
            // We use Flexible so the icon can shrink if the text needs more room
            Flexible(
              flex: 2,
              child: SvgPicture.asset(
                icon,
                width: 60,  // Reduced width/height to leave room for long text
                height: 60,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
            
            const SizedBox(height: 12), // Space between icon and text

            // 2. Text Section
            Flexible(
              flex: 2,
              child: AutoText(
                text,
                textAlign: TextAlign.center, // Center the text horizontally
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // Slightly smaller base font for better fitting
                ),
                // Important for long languages:
                softWrap: true, 
                maxLines: 3, 
                overflow: TextOverflow.ellipsis, 
              ),
            ),
          ],
        ),
      ),  
    );
  }
}

