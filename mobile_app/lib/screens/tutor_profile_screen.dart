import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/review.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';

class TutorProfileScreen extends StatelessWidget {
  final String uid;
  final String name;
  final String skill;
  final double rating;
  final bool isAvailable;
  final String? photoUrl;
  final double rate;

  const TutorProfileScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.skill,
    required this.rating,
    required this.isAvailable,
    required this.rate,
    this.photoUrl,
  });


  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? const Color(0xFF122240) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white54 : Colors.black54;
    const Color accent = Color(0xFF00E5A0);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image with Badge
            // Header Section with Profile Pic
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: 0.2),
                    bgColor,
                  ],
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: accent.withValues(alpha: 0.1),
                  backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : NetworkImage('https://i.pravatar.cc/300?u=$name'),
                ),
              ),
            ),
            
            // Verified Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: accent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'VERIFIED TUTOR',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Senior $skill Expert',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${rate.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: const TextStyle(

                              color: accent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PER HOUR',
                            style: TextStyle(
                              color: subTextColor.withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // About Me
                  Text(
                    'ABOUT ME',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: textColor.withValues(alpha: 0.05)),
                    ),
                    child: Text(
                      'Final year student, expert in $skill and practical project-building. I focus on clear architectural concepts and industry best practices.',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('tutorUid', isEqualTo: uid)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: accent));
                      }

                      final reviews = snapshot.data?.docs.map((doc) => Review.fromFirestore(doc)).toList() ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'REVIEWS',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$rating (${reviews.isEmpty ? 2 : reviews.length})',
                                        style: TextStyle(
                                          color: textColor.withValues(alpha: 0.6),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (uid != FirebaseAuth.instance.currentUser?.uid)
                                TextButton.icon(
                                  onPressed: () => _showAddReviewDialog(context),
                                  icon: const Icon(Icons.rate_review_outlined, size: 16, color: accent),
                                  label: const Text('Write Review', style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (reviews.isEmpty) ...[
                            // Dummy reviews for Pise and Obert as requested
                            _buildReviewCard('Pise', 'Outstanding tutor! Very patient and explained the concepts in great detail.', textColor, subTextColor, isDark, 5.0),
                            const SizedBox(height: 12),
                            _buildReviewCard('Obert', 'Great session, helped me debug my code in minutes. Highly recommended.', textColor, subTextColor, isDark, 5.0),
                          ],
                          ...reviews.map((review) => Column(
                            children: [
                              _buildReviewCard(
                                review.reviewerName,
                                review.comment,
                                textColor,
                                subTextColor,
                                isDark,
                                review.rating,
                                photoUrl: review.reviewerPhotoUrl,
                              ),
                              const SizedBox(height: 12),
                            ],
                          )),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: textColor.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: textColor.withValues(alpha: 0.1)),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: accent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: uid,
                        otherUserName: name,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isAvailable ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          tutorUid: uid, // Use uid here
                          tutorName: name,
                          skill: skill,
                        ),
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: const Color(0xFF0B1E3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Book a Session',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(String reviewer, String comment, Color textColor, Color subTextColor, bool isDark, double rating, {String? photoUrl}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : NetworkImage('https://i.pravatar.cc/100?u=$reviewer'),
              ),
              const SizedBox(width: 8),
              Text(
                reviewer,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star, 
                  color: index < rating ? Colors.amber : Colors.grey.withValues(alpha: 0.3), 
                  size: 12
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"$comment"',
            style: TextStyle(
              color: subTextColor,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF122240),
          title: const Text('Add Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rate your experience:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => GestureDetector(
                  onTap: () => setDialogState(() => selectedRating = index + 1.0),
                  child: Icon(
                    Icons.star,
                    color: index < selectedRating ? Colors.amber : Colors.white24,
                    size: 32,
                  ),
                )),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: commentController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Describe your session...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  await AuthService.postReview(
                    tutorUid: uid,
                    comment: commentController.text,
                    rating: selectedRating,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A0)),
              child: const Text('SUBMIT', style: TextStyle(color: Color(0xFF0B1E3A), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
