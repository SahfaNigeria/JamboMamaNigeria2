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
      title: Text(
        text,
        style: const TextStyle(),
      ),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
