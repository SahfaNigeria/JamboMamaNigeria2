import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropDownButton extends StatefulWidget {
  const DropDownButton({Key? key}) : super(key: key);

  @override
  State<DropDownButton> createState() => _DropDownButtonState();
}

class _DropDownButtonState extends State<DropDownButton> {
  final Map<String, String> languageMap = {
    "en": autoI8lnGen.translate("ENGLISH"),
    "sw": autoI8lnGen.translate("SWAHILI"),
    "fr": autoI8lnGen.translate("FRENCH"),
    "pt": autoI8lnGen.translate("PORTUGUESE"),
    "kg": autoI8lnGen.translate("KIKONGO"),
    "ny": autoI8lnGen.translate("CHICHEWA"),
    "so": autoI8lnGen.translate("SOMALI"),
  };

  String? selectedValue;
  _loadCurrentLocale() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? storedV = preferences.getString("auto_i8ln_locale"); // ✅ correct key
    setState(() {
      selectedValue = storedV;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCurrentLocale();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: AutoText(
          'SELECT_ITEM',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: languageMap.entries
            .map((entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (String? value) async {
          if (value == null) return;

          autoI8lnGen.setLocale(value);
          final content = await rootBundle.loadString(autoI8lnGen.getGenPath());
          autoI8lnGen.initializeLocale(content);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('auto_i8ln_locale', value);
          prefs.setString('stored_locale', languageMap[value] ?? "");

          setState(() {
            selectedValue = value;
          });

          Restart.restartApp();
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: 300,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
      ),
    );
  }
}
