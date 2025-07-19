import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';

showSnackMessage(context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: AutoText(title),
    ),
  );
}
