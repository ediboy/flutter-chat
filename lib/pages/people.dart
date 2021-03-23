import 'package:flutter/material.dart';
import 'package:flutter_chat/models/auth_model.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/pages/chat.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/user_service.dart';
import 'package:provider/provider.dart';

class People extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = context.watch<AuthModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () async => AuthService().signOut()),
      ),
      body: SafeArea(
        child: StreamProvider<List<UserModel>>.value(
          value: UserService(email: _user.email).users,
          initialData: [],
          child: _UserList(),
        ),
      ),
    );
  }
}

class _UserList extends StatefulWidget {
  @override
  __UserListState createState() => __UserListState();
}

class __UserListState extends State<_UserList> {
  @override
  Widget build(BuildContext context) {
    final List<UserModel> _users = context.watch<List<UserModel>>();
    final UserModel _currentUser = context.watch<UserModel>();

    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[400],
      ),
      itemCount: _users.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_users[index].name),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(_users[index].image),
            ),
            if (_users[index].online) ...[
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
        tileColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        selectedTileColor: Colors.grey[200],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              user: _users[index],
              currentUser: _currentUser,
            ),
          ),
        ),
      ),
    );
  }
}
