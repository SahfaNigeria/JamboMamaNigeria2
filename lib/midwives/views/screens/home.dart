import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/banner_component.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
import 'package:jambomama_nigeria/midwives/views/screens/availability_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/colleague_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/instruction_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/patients.dart';
import 'package:jambomama_nigeria/views/mothers/notification.dart';

class MidWifeHomePage extends StatelessWidget {
  MidWifeHomePage({super.key});

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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getUnreadNotificationCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: AutoText('HOME_2'),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: AutoText('HOME_2'),
              centerTitle: true,
            ),
            body: Center(child: AutoText('ERROR: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: AutoText('HOME_2'),
              centerTitle: true,
            ),
            body: Center(child: AutoText('ERROR_9')),
          );
        }

        var userData = snapshot.data!;
        String title = userData['position'] ?? 'HEALTH_PROFESSIONAL';
        String name = userData['fullName'] ?? 'USER';
        String profilePictureUrl = userData['midWifeImage'] ?? '';

        // Extract user data for drawer
        String userName = userData['fullName'] ?? '';
        String email = userData['email'] ?? '';
        String address = userData['address'] ?? '';
        String cityValue = userData['cityValue'] ?? '';
        String stateValue = userData['stateValue'] ?? '';
        String villageTown = userData['villageTown'] ?? '';
        String hospital = userData['healthFacility'] ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const AutoText('HOME_2'),
            centerTitle: true,

            actions: [
  StreamBuilder<int>(
    stream: getUnreadNotificationCount(),
    builder: (context, snapshot) {
      int unreadCount = snapshot.data ?? 0;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
          if (unreadCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  )
]
            // actions: [
            //   StreamBuilder<int>(
            //     stream: getUnreadNotificationCount(),
            //     builder: (context, snapshot) {
            //       int unreadCount = snapshot.data ?? 0;
            //       return Stack(
            //         clipBehavior: Clip.none,
            //         children: [
            //           IconButton(
            //             icon: const Icon(Icons.notifications_active),
            //             onPressed: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (_) => const NotificationsPage(),
            //                 ),
            //               );
            //             },
            //           ),
            //           if (unreadCount > 0)
            //             Positioned(
            //               right: 5,
            //               top: 5,
            //               child: Container(
            //                 width: 13,
            //                 height: 13,
            //                 decoration: const BoxDecoration(
            //                   color: Colors.red,
            //                   shape: BoxShape.circle,
            //                 ),
            //               ),
            //             ),
            //         ],
            //       );
            //     },
            //   )
            // ],
          ),
          drawer: HealthProviderHomeDrawer(
            userName: userName,
            email: email,
            address: address,
            cityValue: cityValue,
            stateValue: stateValue,
            villageTown: villageTown,
            hospital: hospital,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 24.0 : 10.0,
                  vertical: 10.0,
                ),
                children: [
                  // Profile Header
                  _buildProfileHeader(
                    profilePictureUrl,
                    title,
                    name,
                    constraints.maxWidth,
                  ),
                  SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),

                  // Responsive Grid
                  _buildResponsiveGrid(
                    context,
                    constraints.maxWidth,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    String profilePictureUrl,
    String title,
    String name,
    double screenWidth,
  ) {
    final bool isWideScreen = screenWidth > 600;
    final double avatarSize = isWideScreen ? 60 : 50;

    return Padding(
      padding: EdgeInsets.all(isWideScreen ? 16.0 : 8.0),
      child: Row(
        children: [
          Container(
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(avatarSize / 2),
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
                    size: avatarSize * 0.8,
                    color: Colors.grey.shade400,
                  )
                : null,
          ),
          SizedBox(width: isWideScreen ? 16 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoText(
                  'HELLO',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: isWideScreen ? 16 : 14,
                  ),
                ),
                Text(
                  '$title, $name.',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: isWideScreen ? 18 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, double screenWidth) {
    // Determine layout based on screen width
    final bool isTablet = screenWidth > 600;
    final bool isDesktop = screenWidth > 1200;

    int crossAxisCount = 2;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    }

    final double spacing = isTablet ? 16.0 : 8.0;
    final double childAspectRatio = isTablet ? 0.85 : 0.77;

    final List<_MenuCard> menuItems = [
      _MenuCard(
        text: 'PATIENTS',
        icon: 'assets/svgs/logo_Jambomama.svg',
        color: Colors.blueAccent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Patients()),
          );
        },
      ),
      _MenuCard(
        text: 'COLLEAGUES',
        icon: 'assets/svgs/file_directory.svg',
        color: Colors.purple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ColleagueList(location: 'Abuja'),
            ),
          );
        },
      ),
      _MenuCard(
        text: 'LEARN',
        icon: 'assets/svgs/learn_medicine.svg',
        color: Colors.green,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PractitionerContentScreen(),
            ),
          );
        },
      ),
      _MenuCard(
        text: 'Availabilty',
        icon: 'assets/svgs/person_account.svg',
        color: Colors.red.shade500,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AvailabilitySchedulePage(),
            ),
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Container(
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: HomeComponents(
            text: item.text,
            icon: item.icon,
            onTap: item.onTap,
          ),
        );
      },
    );
  }
}

class _MenuCard {
  final String text;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  _MenuCard({
    required this.text,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}



// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/components/banner_component.dart';
// import 'package:jambomama_nigeria/components/home_components.dart';
// import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/availability_screen.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/colleague_screen.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/instruction_screen.dart';

// import 'package:jambomama_nigeria/midwives/views/screens/patients.dart';

// import 'package:jambomama_nigeria/views/mothers/notification.dart';

// class MidWifeHomePage extends StatelessWidget {
//   MidWifeHomePage({super.key});

//   Future<Map<String, dynamic>> getUserDetails() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Health Professionals')
//           .doc(user.uid)
//           .get();

//       return userDoc.data() as Map<String, dynamic>;
//     } else {
//       throw Exception('No user logged in');
//     }
//   }

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<int> getUnreadNotificationCount() {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return Stream.value(0);

//     return _firestore
//         .collection('notifications')
//         .where('recipientId', isEqualTo: userId)
//         .where('read', isEqualTo: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: getUserDetails(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(
//               title: AutoText('HOME_2'),
//               centerTitle: true,
//             ),
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             appBar: AppBar(
//               title: AutoText('HOME_2'),
//               centerTitle: true,
//             ),
//             body: Center(child: AutoText('ERROR: ${snapshot.error}')),
//           );
//         } else if (!snapshot.hasData || snapshot.data == null) {
//           return Scaffold(
//             appBar: AppBar(
//               title: AutoText('HOME_2'),
//               centerTitle: true,
//             ),
//             body: Center(child: AutoText('ERROR_9')),
//           );
//         }

//         var userData = snapshot.data!;
//         String title = userData['position'] ?? 'HEALTH_PROFESSIONAL';
//         String name = userData['fullName'] ?? 'USER';
//         String profilePictureUrl = userData['midWifeImage'] ?? '';

//         // Extract user data for drawer
//         String userName = userData['fullName'] ?? '';
//         String email = userData['email'] ?? '';
//         String address = userData['address'] ?? '';
//         String cityValue = userData['city'] ?? '';
//         String stateValue = userData['state'] ?? '';
//         String villageTown = userData['villageTown'] ?? '';
//         String hospital = userData['hospital'] ?? '';

//         return Scaffold(
//           appBar: AppBar(
//             title: const AutoText('HOME_2'),
//             centerTitle: true,
//             actions: [
//               StreamBuilder<int>(
//                 stream: getUnreadNotificationCount(),
//                 builder: (context, snapshot) {
//                   int unreadCount = snapshot.data ?? 0;
//                   return Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.notifications_active),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const NotificationsPage(),
//                             ),
//                           );
//                         },
//                       ),
//                       if (unreadCount > 0)
//                         Positioned(
//                           right: 5,
//                           top: 5,
//                           child: Container(
//                             width: 13,
//                             height: 13,
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               )
//             ],
//           ),
//           drawer: HealthProviderHomeDrawer(
//             userName: userName,
//             email: email,
//             address: address,
//             cityValue: cityValue,
//             stateValue: stateValue,
//             villageTown: villageTown,
//             hospital: hospital,
//           ),
//           body: ListView(
//             children: [
//               FrontBanner(),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 50,
//                       width: 50,
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade100,
//                         borderRadius: BorderRadius.circular(30),
//                         image: profilePictureUrl.isNotEmpty
//                             ? DecorationImage(
//                                 image: NetworkImage(profilePictureUrl),
//                                 fit: BoxFit.cover,
//                               )
//                             : null,
//                       ),
//                       child: profilePictureUrl.isEmpty
//                           ? Icon(
//                               Icons.person,
//                               size: 40,
//                               color: Colors.grey.shade400,
//                             )
//                           : null,
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     AutoText(
//                       'HELLO',
//                       style: TextStyle(
//                           color: Colors.grey, fontWeight: FontWeight.w400),
//                     ),
//                     Text(
//                       '$title, $name.',
//                       style: TextStyle(
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 170,
//                       height: 220,
//                       decoration: BoxDecoration(
//                         color: Colors.blueAccent,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: HomeComponents(
//                         text: "PATIENTS",
//                         icon: 'assets/svgs/logo_Jambomama.svg',
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const Patients(),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Container(
//                       width: 170,
//                       height: 220,
//                       decoration: BoxDecoration(
//                         color: Colors.purple,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: HomeComponents(
//                         text: 'COLLEAGUES',
//                         icon: 'assets/svgs/file_directory.svg',
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ColleagueList(
//                                 location: 'Abuja',
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 170,
//                     height: 220,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'LEARN',
//                       icon: 'assets/svgs/learn_medicine.svg',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PractitionerContentScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Container(
//                     width: 170,
//                     height: 220,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade500,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'AVAILABILITY',
//                       icon: 'assets/svgs/person_account.svg',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => AvailabilitySchedulePage(),
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
