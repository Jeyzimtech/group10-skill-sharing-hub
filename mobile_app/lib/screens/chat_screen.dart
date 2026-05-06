import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart';
import 'video_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color _accent = const Color(0xFF00E5A0);

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();
    await ChatService.sendMessage(widget.otherUserId, text);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              child: Text(
                widget.otherUserName.isNotEmpty ? widget.otherUserName[0] : 'U',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Color(0xFF00E5A0)),
            onPressed: () {
              // Create a unique channel name based on user IDs
              final String myId = FirebaseAuth.instance.currentUser?.uid ?? '';
              final List<String> ids = [myId, widget.otherUserId]..sort();
              final String channelName = ids.join('_');
              
              // Notify the other user via chat
              ChatService.sendMessage(widget.otherUserId, "📞 Initiating video call... Join me!");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    channelName: channelName,
                    userName: widget.otherUserName,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ChatService.getMessages(widget.otherUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5A0)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Start a conversation', style: TextStyle(color: subTextColor)),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                    return _buildMessageBubble(data['text'], isMe, data['timestamp'], isDark, textColor, subTextColor, bgColor);
                  },
                );
              },
            ),
          ),
          _buildInputArea(isDark, textColor, subTextColor, bgColor),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, dynamic timestamp, bool isDark, Color textColor, Color subTextColor, Color bg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? _accent : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isMe ? const Color(0xFF0B1E3A) : textColor,
                  fontSize: 15,
                ),
              ),
              if (!isMe && text.contains("video call"))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final String myId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final List<String> ids = [myId, widget.otherUserId]..sort();
                      final String channelName = ids.join('_');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCallScreen(
                            channelName: channelName,
                            userName: widget.otherUserName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.videocam, size: 16),
                    label: const Text("JOIN CALL", style: TextStyle(letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: const Color(0xFF0B1E3A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                timestamp != null 
                  ? DateFormat('HH:mm').format((timestamp as Timestamp).toDate())
                  : '',
                style: TextStyle(
                  color: (isMe ? const Color(0xFF0B1E3A) : textColor).withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark, Color textColor, Color subTextColor, Color bg) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: textColor.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: subTextColor),
                filled: true,
                fillColor: isDark ? const Color(0xFF122240) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Color(0xFF0B1E3A), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
