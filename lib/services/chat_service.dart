import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/models/chat_model.dart';

class ChatService {
  final String userId;
  final String authId;

  ChatService({this.userId, this.authId});

  // collection reference
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  // map chat list
  List<ChatModel> _mapChats(QuerySnapshot snapshot) {
    return snapshot.docs.map((snap) => ChatModel.fromFirestore(snap)).toList();
  }

  // stream chats
  Stream<List<ChatModel>> get chats {
    return chatCollection
        .where('users.$userId', isEqualTo: true)
        .where('users.$authId', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map(_mapChats);
  }

  // add chat
  Future addChat(String authorId, String message, String userId) async {
    try {
      return await chatCollection.add({
        'author_id': authorId,
        'message': message,
        'users': {
          authorId: true,
          userId: true,
        },
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
