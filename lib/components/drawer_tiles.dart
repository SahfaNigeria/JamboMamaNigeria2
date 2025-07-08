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
      title: Text(
        text,
        style: const TextStyle(),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
