import 'package:aseep/components/chat_bublle.dart';
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
  final String receiverImagePath;
  final String receiverEmail;
  final String receiverID;

   ChatScreen({super.key, required this.receiverEmail, required this.receiverID, required this.receiverFirstName, required this.receiverLastName, required this.receiverImagePath});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final MyServices _chatService = MyServices();
  final AuthService _authService = AuthService();

  // for textField focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // add listener to focus node
    myFocusNode.addListener(() {
      if(myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        // then the amount of remaining space will be calculated
        // then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
            () => scrollDown(),
        );
      }
    });

    // wait a bit for listview to be built, then scroll to bottom
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

  /// scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
    );
  }



  // send message
  void sendMessage() async {
    // if there is something inside the textField
    if(_messageController.text.isNotEmpty) {
      // send the message
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
        elevation: 0,
        foregroundColor: Colors.grey,
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              CupertinoIcons.back,
              size: 30,
            )
        ),
        title: Column(
          children: [
            Text(
                widget.receiverFirstName + " " + widget.receiverLastName,
              style: const TextStyle(
                fontSize: 18
              ),
            ),
            Text(
                widget.receiverEmail,
              style: const TextStyle(
                  fontSize: 10
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.receiverImagePath.isNotEmpty
                    ? NetworkImage(widget.receiverImagePath)
                    : const AssetImage('assets/images/ourLogo.jpg') as ImageProvider,
              ),
            ),
          ),

        ],
      ),

      body: Column(
        children: [
          // display all nessages
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(context ),
        ],
      ),
    );
  }

  // build message list
Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(senderID, widget.receiverID),
        builder: (context, snapshot) {
          // error
          if (snapshot.hasError) {
            return const Text("Error");
          }

          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: Color(0xff2983A6),
                  size: 35
              ),
            );
          }

          // return List view
          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          );
        }
  );
}

Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // align messsage to the right if sender is the current user, otherwise left
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;


    return Container(
      alignment: alignment,
        child: Column(
          crossAxisAlignment: isCurrentUser ?  CrossAxisAlignment.end : CrossAxisAlignment.start,
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

// build message input
Widget _buildUserInput(BuildContext context) {
    return Row(
      children: [
        // textField should take up most of the space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              focusNode: myFocusNode,
              obscureText: false,
              controller: _messageController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
                     borderRadius: BorderRadius.circular(20)
                  ),
                  fillColor: Theme.of(context).colorScheme.secondary,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  filled: true,
                  hintText: "Votre message",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),

        // sender Button
        Container(
          margin: const EdgeInsets.only(right: 25),
          child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                  Icons.send
              )
          ),
        ),
      ],
    );
}
}
