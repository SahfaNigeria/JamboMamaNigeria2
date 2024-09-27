import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/banner_component.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/midwives/views/components/midwife_home_drawer.dart';
import 'package:jambomama_nigeria/midwives/views/screens/account_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/directory_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/patients.dart';

import '../../../views/mothers/learn_question_screen.dart';

class MidWifeHomePage extends StatelessWidget {
  const MidWifeHomePage({super.key});

  Future<Map<String, dynamic>> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Health Professionals')
          .doc(user.uid)
          .get();

      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception('No user logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_active_outlined),
          )
        ],
      ),
      drawer: HealthProviderHomeDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No user data found'));
          }

          var userData = snapshot.data!;
          String title = userData['position'] ?? 'Health Professional';
          String name = userData['fullName'] ?? 'User';
          String profilePictureUrl = userData['midWifeImage'] ?? '';

          return ListView(
            children: [
              FrontBanner(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(30),
                        image: profilePictureUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(profilePictureUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profilePictureUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Hello!👋 ',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      '$title, $name.',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HomeComponents(
                        text: 'Patients',
                        icon: 'assets/svgs/logo_Jambomama.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Patients(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: 170,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HomeComponents(
                        text: 'Directory',
                        icon: 'assets/svgs/file_directory.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DirectoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HomeComponents(
                      text: 'Learn',
                      icon: 'assets/svgs/learn_medicine.svg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuestionairePregnantFeelingsForm(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 170,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HomeComponents(
                      text: 'My Account',
                      icon: 'assets/svgs/person_account.svg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountScreen(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
