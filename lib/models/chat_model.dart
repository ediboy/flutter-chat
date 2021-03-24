import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final Map users;
  final Map status;

  ChatModel({this.id, this.users, this.status});

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ChatModel(
      id: doc.id,
      users: data['users'] ?? {},
      status: data['status'] ?? {},
    );
  }
}
