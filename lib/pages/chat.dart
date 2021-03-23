import 'package:flutter/material.dart';
import 'package:flutter_chat/models/chat_model.dart';
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
        leading: Row(
          children: [
            SizedBox(width: 10),
            BackButton(),
            CircleAvatar(
              backgroundImage: AssetImage(widget.user.image),
              radius: 15,
            ),
            SizedBox(width: 10),
            Text(widget.user.name),
          ],
        ),
        leadingWidth: double.infinity,
      ),
      body: SafeArea(
        child: MultiProvider(
          providers: [
            StreamProvider<List<ChatModel>>.value(
              value: ChatService(
                      userId: widget.user.id, authId: widget.currentUser.id)
                  .chats,
              initialData: [],
            ),
          ],
          child: _ChatList(
            user: widget.user,
            currentUser: widget.currentUser,
          ),
        ),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;

  _ChatList({this.user, this.currentUser});

  final TextEditingController chatController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<ChatModel> _chats = context.watch<List<ChatModel>>();

    if (_chats == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: _chats.length,
            reverse: true,
            itemBuilder: (context, index) => _Chat(
              chat: _chats[index],
              user: user,
              currentUser: currentUser,
            ),
          ),
        ),
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
                      dynamic result = await ChatService().addChat(
                          currentUser.id, chatController.text, user.id);

                      if (result != null) {
                        chatController.text = '';
                      }
                    }
                  }),
            ),
            maxLines: null,
            controller: chatController,
          ),
        ),
      ],
    );
  }
}

class _Chat extends StatelessWidget {
  final ChatModel chat;
  final UserModel user;
  final UserModel currentUser;

  _Chat({this.chat, this.user, this.currentUser});

  @override
  Widget build(BuildContext context) {
    // check if the chat belongs to the current user
    if (currentUser.id == chat.author) {
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
                chat.message,
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
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              chat.message,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            backgroundImage: AssetImage(user.image),
            radius: 15,
          ),
        ],
      ),
    );
  }
}
