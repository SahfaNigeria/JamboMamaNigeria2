import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/models/link_widget.dart';

class Fypcomponent extends StatelessWidget {
  final String timetext;
  final String title;
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
    required this.title,
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
      width: screenWidth,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFFFDF6F3),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week text
                  Center(
                    child: Text(
                      timetext,
                      // style: GoogleFonts.nunito(
                      //   fontSize: 20,
                      //   fontWeight: FontWeight.bold,
                      //   color: Colors.pink.shade700,
                      // ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // color: Colors.pink.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imagePath,
                      width: double.infinity,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('IMAGE ERROR: $error');
                        debugPrint('IMAGE PATH: $imagePath');
                        return Container(
                          height: screenHeight * 0.3,
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image, size: 60),
                                const SizedBox(height: 8),
                                Text(
                                  imagePath.isEmpty
                                      ? 'No URL'
                                      : imagePath.substring(
                                          0, imagePath.length.clamp(0, 60)),
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // First paragraph
                  // Text(
                  //   firstparagraph,
                  //   // // style: GoogleFonts.nunito(
                  //   // //   fontSize: 15,
                  //   // //   height: 1.6,
                  //   // //   color: Colors.grey.shade800,
                  //   // ),
                  // ),
                  LinkedTextWidget(text: firstparagraph),

                  const SizedBox(height: 10),

                  // Second paragraph
                  // Text(
                  //   secparagraph,
                  //   // // style: GoogleFonts.nunito(
                  //   // //   fontSize: 15,
                  //   // //   height: 1.6,
                  //   // //   color: Colors.grey.shade800,
                  //   // ),
                  // ),
                  LinkedTextWidget(text: secparagraph),
                  const SizedBox(height: 10),

                  // Third paragraph
                  // Text(
                  //   thirdparagraph,
                  //   // style: GoogleFonts.nunito(
                  //   //   fontSize: 15,
                  //   //   height: 1.6,
                  //   //   color: Colors.grey.shade800,
                  //   // ),
                  // ),
                  LinkedTextWidget(text: thirdparagraph),
                  const SizedBox(height: 20),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onClick,
                        icon: const Icon(Icons.favorite, size: 18),
                        label: Text(you),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.child_friendly, size: 18),
                        label: Text(baby),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
