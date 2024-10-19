import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:panchayat/components/my_textfield.dart';
import 'package:panchayat/services/auth/auth_service.dart';
import 'package:panchayat/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messageController = TextEditingController();

  //chat and auth services
  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  //send message
  void sendMessage() async {
    //if there is something in the textfield
    if (_messageController.text.isNotEmpty) {
      //send message
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text); //CHECK

      //clear textfield
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(widget.receiverEmail),
        centerTitle: true,
      ),
      body: Column(
        children: [
          //display messages(majority)
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        //return list view
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderId'] == _authService.getCurrentUser()!.uid;

    //align to the right if sender is the current user, else left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // return Row(
    //   mainAxisAlignment:
    //       isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
    //   children: [
    //     Container(
    //       margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
    //       padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    //       decoration: BoxDecoration(
    //         color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
    //         borderRadius: BorderRadius.circular(12.0),
    //       ),
    //       child: Text(
    //         data["message"],
    //         style: TextStyle(
    //           fontSize: 14.0,
    //           color: isCurrentUser
    //               ? Colors.black
    //               : const Color.fromARGB(221, 238, 4, 4),
    //         ),
    //       ),
    //     ),
    //   ],
    // );

    return Container(
      alignment: alignment,
      child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(data['message']),
          ]),
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        //textfield should take up most of the space
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15.0),
            child: MyTextField(
              controller: _messageController,
              hintText: "Type a message....",
              //obscureText: false,
            ),
          ),
        ),

        //send button
        Container(
          margin: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.arrow_upward),
          ),
        ),
      ],
    );
  }
}
