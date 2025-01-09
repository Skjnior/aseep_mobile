import 'dart:math';
import 'package:aseep/components/chat_bublle.dart';
import 'package:aseep/screens/profile_screen.dart';
import 'package:aseep/services/auth/auth_services.dart';
import 'package:aseep/services/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  final String receiverFirstName;
  final String receiverLastName;
  final String receiverEmail;
  final String receiverID;

  ChatScreen({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.receiverFirstName,
    required this.receiverLastName,
    required receiverImagePath,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Generate a random image URL
  static final Random random = Random();
  String get randomPictureUrl {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/seed/$randomInt/300/300';
  }

  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat & auth services
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();

  // For textField focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => scrollDown(),
        );
      }
    });
    Future.delayed(
      const Duration(milliseconds: 500),
          () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, _messageController.text);
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        elevation: 0,
        foregroundColor: Colors.grey,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            CupertinoIcons.back,
            size: 30,
          ),
        ),
        title: Column(
          children: [
            Text(
              "${widget.receiverFirstName} ${widget.receiverLastName}",
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 16,
              ),
            ),
            Text(
              widget.receiverEmail,
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.to(
                  () => ProfileScreen(
                userEmail: widget.receiverEmail,
                userId: widget.receiverID,
                userFirstName: widget.receiverFirstName,
                userLastName: widget.receiverLastName,
                userImagePath: randomPictureUrl,
                userBirthDate: '',
                userMatricule: '',
                userNiveaux: [],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(randomPictureUrl),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Theme.of(context).colorScheme.secondary,
              size: 35,
            ),
          );
        }
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBublle(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data["senderID"],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              focusNode: myFocusNode,
              controller: _messageController,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Theme.of(context).colorScheme.secondary,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                filled: true,
                hintText: "Votre message",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 25),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }
}
