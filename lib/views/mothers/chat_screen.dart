// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   final String otherUserId;

//   ChatScreen({required this.otherUserId});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final ChatService _chatService = ChatService(FirebaseFirestore.instance);
//   final TextEditingController _messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.otherUserId}'),
//       ),
//       body: Column(
//         children: [
//           StreamBuilder(
//             stream: _chatService.getChatConversations(
//               currentUserId: FirebaseAuth.instance.currentUser!.uid,
//               otherUserId: widget.otherUserId,
//             ),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }

//               return ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(snapshot.data![index].messageText),
//                   );
//                 },
//               );
//             },
//           ),
//           TextField(
//             controller: _messageController,
//             decoration: InputDecoration(
//               hintText: 'Type a message',
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await _chatService.sendMessage(
//                 senderId: FirebaseAuth.instance.currentUser!.uid,
//                 recipientId: widget.otherUserId,
//                 messageText: _messageController.text,
//               );
//               _messageController.clear();
//             },
//             child: Text('Send'),
//           ),
//         ],
//       ),
//     );
//   }
// }
