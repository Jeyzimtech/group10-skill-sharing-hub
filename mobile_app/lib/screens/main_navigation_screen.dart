import 'package:flutter/material.dart';
import 'dart:async';
import 'home_dashboard_screen.dart';
import 'skill_listing_screen.dart';
import 'sessions_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'chat_screen.dart';
import 'ai_tutor_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'video_call_screen.dart';
import '../utils/responsive.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late final List<Widget> _screens;
  StreamSubscription<QuerySnapshot>? _messageSubscription;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      HomeDashboardScreen(onNavigateTab: _onTabTapped),
      const SkillListingScreen(),
      const MessagesScreen(),
      SessionsScreen(onNavigateTab: _onTabTapped),
      const ProfileScreen(),
    ];
    _initMessageListener();
  }

  void _initMessageListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _messageSubscription = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              
              if (timestamp != null && timestamp.toDate().isAfter(_startTime)) {
                final type = data['type'] ?? 'text';
                if (type == 'call') {
                  _showIncomingCallDialog(data);
                } else {
                  _showNewMessageNotification(data);
                }
              }
            }
          }
        });
  }

  void _showIncomingCallDialog(Map<String, dynamic> data) async {
    final senderId = data['senderId'] as String;
    final senderDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();
    final senderName = senderDoc.exists ? (senderDoc.data()?['name'] ?? 'Someone') : 'Someone';

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF122240),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5A0).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam, color: Color(0xFF00E5A0), size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'INCOMING VIDEO CALL',
              style: TextStyle(
                color: const Color(0xFF00E5A0),
                letterSpacing: 2,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              senderName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallAction(
                  icon: Icons.close,
                  color: Colors.redAccent,
                  label: 'Decline',
                  onTap: () => Navigator.pop(context),
                ),
                _buildCallAction(
                  icon: Icons.videocam,
                  color: const Color(0xFF00E5A0),
                  label: 'Accept',
                  onTap: () {
                    Navigator.pop(context);
                    final String myId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    final List<String> ids = [myId, senderId]..sort();
                    final String channelName = ids.join('_');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          channelName: channelName,
                          userName: senderName,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallAction({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  void _showNewMessageNotification(Map<String, dynamic> data) async {
    if (_currentIndex == 2) return; // Don't show if already on messages tab

    final senderId = data['senderId'] as String;
    final text = data['text'] as String;

    final senderDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();
    final senderName = senderDoc.exists ? (senderDoc.data()?['name'] ?? 'Someone') : 'Someone';

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF122240),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00E5A0).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5A0).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF00E5A0), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message from $senderName',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _onTabTapped(2); // Go to messages tab
                },
                child: const Text('VIEW', style: TextStyle(color: Color(0xFF00E5A0), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = const Color(0xFF00E5A0);
    final Color inactiveColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: TextStyle(color: inactiveColor),
              selectedIconTheme: IconThemeData(color: activeColor),
              unselectedIconTheme: IconThemeData(color: inactiveColor),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  selectedIcon: Icon(Icons.saved_search),
                  label: Text('Skills'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: Text('Sessions'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AITutorScreen()),
          );
        },
        backgroundColor: activeColor,
        elevation: 8,
        child: const Icon(Icons.smart_toy, color: Color(0xFF0B1E3A), size: 30),
      ),
      bottomNavigationBar: isMobile 
        ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: activeColor,
              unselectedItemColor: inactiveColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.saved_search), label: 'Skills'),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Messages'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Sessions'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          )
        : null,
    );
  }
}
