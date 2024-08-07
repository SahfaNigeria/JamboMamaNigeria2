import 'package:flutter/material.dart';

class FrontBanner extends StatefulWidget {
  @override
  State<FrontBanner> createState() => _FrontBannerState();
}

class _FrontBannerState extends State<FrontBanner> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
