import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Session {
  final String tutorName;
  final String skill;
  final String dateString;
  final String timeString;
  final bool isUpcoming;
  final Timestamp? createdAt;

  Session({
    required this.tutorName,
    required this.skill,
    required this.dateString,
    required this.timeString,
    required this.isUpcoming,
    this.createdAt,
  });

  factory Session.fromFirestore(Map<String, dynamic> data) {
    return Session(
      tutorName: data['tutorName'] ?? 'Unknown',
      skill: data['skill'] ?? 'Unknown Skill',
      dateString: data['date'] ?? '',
      timeString: data['time'] ?? '',
      isUpcoming: data['status'] == 'upcoming',
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

  final Color _bg = const Color(0xFF0B1E3A);
  final Color _accent = const Color(0xFF00E5A0);
  final Color _cardBg = const Color(0xFF122240);

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

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'My Sessions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
          dividerColor: Colors.white.withValues(alpha: 0.1),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading sessions',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
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
              _buildSessionList(upcomingSessions, isUpcoming: true),
              _buildSessionList(pastSessions, isUpcoming: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSessionList(List<Session> sessions, {required bool isUpcoming}) {
    if (sessions.isEmpty) {
      return _buildEmptyState(isUpcoming: isUpcoming);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildSessionCard(sessions[index]);
      },
    );
  }

  Widget _buildSessionCard(Session session) {
    final statusColor = session.isUpcoming ? _accent : Colors.white.withValues(alpha: 0.5);
    final statusBgColor = session.isUpcoming 
        ? _accent.withValues(alpha: 0.15) 
        : Colors.white.withValues(alpha: 0.05);
    
    final dateFormat = DateFormat('MMM dd, yyyy • h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.tutorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.skill,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
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
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                _formatSessionDateTime(session.dateString, session.timeString),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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

  Widget _buildEmptyState({required bool isUpcoming}) {
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
                color: Colors.white.withValues(alpha: 0.03),
              ),
              child: Icon(
                isUpcoming ? Icons.event_busy : Icons.history,
                size: 64,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming ? 'No upcoming sessions' : 'No past sessions',
              style: const TextStyle(
                color: Colors.white,
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
                  color: Colors.white.withValues(alpha: 0.6),
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
                  foregroundColor: _bg,
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
