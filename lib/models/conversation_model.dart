import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String author;
  final String message;

  ConversationModel({this.id, this.author, this.message});

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return ConversationModel(
      id: doc.id,
      author: data['author_id'] ?? '',
      message: data['message'] ?? '',
    );
  }
}
