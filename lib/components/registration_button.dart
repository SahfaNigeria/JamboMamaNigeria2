import 'package:flutter/material.dart';

class RegistrationButton extends StatelessWidget {
  final String text;
  final IconData icon;

  final void Function()? onTap;
  const RegistrationButton(
      {super.key, required this.text, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 90,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color.fromARGB(255, 176, 10, 1)),
      child: Center(
          child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      )),
    );
  }
}
