import 'package:flutter/material.dart';
import 'package:flutter_chat/models/auth_model.dart';
import 'package:flutter_chat/models/user_model.dart';
import 'package:flutter_chat/pages/people.dart';
import 'package:flutter_chat/pages/choose_character.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'package:flutter_chat/services/user_service.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<AuthModel>.value(
          initialData: null,
          value: AuthService().user,
        ),
      ],
      child: _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authUser = context.watch<AuthModel>();

    bool loggedIn = _authUser != null;

    if (!loggedIn) {
      return ChooseCharacter();
    }

    return StreamProvider<UserModel>.value(
        initialData: null,
        value: UserService(id: _authUser.uid).user,
        child: People());
  }
}
