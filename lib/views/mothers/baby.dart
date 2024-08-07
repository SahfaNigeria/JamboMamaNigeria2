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
            timetext: 'How it starts: Week 2',
            imagePath: 'assets/images/2 weeks.jpg',
            firstparagraph:
                'Your pregnancy starts when during sexual congress the mans sperm fertilizes an egg in your womb.',
            secparagraph:
                ' At the start of this week, you ovulate. Your egg is fertilized 12 to 24 hours later if a sperm penetrates it. Over the next several days, the fertilized egg (called a zygote) will start dividing into multiple cells as it travels down the fallopian tube, enters your uterus, and starts to burrow into the uterine lining..',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK 4',
            imagePath: 'assets/images/week-5.jpg',
            firstparagraph:
                'Your ball of cells is now officially an embryo. You are now about 4 weeks from the beginning of your last period',
            secparagraph:
                'Now a start is made with his face and neck. The heart and veins continue to develop. The lungs, stomach and liver start to develop too.',
            thirdparagraph:
                'It is around this time – when your next period would normally be due –  that you might be able to get a positive result on a home pregnancy test.',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'Your baby is 12 weeks old',
            imagePath: 'assets/images/week 12.jpg',
            firstparagraph:
                'He measures about 5cm and starts to make its own movement. The baby heartbeat can be heard but only with a special instrument. ',
            secparagraph:
                ' This week your babys reflexes kick in: Their fingers will soon begin to open and close, toes will curl, and their mouth will make sucking movements.',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'Your Baby is 16 weeks old',
            imagePath: 'assets/images/week 16.jpg',
            firstparagraph:
                ' The babys eyes can blink and the heart and blood vessels are fully formed. The patterning on your babys scalp has begun, though their hair is not visible yet.',
            secparagraph:
                'Their legs are more developed, their head is more upright, and their ears are close to their final position. The babys fingers and toes have fingerprints. The baby now measures about 11-12cm and weighs about 100 grams. ',
            thirdparagraph:
                'The top of your uterus (belly) is now 7.8cm below your belly button.',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK 16-19',
            imagePath: 'assets/images/week 21.jpg',
            firstparagraph:
                'Add some meat, fish, beans or eggs with your cassava or plantain stew to give energy to your baby. ',
            secparagraph:
                'Add every day some fruit and leafy veggies, peanuts are good too, reduce salt in your food.',
            thirdparagraph:
                ' You should be less nauseous now. If nausea continues, tell your health worker at antenatal clinic',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'Week 24 ',
            imagePath: 'assets/images/24 week.jpg',
            firstparagraph:
                'His weight is 500-600 grams now. He responds to sounds by moving or his heat beats faster. If you feel jerking motions he has hiccups. The baby may feel it is upside down in the womb. He can hear music, your voice, feel your movement, feel your hands when you tour him. ',
            secparagraph:
                'Your baby cuts a pretty long and lean figure, but chubbier times are coming. Their skin is still thin and translucent, but that will begin to change soon too',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK 28',
            imagePath: 'assets/images/week 27.jpg',
            firstparagraph:
                'The baby is 35cm long and weighs a kilo. He moves around and kicks a lot now. He is playing if labour started too early, your baby could survive but it is really better he stays inside for 10 weeks more!.',
            secparagraph:
                ' Your babys eyesight is developing, which may enable them to sense light filtering in from the outside. They can blink, and their eyelashes have grown in .',
            thirdparagraph:
                'Ask your doctor about preterm labour warning signs. Re view your birth plan and prepare yourself for childbirth, learn the anger and warning signs, and how labour starts. ',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'WEEK 35',
            imagePath: 'assets/images/30 week.jpg',
            firstparagraph:
                'The baby weighs almost 2kgs now and is moving around a lot. Skin wrinkles disappear as fat starts to fprm under the skin. Between now and his birth, your baby will gain up between one to two kilos more  ',
            secparagraph:
                ' You are probably gaining about a pound a week now. Half of that goes straight to your baby, who will gain one-third to half their birth weight in the next seven weeks in preparation for life outside the womb ',
            thirdparagraph: '',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'Week 39',
            imagePath: 'assets/images/37 week.jpg',
            firstparagraph:
                ' Babies differ in size, Boys are often bigger than bigger than girls, twins are smaller thasingletons, the parents are bigger or smaller.  ',
            secparagraph:
                'If your baby is smalll but growing steadily is OK. At this stage he is about 47cm and weighs close to 2,7kg. The brain and lungs are nearly finished. ',
            thirdparagraph:
                'The head is facing downwards by now, ready for the birth. Birth between 37-42 weeks is best.  ',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
          Fypcomponent(
            timetext: 'Week 40 ',
            imagePath: 'assets/images/delivered baby.jpg',
            firstparagraph:
                'There he is! The babys due date for full growth is calculated for 40 weeks of gestation, but a full term birth can be fro week 38 thruough 42. ',
            secparagraph:
                'If labour doesnt start spontaneously at 42 weeks, labour may be medically induced by the health provider for the babys and your own safety. ',
            thirdparagraph:
                'If youre past your due date, you may not be as late as you think, especially if you calculated it solely based on the day of your last period. Sometimes women ovulate later than expected.',
            baby: 'Baby',
            you: 'You',
            onTap: () {},
            onClick: navToYouPage,
          ),
        ],
      ),
    );
  }
}
