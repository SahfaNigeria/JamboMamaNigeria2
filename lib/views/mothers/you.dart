import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/fyp_component.dart';
import 'package:jambomama_nigeria/views/mothers/baby.dart';

class You extends StatelessWidget {
  const You({super.key});

  @override
  Widget build(BuildContext context) {
    void navToBabyPage() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Baby()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoText(
          "FOLLOW_YOUR_PREGNANCY",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        children: [
          Fypcomponent(
            timetext: "WEEK_1-3",
            imagePath: 'assets/images/firstgirl.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_32',
            secparagraph:
                'HEALTH_DESCRIPTION_33',
            thirdparagraph: '',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_4-7',
            imagePath: 'assets/images/breast changes.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_34',
            secparagraph:
                'HEALTH_DESCRIPTION_35',
            thirdparagraph:
                'HEALTH_DESCRIPTION_36',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_8-11',
            imagePath: 'assets/images/tired.jpeg',
            firstparagraph:
                'HEALTH_DESCRIPTION_37',
            secparagraph:
                'HEALTH_DESCRIPTION_38',
            thirdparagraph:
                'HEALTH_DESCRIPTION_39',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_12-15',
            imagePath: 'assets/images/prenatal-clinic.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_40',
            secparagraph:
                'HEALTH_DESCRIPTION_41',
            thirdparagraph:
                'HEALTH_DESCRIPTION_42',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_16-19',
            imagePath: 'assets/images/eating fruits.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_43',
            secparagraph:
                'HEALTH_DESCRIPTION_44',
            thirdparagraph:
                'HEALTH_DESCRIPTION_45',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_20-23',
            imagePath: 'assets/images/antenatal care.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_46',
            secparagraph:
                'HEALTH_DESCRIPTION_47',
            thirdparagraph:
                'HEALTH_DESCRIPTION_48',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_24-27',
            imagePath: 'assets/images/seven months.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_49',
            secparagraph:
                'HEALTH_DESCRIPTION_50',
            thirdparagraph: '',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_28-31',
            imagePath: 'assets/images/eight monthjpg.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_51',
            secparagraph:
                'HEALTH_DESCRIPTION_52',
            thirdparagraph:
                'HEALTH_DESCRIPTION_53',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_32-35',
            imagePath: 'assets/images/35 week.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_54',
            secparagraph:
                'HEALTH_DESCRIPTION_55',
            thirdparagraph:
                'HEALTH_DESCRIPTION_56',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_36-37',
            imagePath: 'assets/images/old pregnant woman.jpeg',
            firstparagraph:
                'HEALTH_DESCRIPTION_57',
            secparagraph:
                'HEALTH_DESCRIPTION_58',
            thirdparagraph: 'HEALTH_DESCRIPTION_59',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_38-42',
            imagePath: 'assets/images/islamic.jpg',
            firstparagraph: 'HEALTH_DESCRIPTION_60',
            secparagraph:
                'HEALTH_DESCRIPTION_61',
            thirdparagraph:
                'HEALTH_DESCRIPTION_62',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK_38-42',
            imagePath: 'assets/images/delivered.jpg',
            firstparagraph:
                'HEALTH_DESCRIPTION_63',
            secparagraph:
                'HEALTH_DESCRIPTION_64',
            thirdparagraph:
                'HEALTH_DESCRIPTION_65',
            baby: "BABY",
            you: "YOU",
            onTap: navToBabyPage,
            onClick: () {},
          ),
        ],
      ),
    );
  }
}
