import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';

class DrawerTiles extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function()? onTap;
  const DrawerTiles(
      {super.key, required this.icon, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoText(
        text,
        style: const TextStyle(),
      ),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
