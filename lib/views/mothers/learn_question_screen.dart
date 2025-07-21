import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';

class QuestionairePregnantFeelingsForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('P_F_F_4'),
      ),
      body: FeelingsForm(),
    );
  }
}

class FeelingsForm extends StatefulWidget {
  @override
  _FeelingsFormState createState() => _FeelingsFormState();
}

class _FeelingsFormState extends State<FeelingsForm> {
  final List<String> _questions = [
    autoI8lnGen.translate("HQ_1"),
    autoI8lnGen.translate("HQ_2"),
    autoI8lnGen.translate("HQ_3"),
    autoI8lnGen.translate("HQ_4"),
    autoI8lnGen.translate("HQ_5"),
    autoI8lnGen.translate("HQ_6"),
    autoI8lnGen.translate("HQ_7"),
    autoI8lnGen.translate("HQ_8"),
    autoI8lnGen.translate("HQ_9"),
    autoI8lnGen.translate("HQ_10"),
  ];

  final List<String> _responses = List.filled(10, '');
  final List<String> _medicalResponses = List.filled(10, '');
  final List<bool> _isAnswered = List.filled(10, true);

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: AutoText(
                    'TODAY_IS',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Center(
                  child: Text(
                      '${now.year}-${_formatTwoDigits(now.month)}-${_formatTwoDigits(now.day)}',
                      style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < 10; i++) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isAnswered[i]
                          ? Colors.grey
                          : Colors.red, // Border color
                      width: 2.0, // Border width
                    ),
                    borderRadius:
                        BorderRadius.circular(10.0), // Optional: Border radius
                  ),
                  child: Column(
                    children: [
                      Text(
                        ' ${_questions[i]}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green.shade600, // background
                            ),
                            onPressed: () {
                              _updateResponse(i, autoI8lnGen.translate("YES_2"));
                            },
                            child:  AutoText(
                              'YES_2',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // background
                            ),
                            onPressed: () {
                              _updateResponse(i, autoI8lnGen.translate("NO_2"));
                            },
                            child:  AutoText('NO_2',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // background
                              ),
                              onPressed: () {
                                _updateResponse(i, autoI8lnGen.translate("SAME_BEFORE"));
                              },
                              child: const AutoText(
                                'SAME_BEFORE',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_responses[i]}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _medicalResponses[i],
                        style: const TextStyle(
                            fontSize: 14, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ],
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: const AutoText('SUBMIT'),
          ),
        ],
      ),
    );
  }

  void _updateResponse(int index, String response) {
    setState(() {
      _responses[index] = response;
      _isAnswered[index] = true;
      _medicalResponses[index] = _triggerMedicalResponse(index, response);
    });
  }

  String _triggerMedicalResponse(int index, String response) {
    switch (index) {
      case 0:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_2")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_3")
                :  autoI8lnGen.translate("HEALTH_DESCRIPTION_4");
      case 1:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_5")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_6")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_7");
      case 2:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_8")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_9")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_10");
      case 3:
        return response == autoI8lnGen.translate("YES_2")
            ?  autoI8lnGen.translate("HEALTH_DESCRIPTION_11")
            : response == autoI8lnGen.translate("NO_2")
                ?autoI8lnGen.translate("HEALTH_DESCRIPTION_12")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_13");
      case 4:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_14")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_15")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_16");
      case 5:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_17")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_18")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_19");
      case 6:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_20")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_21")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_22");
      case 7:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_23")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_24")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_25");
      case 8:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_26")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_27")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_28");
      case 9:
        return response == autoI8lnGen.translate("YES_2")
            ? autoI8lnGen.translate("HEALTH_DESCRIPTION_29")
            : response == autoI8lnGen.translate("NO_2")
                ? autoI8lnGen.translate("HEALTH_DESCRIPTION_30")
                : autoI8lnGen.translate("HEALTH_DESCRIPTION_31");
      default:
        return '';
    }
  }

  void _submitForm() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoText(
            'NEED_TO_REGISTER'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  String _formatTwoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
