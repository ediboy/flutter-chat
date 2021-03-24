import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/models/chat_model.dart';
import 'package:flutter_chat/models/conversation_model.dart';

class ChatService {
  final String chatId;
  final String userId;
  final String currentUserId;

  ChatService({this.chatId, this.userId, this.currentUserId});

  // collection reference
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  // map conversation list
  List<ConversationModel> _mapConversations(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((snap) => ConversationModel.fromFirestore(snap))
        .toList();
  }

  // stream conversations
  Stream<List<ConversationModel>> get conversations {
    return chatCollection
        .doc(chatId)
        .collection('conversations')
        .orderBy('date', descending: true)
        .snapshots()
        .map(_mapConversations);
  }

  // stream chat
  Stream<ChatModel> get chat {
    return chatCollection
        .doc(chatId)
        .snapshots()
        .map((snap) => ChatModel.fromFirestore(snap));
  }

  // get chat
  Future<String> getChat() async {
    try {
      // check if chat between users is already exist
      QuerySnapshot chats = await chatCollection
          .where('users.$userId', isEqualTo: true)
          .where('users.$currentUserId', isEqualTo: true)
          .limit(1)
          .get();

      // if empty check one
      if (chats.docs.isEmpty) {
        return await chatCollection.add({
          'users': {
            currentUserId: true,
            userId: true,
          }
        }).then((chat) => chat.id);
      }

      // if not empty return the chat id
      return chats.docs[0].id;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // add chat
  Future addChat(String authorId, String message, String userId) async {
    try {
      return await chatCollection.doc(chatId).collection('conversations').add({
        'author_id': authorId,
        'message': message,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // update status to typing
  Future updateTypingStatus(String id) async {
    try {
      return await chatCollection.doc(chatId).update({'status.$id': 'typing'});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // update status to idle
  Future updateIdleStatus(String id) async {
    try {
      return await chatCollection.doc(chatId).update({'status.$id': 'idle'});
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
