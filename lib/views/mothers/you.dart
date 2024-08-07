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
        title: const Text(
          "Follow your Pregnancy ",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: ListView(
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(),
        children: [
          Fypcomponent(
            timetext: 'WEEK 1-3',
            imagePath: 'assets/images/firstgirl.jpg',
            firstparagraph:
                'Right from the start, alcohol, smoking and drugs (iNcluding herbal teas) can seriously damage your babys health.',
            secparagraph:
                ' This is  why it is important to know if you are expecting a child and seek advice and assistance from qualified health providers early.',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 4-7',
            imagePath: 'assets/images/breast changes.jpg',
            firstparagraph:
                'One month in, your breats may become tender and swollen already. You feel like vomiiting often? In a few weeks it will be over',
            secparagraph:
                'Drinking light tea and eating only small portions of food at a time, not too fat, sagary or salty, will reduce the nausea.',
            thirdparagraph:
                'For the health of your child, dont drink alcohol, dont use herbal teas nor use tobacco or hemp like products. Eat healthy food.',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 8-11',
            imagePath: 'assets/images/tired and nauseous.png',
            firstparagraph:
                'At 8-11 weeks, theres nothing to see yet but you may feel tired and often nauseous especially in the morning. It will pass in a few weeks',
            secparagraph:
                'Drinking light tea and eating only small portions with no fat and too salty helps',
            thirdparagraph:
                'If you are still feeling nauseous often after 12 weeks, tell your referent health provider ',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 12-15',
            imagePath: 'assets/images/prenatal-clinic.jpg',
            firstparagraph:
                'You missed your period twice? You are still nauseous and your breats feel a bit heavier. ',
            secparagraph:
                'You may have noticed, few others will, but it is good to go to the ANC clinic now to get a healthy start of your pregnancy with check ups for harmful infections, advice and vitamin supplements.',
            thirdparagraph:
                'And, if neccessary medication, to keep you and your baby as safe and healthy as possible. Ask your partner to come along.',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 16-19',
            imagePath: 'assets/images/eating fruits.jpg',
            firstparagraph:
                'Add some meat, fish, beans or eggs with your cassava or plantain stew to give energy to your baby. ',
            secparagraph:
                'Add every day some fruit and leafy veggies, peanuts are good too, reduce salt in your food.',
            thirdparagraph:
                ' You should be less nauseous now. If nausea continues, tell your health worker at antenatal clinic',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 20 to 23',
            imagePath: 'assets/images/antenatal care.jpg',
            firstparagraph:
                'By week 20-23, you should begin to feel the baby kick and move if you lie still.',
            secparagraph:
                'Still 18 - 20 weeks before the baby is due, but something can happen that makes him/her try to come earlier, so prepared',
            thirdparagraph:
                'At your next antenatal visit, go with your husband or trusted person and discuss your birth and emergency plan with the clinic attendants',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 24 to 27',
            imagePath: 'assets/images/seven months.jpg',
            firstparagraph:
                'This mom is around 24 weeks (7 months) pregnant. She is glowing with health. She is eating healthy food, she takes moderate exercise, she takes a bit more rest but not too much.',
            secparagraph:
                'Now the baby will start growing very fast, so eat plenty of proteins ( fishes, eggs, meats, milk and green leaves and all vegetables and fruits of the season). Be careful, your baby may announce itself early.',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 28 -31',
            imagePath: 'assets/images/eight monthjpg.jpg',
            firstparagraph:
                'Three months or less left before the birth is your Birth plan ready?',
            secparagraph:
                'Your belly should be growing fast now  and your breast growing and becoming more tender preparing for nursing ',
            thirdparagraph:
                'Take afternon naps. Keep active but not heavy load lifting or hoeing',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 32 - 35',
            imagePath: 'assets/images/35 week.jpg',
            firstparagraph:
                'Your belly is quite huge now and it will still increase a lot more as your baby gains 1 to 2 kg more',
            secparagraph:
                'A yellow fluid may leak from your breats. That is called colostrum, and it happens to get your your breasts ready for making milk',
            thirdparagraph:
                'If possible go to the ANC clinic every two weeks at this stage of pregnancy if you cant go, connect with your health provider through JamboMama',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 36-37',
            imagePath: 'assets/images/old pregnant woman.jpeg',
            firstparagraph:
                'Your pregnancy is now around 36 weeks: the birth is near! Birth plan ready? Trusted person ready? Everything ready? Go to your birth plan one more time!',
            secparagraph:
                'Advice: When you become heavy it is safest to sleep on your left side to keep the oxygen and blood flowing to your baby',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 38-42',
            imagePath: 'assets/images/islamic.jpg',
            firstparagraph: 'Your baby is still not there? ',
            secparagraph:
                'if your baby is not there yet, be ready to go the health facilty any moment. Make sure your baby keeps moving and sleep and rest on the left side. If it past 40 Weeks and nothing happens, call your RHP. ',
            thirdparagraph:
                'You should be kept under close watch. If the birth doesnt start by itself by week 42, contractions (labour pains) may be induced. ',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
          Fypcomponent(
            timetext: 'WEEK 38-42',
            imagePath: 'assets/images/delivered.jpg',
            firstparagraph:
                'Your baby is born! Congratulation! You went to the hospital on time.',
            secparagraph:
                'Rest well, breastfeed your baby and stay in touch with your healthprovider!. The first ten days are still high risk. Watch for these danger signs for yourself. Fever, bleeding, or smelly discharge from vagina, convulsions.',
            thirdparagraph:
                'In your baby: fever, convultion, difficulty breathing, no movement, listless sucking. Call emergency help for you baby instantly when you are worried about anything!',
            baby: 'Baby',
            you: 'You',
            onTap: navToBabyPage,
            onClick: () {},
          ),
        ],
      ),
    );
  }
}
