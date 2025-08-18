import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';

class DrawerTiles extends StatelessWidget {
  final String text;
  final IconData icon;
   final String? subtitle;
  final void Function()? onTap;
  const DrawerTiles(
      {super.key, required this.icon, required this.onTap, required this.text, this.subtitle });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoText(
        text,
        style: const TextStyle(),
      ),
      subtitle: subtitle != null ? AutoText(subtitle!) : null,
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
