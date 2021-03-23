import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String author;
  final String message;

  ChatModel({this.id, this.author, this.message});

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ChatModel(
      id: doc.id,
      author: data['author_id'] ?? '',
      message: data['message'] ?? '',
    );
  }
}
