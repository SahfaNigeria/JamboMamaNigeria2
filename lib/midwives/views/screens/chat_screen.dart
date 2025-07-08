import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jambomama_nigeria/controllers/recieve_messages.dart';
import 'package:jambomama_nigeria/controllers/send_message.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String senderCollection;
  final String senderNameField;
  final String receiverCollection;
  final String receiverNameField;

  ChatScreen({
    required this.chatId,
    required this.senderCollection,
    required this.senderNameField,
    required this.receiverCollection,
    required this.receiverNameField,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: getMessagesStream(chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId ==
                        FirebaseAuth.instance.currentUser!.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color:
                              isMe ? Colors.red.shade100 : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft:
                                isMe ? Radius.circular(12) : Radius.circular(0),
                            bottomRight:
                                isMe ? Radius.circular(0) : Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('hh:mm a').format(message.timestamp),
                              style: TextStyle(
                                  fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(chatId: chatId),
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final String chatId;

  MessageInput({required this.chatId});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  sendMessage(widget.chatId, _controller.text.trim());
                  _controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/controllers/get_user_name.dart';
// import 'package:jambomama_nigeria/controllers/recieve_messages.dart';
// import 'package:jambomama_nigeria/controllers/send_message.dart';
// import 'package:intl/intl.dart';

// class ChatScreen extends StatelessWidget {
//   final String chatId;
//   final String senderCollection;
//   final String senderNameField;
//   final String receiverCollection;
//   final String receiverNameField;

//   ChatScreen({
//     required this.chatId,
//     required this.senderCollection,
//     required this.senderNameField,
//     required this.receiverCollection,
//     required this.receiverNameField,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Message>>(
//               stream: getMessagesStream(chatId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No messages'));
//                 }

//                 final messages = snapshot.data!;
//                 return ListView.builder(
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isSenderHealthProvider =
//                         determineSender(message.senderId);

//                     return FutureBuilder<String>(
//                       future: getUserName(
//                         message.senderId,
//                         isSenderHealthProvider
//                             ? senderCollection
//                             : receiverCollection,
//                         isSenderHealthProvider
//                             ? senderNameField
//                             : receiverNameField,
//                       ),
//                       builder: (context, userSnapshot) {
//                         if (userSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return ListTile(
//                             title: Text(message.text),
//                             subtitle: Text('Sent by: Loading...'),
//                             trailing: Text(
//                               DateFormat('hh:mm a').format(message.timestamp),
//                             ),
//                           );
//                         }
//                         if (userSnapshot.hasError || !userSnapshot.hasData) {
//                           return ListTile(
//                             title: Text(message.text),
//                             subtitle:
//                                 Text('Sent by: Name could not be fetched'),
//                             trailing: Text(
//                               DateFormat('hh:mm a').format(message.timestamp),
//                             ),
//                           );
//                         }

//                         final userName = userSnapshot.data!;
//                         return ListTile(
//                           title: Text(message.text),
//                           subtitle: Text('Sent by: $userName'),
//                           trailing: Text(
//                             DateFormat('hh:mm a').format(message.timestamp),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           MessageInput(chatId: chatId),
//         ],
//       ),
//     );
//   }

//   // Helper function to determine if the sender is a health provider
//   bool determineSender(String senderId) {
//     // Implement logic to determine if the senderId belongs to a health provider
//     // For example, you might check the senderId against a known list of health provider IDs
//     return true; // Or false, based on your logic
//   }
// }

// class MessageInput extends StatefulWidget {
//   final String chatId;

//   MessageInput({required this.chatId});

//   @override
//   _MessageInputState createState() => _MessageInputState();
// }

// class _MessageInputState extends State<MessageInput> {
//   final _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 hintText: 'Enter message',
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: () {
//               if (_controller.text.isNotEmpty) {
//                 sendMessage(widget.chatId, _controller.text);
//                 _controller.clear();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
