import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/views/mothers/learn_question_screen.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  void login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  AutoText('LEARN'),
        centerTitle: true,
      ),
      // drawer: const HomeDrawer(),
      body: ListView(
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 320,
                color: Colors.blueAccent,
                child: HomeComponents(
                  text: 'FOLLOW_YOUR_PREGNANCY',
                  icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const You()),
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                width: 170,
                height: 320,
                color: Colors.purple,
                child: HomeComponents(
                  text: 'P_Q',
                  icon: 'assets/svgs/perfusion-svgrepo-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              QuestionairePregnantFeelingsForm()),
                    );
                  },
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 320,
                color: Colors.green,
                child: HomeComponents(
                  text: 'VITAL_INFO_UPDATE_2',
                  icon: 'assets/svgs/doctor-svgrepo-com.svg',
                  onTap: () {},
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                width: 170,
                height: 320,
                color: Colors.red,
                child: HomeComponents(
                  text: 'FOLLOW_YOUR_PREGNANCY',
                  icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
                  onTap: () {},
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
