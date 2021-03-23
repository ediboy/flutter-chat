import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/models/user_model.dart';

class UserService {
  final String id;
  final String email;

  UserService({this.id, this.email});

  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // map user list from snapshot
  List<UserModel> _mapUsers(QuerySnapshot snapshot) {
    return snapshot.docs.map((snap) => UserModel.fromFirestore(snap)).toList();
  }

  // stream users
  Stream<List<UserModel>> get users {
    return userCollection
        .where('email', isNotEqualTo: email)
        .snapshots()
        .map(_mapUsers);
  }

  // stream user
  Stream<UserModel> get user {
    return userCollection
        .doc(id)
        .snapshots()
        .map((snap) => UserModel.fromFirestore(snap));
  }
}
