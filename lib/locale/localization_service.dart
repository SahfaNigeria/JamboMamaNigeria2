// import 'package:flutter_localization/flutter_localization.dart';
//
// const List<MapLocale> AppLocale = [
//   MapLocale("en", LocalizationService.EN),
//   MapLocale("sw", LocalizationService.SWA),
//   MapLocale("fr", LocalizationService.FR),
//   MapLocale("pt", LocalizationService.PT),
//   MapLocale("kg", LocalizationService.KG),
//   MapLocale("so", LocalizationService.SO),
//   MapLocale("ny", LocalizationService.NY),
// ];
//
// mixin LocalizationService {
//   static const String followYourPregnancy = "Follow your Pregnancy ";
//   static const String week = "Week";
//
//   // english
//   static const Map<String, dynamic> EN = {
//     followYourPregnancy: "Follow your Pregnancy ",
//     week: "Week %a",
//   };
//
//   // swahili
//   static const Map<String, dynamic> SWA = {
//     followYourPregnancy: "Fuata ujauzito wako",
//     week: "Wiki %a",
//   };
//
//   // french
//   static const Map<String, dynamic> FR = {
//     followYourPregnancy: "Suivez votre grossesse",
//     week: "Semaine %a",
//   };
//
//   // portugal
//   static const Map<String, dynamic> PT = {
//     followYourPregnancy: "Acompanhe sua gravidez",
//     week: "Semana %a",
//   };
//
//   // kikongo
//   static const Map<String, dynamic> KG = {
//     followYourPregnancy: "Landakana zayina na nge",
//     week: "Ndinga %a",
//   };
//
//   // Somali
//   static const Map<String, dynamic> SO = {
//     followYourPregnancy: "Raac uurkaaga",
//     week: "Usbuuc %a",
//   };
//
//   // Chichewa
//   static const Map<String, dynamic> NY = {
//     followYourPregnancy: "Tsatirani pakati panu",
//     week: "Sabata %a",
//   };
//
//   // static const Map<String, dynamic> EN = {
//   //
//   // };
// }

import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? locale = prefs.getString('auto_i8ln_locale');
    autoI8lnGen.setLocale(
      locale,

    );
    // ! NEXT: Initialize locale
    final content = await rootBundle.loadString(autoI8lnGen.getGenPath());
    autoI8lnGen.initializeLocale(content);
  }
}
