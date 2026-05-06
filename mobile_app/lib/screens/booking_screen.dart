import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation_screen.dart';
import '../services/chat_service.dart';

class BookingScreen extends StatefulWidget {
  final String tutorUid;
  final String tutorName;
  final String skill;

  const BookingScreen({
    super.key,
    required this.tutorUid,
    required this.tutorName,
    required this.skill,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final Color _accent = const Color(0xFF00E5A0);
  final Color _cardBg = const Color(0xFF122240);

  DateTime? _selectedDate;
  String? _selectedTime;
  String _sessionType = 'Online'; // Default

  final List<String> _timeSlots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'];

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a session.')),
      );
      return;
    }

    try {
      // Find the tutor's UID from the 'tutors' collection based on their name (for now, or ideally passed in)
      // Since we might not have it, let's assume we need to pass it or look it up.
      // For this step, I'll assume we should have passed it. I'll update the constructor next.
      final tutorUid = widget.tutorUid; 

      await FirebaseFirestore.instance.collection('sessions').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Student',
        'tutorUid': tutorUid,
        'tutorName': widget.tutorName,
        'skill': widget.skill,
        'date': (_selectedDate ?? DateTime.now()).toIso8601String(),
        'time': _selectedTime ?? 'ASAP',
        'status': 'upcoming',
        'type': _sessionType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send automated message to tutor
      final dateStr = DateFormat('MMM dd').format(_selectedDate ?? DateTime.now());
      await ChatService.sendMessage(
        tutorUid, 
        'Hi ${widget.tutorName}! I just booked a ${_sessionType.toLowerCase()} session for ${widget.skill} on $dateStr at ${_selectedTime ?? 'ASAP'}. Looking forward to it!',
      );

      if (!mounted) return;

      // Show a success dialog and pop back
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Color(0xFF00E5A0), size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are booked with ${widget.tutorName} for ${widget.skill}.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 2)),
                (route) => false,
              );
            },
            child: Text('Done', style: TextStyle(color: _accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? const Color(0xFF122240) : Colors.white;
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
        title: Text(
          'Book Session', 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tutor summary
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                          ),
                          child: Icon(Icons.person, color: subTextColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tutorName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.skill,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Date Selection
                    Text(
                      'Select Date',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final DateTime now = DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 60)),
                        );

                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDate != null 
                                ? _accent.withValues(alpha: 0.5) 
                                : textColor.withValues(alpha: 0.1),
                          ),
                          boxShadow: isDark ? [] : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: _selectedDate != null ? _accent : subTextColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!)
                                  : 'Choose a date',
                              style: TextStyle(
                                color: _selectedDate != null ? textColor : subTextColor,
                                fontSize: 16,
                                fontWeight: _selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Time Selection
                    Text(
                      'Select Time',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _timeSlots.map((time) {
                        final isSelected = _selectedTime == time;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? _accent.withValues(alpha: 0.15) : cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? _accent 
                                    : textColor.withValues(alpha: 0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: (isSelected || isDark) ? [] : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              time,
                              style: TextStyle(
                                color: isSelected ? _accent : textColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Session Type
                    Text(
                      'Session Type',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSessionTypeOption('Online', Icons.video_camera_front, isDark, textColor, subTextColor, cardColor),
                        const SizedBox(width: 16),
                        _buildSessionTypeOption('In-person', Icons.people, isDark, textColor, subTextColor, cardColor),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Confirm Button Area
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(
                    color: textColor.withValues(alpha: 0.05),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: textColor.withValues(alpha: 0.1),
                    foregroundColor: const Color(0xFF0B1E3A),
                    disabledForegroundColor: textColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: (_selectedDate != null && _selectedTime != null) ? 4 : 0,
                    shadowColor: _accent.withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTypeOption(String type, IconData icon, bool isDark, Color textColor, Color subTextColor, Color cardBg) {
    final isSelected = _sessionType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _sessionType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _accent.withValues(alpha: 0.1) : cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _accent.withValues(alpha: 0.5) : textColor.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: (isSelected || isDark) ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? _accent : subTextColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? textColor : subTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
