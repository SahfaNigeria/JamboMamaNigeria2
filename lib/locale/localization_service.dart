import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> AppLocale = [
  MapLocale("en", LocalizationService.EN),
  MapLocale("sw", LocalizationService.SWA),
  MapLocale("fr", LocalizationService.FR),
  MapLocale("pt", LocalizationService.PT),
  MapLocale("kg", LocalizationService.KG),
  MapLocale("so", LocalizationService.SO),
  MapLocale("ny", LocalizationService.NY),
];

mixin LocalizationService {
  static const String title = "title";
  static const String body = "body";

  // english
  static const Map<String, dynamic> EN = {
    title: "",
    body: "",
  };

  // swahili
  static const Map<String, dynamic> SWA = {
    title: "",
    body: "",
  };

  // french
  static const Map<String, dynamic> FR = {
    title: "",
    body: "",
  };

  // portugal
  static const Map<String, dynamic> PT = {
    title: "",
    body: "",
  };

  // kikongo
  static const Map<String, dynamic> KG = {
    title: "",
    body: "",
  };

  // Somali
  static const Map<String, dynamic> SO = {
    title: "",
    body: "",
  };

  // Chichewa
  static const Map<String, dynamic> NY = {
    title: "",
    body: "",
  };

  // static const Map<String, dynamic> EN = {
  //
  // };
}
