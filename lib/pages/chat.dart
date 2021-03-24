import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat/models/chat_model.dart';
import 'package:flutter_chat/models/conversation_model.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/services/chat_service.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;

  Chat({this.user, this.currentUser});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.user.image),
              radius: 15,
            ),
            SizedBox(width: 10),
            Text(widget.user.name),
          ],
        ),
        leadingWidth: 30,
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: ChatService(
                  userId: widget.user.id, currentUserId: widget.currentUser.id)
              .getChat(),
          builder: (context, snapshot) {
            // Check for errors
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            // Show app
            if (snapshot.connectionState == ConnectionState.done) {
              return MultiProvider(
                providers: [
                  StreamProvider<List<ConversationModel>>.value(
                    value: ChatService(chatId: snapshot.data).conversations,
                    initialData: [],
                  ),
                  StreamProvider<ChatModel>.value(
                    value: ChatService(chatId: snapshot.data).chat,
                    initialData: null,
                  ),
                ],
                child: _ChatList(
                  user: widget.user,
                  currentUser: widget.currentUser,
                ),
              );
            }

            // Show loading
            return Center(
              child: Container(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatList extends StatefulWidget {
  final UserModel user;
  final UserModel currentUser;

  _ChatList({this.user, this.currentUser});

  @override
  __ChatListState createState() => __ChatListState();
}

class __ChatListState extends State<_ChatList> {
  final TextEditingController chatController = new TextEditingController();

  Timer _typingTimer;

  @override
  Widget build(BuildContext context) {
    final List<ConversationModel> _conversations =
        context.watch<List<ConversationModel>>();

    final ChatModel _chat = context.watch<ChatModel>();

    if (_conversations == null || _chat == null) {
      return Center(child: CircularProgressIndicator());
    }

    final ChatService _chatService = ChatService(chatId: _chat.id);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: _conversations.length,
            reverse: true,
            itemBuilder: (context, index) => _Chat(
              conversation: _conversations[index],
              user: widget.user,
              currentUser: widget.currentUser,
            ),
          ),
        ),
        if (_chat.status[widget.user.id] == 'typing') ...[
          _ChatTyping(user: widget.user)
        ],
        Padding(
          padding: EdgeInsets.all(10),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Write something...',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  if (chatController.text != '') {
                    dynamic result = await _chatService.addChat(
                        widget.currentUser.id,
                        chatController.text,
                        widget.user.id);

                    if (result != null) {
                      chatController.text = '';
                    }
                  }
                },
              ),
            ),
            maxLines: null,
            controller: chatController,
            onChanged: (value) {
              const duration = Duration(milliseconds: 2000);

              if (_typingTimer != null) {
                _typingTimer.cancel();
              }

              if (_chat.status[widget.currentUser.id] != 'typing') {
                _chatService.updateTypingStatus(widget.currentUser.id);
              }

              _typingTimer = Timer(duration,
                  () => _chatService.updateIdleStatus(widget.currentUser.id));
            },
          ),
        ),
      ],
    );
  }
}

class _Chat extends StatelessWidget {
  final ConversationModel conversation;
  final UserModel user;
  final UserModel currentUser;

  _Chat({this.conversation, this.user, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final ChatModel _chat = context.watch<ChatModel>();

    // check if the chat belongs to the current user
    if (currentUser.id == conversation.author) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                conversation.message,
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: AssetImage(currentUser.image),
              radius: 15,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(user.image),
            radius: 15,
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              conversation.message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTyping extends StatelessWidget {
  final UserModel user;

  _ChatTyping({this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(user.image),
            radius: 15,
          ),
          SizedBox(width: 10),
          Text('typing...')
        ],
      ),
    );
  }
}
