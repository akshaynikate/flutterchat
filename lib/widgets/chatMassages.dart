import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/widgets/messageBubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            heightFactor: 150,
            widthFactor: 150,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('no messages...'),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        } else {
          final loadedMessages = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            child: ListView.builder(
                reverse: true,
                itemCount: loadedMessages.length,
                itemBuilder: (context, index) {
                  final chatmessage = loadedMessages[index].data();
                  final nextChatmessage = index + 1 < loadedMessages.length
                      ? loadedMessages[index + 1].data()
                      : null;
                  final currentUserId = chatmessage['userId'];
                  final nextMessageUserId = nextChatmessage != null
                      ? nextChatmessage['userId']
                      : null;
                  final nextUserIsSame = nextMessageUserId == currentUserId;
                  if (nextUserIsSame) {
                    return MessageBubble.next(
                      message: chatmessage['text'],
                      isMe: authenticatedUser.uid == currentUserId,
                    );
                  } else {
                    return MessageBubble.first(
                      userImage: chatmessage['userImage'],
                      username: chatmessage['userName'],
                      message: chatmessage['text'],
                      isMe: authenticatedUser.uid == currentUserId,
                    );
                  }
                }),
          );
        }
      },
    );
  }
}
