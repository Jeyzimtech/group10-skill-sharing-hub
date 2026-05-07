import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessage {
  final String senderId;
  final String text;
  final Timestamp timestamp;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class ChatService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String getChatId(String otherUserId) {
    final currentUserId = _auth.currentUser!.uid;
    final List<String> ids = [currentUserId, otherUserId]..sort();
    return ids.join('_');
  }

  static Future<void> sendMessage(String otherUserId, String text) async {
    final currentUserId = _auth.currentUser!.uid;
    final chatId = getChatId(otherUserId);

    final messageData = {
      'senderId': currentUserId,
      'receiverId': otherUserId,
      'text': text,
      'type': text.contains("📞") ? "call" : "text",
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageType': text.contains("📞") ? "call" : "text",
      'lastTimestamp': FieldValue.serverTimestamp(),
      'users': [currentUserId, otherUserId],
    }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot> getMessages(String otherUserId) {
    final chatId = getChatId(otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getConversations() {
    final currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }
}
