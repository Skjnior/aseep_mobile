import 'package:aseep/components/myAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final _firestore = FirebaseFirestore.instance;

class AllChat extends StatefulWidget {

  @override
  _AllChatState createState() => _AllChatState();
}

class _AllChatState extends State<AllChat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? messageText;
  @override
  void initState() {
    super.initState();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: MyAppBar(
        text: 'EPI',
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  /*Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Theme.of(context).colorScheme.secondary,
              size: 35,
            ),
          );
        }

        final messages = snapshot.data?.docs ?? [];
        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          reverse: false,
          itemBuilder: (context, index) {
            final message = messages[index];
            final data = message.data() as Map<String, dynamic>;
            return MessageBubble(
              sender: data['sender'] ?? 'Inconnu',
              text: data['text'] ?? '',
              isMe: data['sender'] == _auth.currentUser?.email,
            );
          },
        );
      },
    );
  }*/
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Theme.of(context).colorScheme.secondary,
              size: 35,
            ),
          );
        }

        final messages = snapshot.data?.docs ?? [];

        // Attendre la construction complète avant de scroller
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());

        return  ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          reverse: false,
          itemBuilder: (context, index) {
            final message = messages[index];
            final data = message.data() as Map<String, dynamic>;
            return MessageBubble(
              sender: data['sender'] ?? 'Inconnu',
              text: data['text'] ?? '',
              isMe: data['sender'] == _auth.currentUser?.email,
              timestamp: data['timestamp'] as Timestamp?,
            );
          },
        );

        /*ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          reverse: false,
          itemBuilder: (context, index) {
            final message = messages[index];
            final data = message.data() as Map<String, dynamic>;
            return MessageBubble(
              sender: data['sender'] ?? 'Inconnu',
              text: data['text'] ?? '',
              isMe: data['sender'] == _auth.currentUser?.email,
            );
          },
        )*/;
      },
    );
  }


  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageTextController,
              onChanged: (value) {
                messageText = value;
              },
              decoration: InputDecoration(
                hintText: "Votre message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          /*IconButton(
            onPressed: () {
              if (messageText != null && messageText!.trim().isNotEmpty) {
                _firestore.collection('messages').add({
                  'text': messageText,
                  'sender': _auth.currentUser?.email ?? 'Inconnu',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                messageTextController.clear();
                scrollDown();
              }
            },
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),*/
          IconButton(
            onPressed: () {
              if (messageText != null && messageText!.trim().isNotEmpty) {
                _firestore.collection('messages').add({
                  'text': messageText,
                  'sender': _auth.currentUser?.email ?? 'Inconnu',
                  'timestamp': FieldValue.serverTimestamp(), // Enregistre le timestamp
                });
                messageTextController.clear();
                scrollDown();
              }
            },
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final Timestamp? timestamp;

  const MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = '';
    if (timestamp != null) {
      DateTime dateTime = timestamp!.toDate();
      formattedTime = DateFormat('HH:mm').format(dateTime);
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(25),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(25),
            ),
            elevation: 5.0,
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

