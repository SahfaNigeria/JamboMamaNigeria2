import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/views/mothers/guest_feeling_form.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';
import 'package:jambomama_nigeria/views/mothers/guest_delivery_date.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  // Helper method to show the snackbar to avoid repeating code
  void _showGuestLimitSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AutoText('GUEST_LIMIT_MESSAGE'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Grid Settings
    const double spacing = 10.0;
    // We subtract the total horizontal padding (10 left + 10 right + 10 middle)
    final double cardWidth = (screenWidth - (spacing * 3)) / 2;
    final double cardHeight = screenHeight * 0.22;
    final double aspectRatio = cardWidth / cardHeight;

    return Scaffold(
      appBar: AppBar(
        title: const AutoText('LEARN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            // --- DUE DATE CALCULATOR BUTTON ---
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GuestExpectedDeliveryScreen(),
                  ),
                );
              },
              child: Container(
                height: 45, // Slightly increased for better tap area
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    AutoText(
                      'CALCULATE_DUE_DATE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // --- GRID OF CARDS ---
            // GridView.count ensures all cards remain the same size
            // regardless of the text length in different languages.
            GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // ListView handles scroll
              crossAxisCount: 2,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
              children: [
                // Card 1: Follow Your Pregnancy
                _buildCard(
                  color: Colors.blueAccent,
                  text: 'FOLLOW_YOUR_PREGNANCY',
                  icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const You()),
                    );
                  },
                ),

                // Card 2: Periodic Questionnaire
                _buildCard(
                  color: Colors.purple,
                  text: 'P_Q',
                  icon: 'assets/svgs/perfusion-svgrepo-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GuestFeelingsForm()),
                    );
                  },
                ),

                // Card 3: Vital Info Update
                _buildCard(
                  color: Colors.green,
                  text: 'VITAL_INFO_UPDATE_2',
                  icon: 'assets/svgs/doctor-svgrepo-com.svg',
                  onTap: () => _showGuestLimitSnackBar(context),
                ),

                // Card 4: Something Happened
                _buildCard(
                  color: Colors.red.shade500,
                  text: 'SOMETHING_HAPPENED',
                  icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
                  onTap: () => _showGuestLimitSnackBar(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep the code clean and ensure consistent styling
  Widget _buildCard({
    required Color color,
    required String text,
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: HomeComponents(
        text: text,
        icon: icon,
        onTap: onTap,
      ),
    );
  }
}
