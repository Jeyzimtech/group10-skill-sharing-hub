import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'video_call_screen.dart';
import '../services/chat_service.dart';

class Session {
  final String tutorName;
  final String userName;
  final String skill;
  final String dateString;
  final String timeString;
  final bool isUpcoming;
  final String userId;
  final String tutorUid;
  final Timestamp? createdAt;

  Session({
    required this.tutorName,
    required this.userName,
    required this.skill,
    required this.dateString,
    required this.timeString,
    required this.isUpcoming,
    required this.userId,
    required this.tutorUid,
    this.createdAt,
  });

  factory Session.fromFirestore(Map<String, dynamic> data) {
    return Session(
      tutorName: data['tutorName'] ?? 'Unknown',
      userName: data['userName'] ?? 'Student',
      skill: data['skill'] ?? 'Unknown Skill',
      dateString: data['date'] ?? '',
      timeString: data['time'] ?? '',
      isUpcoming: data['status'] == 'upcoming',
      userId: data['userId'] ?? '',
      tutorUid: data['tutorUid'] ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}

class SessionsScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const SessionsScreen({super.key, this.onNavigateTab});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color _accent = const Color(0xFF00E5A0);


  // Data fetched via StreamBuilder

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text(
          'My Sessions',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: subTextColor,
          dividerColor: textColor.withValues(alpha: 0.1),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where(Filter.or(
              Filter('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid),
              Filter('tutorUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid),
            ))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5A0)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading sessions',
                style: TextStyle(color: subTextColor),
              ),
            );
          }

          final sessions = snapshot.data?.docs.map((doc) {
            return Session.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList() ?? [];

          sessions.sort((a, b) {
            final aTime = a.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          final upcomingSessions = sessions.where((s) => s.isUpcoming).toList();
          final pastSessions = sessions.where((s) => !s.isUpcoming).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSessionList(upcomingSessions, isUpcoming: true, isDark: isDark, textColor: textColor, subTextColor: subTextColor),
              _buildSessionList(pastSessions, isUpcoming: false, isDark: isDark, textColor: textColor, subTextColor: subTextColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionList(List<Session> sessions, {required bool isUpcoming, required bool isDark, required Color textColor, required Color subTextColor}) {
    if (sessions.isEmpty) {
      return _buildEmptyState(isUpcoming: isUpcoming, textColor: textColor, subTextColor: subTextColor);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildSessionCard(sessions[index], isDark, textColor, subTextColor);
      },
    );
  }

  Widget _buildSessionCard(Session session, bool isDark, Color textColor, Color subTextColor) {
    final statusColor = session.isUpcoming ? _accent : subTextColor;
    final statusBgColor = session.isUpcoming 
        ? _accent.withValues(alpha: 0.15) 
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100);
    
    final Color cardBg = isDark ? const Color(0xFF122240) : Colors.white;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isUserTutorInThisSession = session.tutorUid == currentUid;
    final displayName = isUserTutorInThisSession ? session.userName : session.tutorName;
    final roleLabel = isUserTutorInThisSession ? 'Student' : 'Tutor';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      ),
                      child: Icon(
                        isUserTutorInThisSession ? Icons.school : Icons.person,
                        color: textColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$roleLabel • ${session.skill}',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  session.isUpcoming ? 'Upcoming' : 'Completed',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: textColor.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: subTextColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatSessionDateTime(session.dateString, session.timeString),
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(width: 8),
              const SizedBox(width: 8),
              if (session.isUpcoming)
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      final otherUid = session.tutorUid == currentUid ? session.userId : session.tutorUid;
                      final otherName = session.tutorUid == currentUid ? session.userName : session.tutorName;
                      
                      final List<String> ids = [currentUid!, otherUid]..sort();
                      final String channelName = ids.join('_');
                      
                      // Notify the other user via chat
                      ChatService.sendMessage(otherUid, "🎥 I've started the video session for '${session.skill}'. Join me!");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCallScreen(
                            channelName: channelName,
                            userName: otherName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.videocam_outlined, size: 14),
                    label: const Text('Start Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: const Color(0xFF0B1E3A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final currentUid = FirebaseAuth.instance.currentUser?.uid;
                    final otherUid = session.tutorUid == currentUid ? session.userId : session.tutorUid;
                    final otherName = session.tutorUid == currentUid ? session.userName : session.tutorName;
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          otherUserId: otherUid,
                          otherUserName: otherName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 14),
                  label: const Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: BorderSide(color: _accent.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSessionDateTime(String dateString, String timeString) {
    try {
      final date = DateTime.parse(dateString);
      final formattedDate = DateFormat('MMM dd, yyyy').format(date);
      return '$formattedDate • $timeString';
    } catch (e) {
      return '$dateString • $timeString';
    }
  }

  Widget _buildEmptyState({required bool isUpcoming, required Color textColor, required Color subTextColor}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor.withValues(alpha: 0.03),
              ),
              child: Icon(
                isUpcoming ? Icons.event_busy : Icons.history,
                size: 64,
                color: textColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming ? 'No upcoming sessions' : 'No past sessions',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (isUpcoming)
              Text(
                'You don\'t have any sessions booked. Find a tutor to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 32),
            if (isUpcoming)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.onNavigateTab != null) {
                    widget.onNavigateTab!(1); // Navigate to Skills (Find Tutor) tab
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: const Color(0xFF0B1E3A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: _accent.withValues(alpha: 0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Find Tutor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
