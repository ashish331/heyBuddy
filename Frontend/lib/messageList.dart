import 'package:flutter/material.dart';
import 'package:hybuddy/mesage.dart';
import 'package:provider12/provider.dart';

import 'state/chatstate.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;

  const MessageList({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatState>().messages;
    return ListView.builder(
      reverse: true, // Show newest messages first
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: !message.isUser ? Colors.blue : Colors.grey[300],
        borderRadius: message.isUser
            ? BorderRadius.only(
                topLeft: Radius.circular(40),
                bottomLeft: Radius.circular(40),
                topRight: Radius.circular(40))
            : BorderRadius.only(
                topLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
                topRight: Radius.circular(40)),
      ),
      padding: EdgeInsets.all(16),
      child: Text(message.text),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
    );
  }
}
