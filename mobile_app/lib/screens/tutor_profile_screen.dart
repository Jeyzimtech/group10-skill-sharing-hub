import 'package:flutter/material.dart';
import 'booking_screen.dart';

class TutorProfileScreen extends StatelessWidget {
  final String name;
  final String skill;
  final double rating;
  final bool isAvailable;

  const TutorProfileScreen({
    super.key,
    required this.name,
    required this.skill,
    required this.rating,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFF0B1E3A);
    final Color accent = const Color(0xFF00E5A0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            
            // Name
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Skill
            Text(
              skill,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // Rating & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber[400], size: 20),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? accent.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAvailable
                          ? accent.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable ? accent : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          color: isAvailable ? accent : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bio Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hi! I am $name, an experienced tutor specializing in $skill. I have helped many students achieve their goals and would love to help you too. Let\'s work together to master new concepts in a fun and engaging way!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),

            // Book Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isAvailable ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        tutorName: name,
                        skill: skill,
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: bg,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: isAvailable ? 4 : 0,
                  shadowColor: accent.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Book Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
