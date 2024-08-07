import 'package:flutter/material.dart';

class Fypcomponent extends StatelessWidget {
  final String timetext;
  final String imagePath;
  final String firstparagraph;
  final String secparagraph;
  final String thirdparagraph;
  final String baby;
  final String you;
  final void Function() onTap;
  final void Function() onClick;

  const Fypcomponent({
    Key? key,
    required this.timetext,
    required this.imagePath,
    required this.firstparagraph,
    required this.secparagraph,
    required this.thirdparagraph,
    required this.baby,
    required this.you,
    required this.onTap,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: onClick,
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 241, 112, 103),
                      ),
                      child: Center(child: Text(you)),
                    )),
                const SizedBox(
                  width: 30,
                ),
                GestureDetector(
                    onTap: onTap,
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 241, 112, 103),
                      ),
                      child: Center(child: Text(baby)),
                    )),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(timetext),
              ),
              Image.asset(imagePath),
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10, left: 10, right: 10),
                child: Text(firstparagraph),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Text(secparagraph),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Text(thirdparagraph),
              )
            ],
          ),
        ],
      ),
    );
  }
}
