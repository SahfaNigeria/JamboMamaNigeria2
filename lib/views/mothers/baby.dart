import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/fyp_component.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';

class Baby extends StatelessWidget {
  const Baby({super.key});

  @override
  Widget build(BuildContext context) {
    void navToYouPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const You()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:  AutoText(
          "FOLLOW_PREGNANCY",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        children: [
          Fypcomponent(
            timetext: 'HOW_IT_STARTS',
            imagePath: 'assets/images/2 weeks.jpg',
            firstparagraph:
                'F_P_1',
            secparagraph:
                'F_P_2',
            thirdparagraph: '',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_4',
            imagePath: 'assets/images/week-5.jpg',
            firstparagraph:
                'F_P_3',
            secparagraph:
                'F_P_4',
            thirdparagraph:
                'F_P_5',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'TIME_TEXT_1',
            imagePath: 'assets/images/week 12.jpg',
            firstparagraph:
                'F_P_6',
            secparagraph:
                'F_P_7',
            thirdparagraph: '',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'TIME_TEXT_2',
            imagePath: 'assets/images/week 16.jpg',
            firstparagraph:
                'F_P_8',
            secparagraph:
                'F_P_9',
            thirdparagraph:
                'F_P_10',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_3',
            imagePath: 'assets/images/week 21.jpg',
            firstparagraph:
                'F_P_11',
            secparagraph:
                'F_P_12',
            thirdparagraph:
                'F_P_13',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_24',
            imagePath: 'assets/images/24 week.jpg',
            firstparagraph:
                'F_P_15',
            secparagraph:
                'F_P_16',
            thirdparagraph: '',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_28',
            imagePath: 'assets/images/week 27.jpg',
            firstparagraph:
                'F_P_17',
            secparagraph:
                'F_P_18',
            thirdparagraph:
                'F_P_19',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_35',
            imagePath: 'assets/images/30 week.jpg',
            firstparagraph:
                'F_P_20',
            secparagraph:
                'F_P_21',
            thirdparagraph: '',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_39',
            imagePath: 'assets/images/37 week.jpg',
            firstparagraph:
                'F_P_22',
            secparagraph:
                'F_P_23',
            thirdparagraph:
                'F_P_24',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK_40',
            imagePath: 'assets/images/delivered baby.jpg',
            firstparagraph:
                'F_P_25',
            secparagraph:
                'F_P_26',
            thirdparagraph:
                'F_P_27',
            baby: 'BABY',
            you: 'YOU',
            onTap: () {},
            onClick: navToYouPage,
          ),
        ],
      ),
    );
  }
}
