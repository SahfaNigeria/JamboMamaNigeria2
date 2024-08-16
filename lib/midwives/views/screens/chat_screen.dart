import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/recieve_messages.dart';
import 'package:jambomama_nigeria/controllers/send_message.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  ChatScreen({required this.chatId});

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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.text),
                      subtitle: Text('Sent by: ${message.senderId}'),
                      trailing: Text(
                        DateFormat('hh:mm a').format(message.timestamp),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter message',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                sendMessage(widget.chatId, _controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
