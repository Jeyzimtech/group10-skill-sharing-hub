import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ChatService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5A0)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message_outlined, size: 64, color: textColor.withValues(alpha: 0.1)),
                    const SizedBox(height: 16),
                    Text(
                      'No conversations yet.\nBook a tutor to start chatting!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subTextColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: textColor.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final users = List<String>.from(data['users'] ?? []);
              final otherUserId = users.firstWhere((id) => id != currentUserId, orElse: () => '');
              
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnap) {
                  final userName = userSnap.hasData && userSnap.data!.exists 
                      ? (userSnap.data!.data() as Map<String, dynamic>)['name'] ?? 'User' 
                      : 'User';
                  
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: otherUserId,
                            otherUserName: userName,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                      child: Text(
                        userName.isNotEmpty ? userName[0] : 'U', 
                        style: TextStyle(color: textColor)
                      ),
                    ),
                    title: Text(
                      userName,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['lastMessage'] ?? '',
                      style: TextStyle(color: subTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      data['lastTimestamp'] != null 
                        ? _formatTime((data['lastTimestamp'] as Timestamp).toDate())
                        : '',
                      style: TextStyle(color: subTextColor.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
