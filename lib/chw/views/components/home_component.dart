import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeComponents extends StatelessWidget {
  final String text;
  // final IconData icon;
  final String icon;
  final void Function()? onTap;

  const HomeComponents(
      {super.key, required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: SvgPicture.asset(
                icon,
                width: 130,
                height: 130,
                color: Colors.white,
              ),
            )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
