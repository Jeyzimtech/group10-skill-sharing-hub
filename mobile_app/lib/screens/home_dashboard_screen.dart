import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'skill_listing_screen.dart';
import 'skill_post_screen.dart';
import 'skill_category_screen.dart';
import 'tutor_profile_screen.dart';
import 'become_tutor_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  static const _accent = Color(0xFF00E5A0);


  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.hasData ? snapshot.data!.data() as Map<String, dynamic>? : null;
                    final displayName = data?['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? 'User';
                    final photoUrl = data?['photoUrl'] ?? FirebaseAuth.instance.currentUser?.photoURL ?? '';
                    return _buildHeader(textColor, subTextColor, cardColor, bgColor, displayName, photoUrl);
                  },
                ),
              ),

              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Responsive(
                  mobile: Column(
                    children: [
                      _buildSearchBar(isDark),
                      const SizedBox(height: 24),
                      _buildQuickActions(textColor, isDark),
                      const SizedBox(height: 24),
                      _buildBecomeTutorCTA(textColor, subTextColor, isDark),
                    ],
                  ),
                  tablet: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 2, child: _buildSearchBar(isDark)),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _buildQuickActions(textColor, isDark)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildBecomeTutorCTA(textColor, subTextColor, isDark),
                    ],
                  ),
                  desktop: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildSearchBar(isDark),
                            const SizedBox(height: 24),
                            _buildBecomeTutorCTA(textColor, subTextColor, isDark),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildQuickActions(textColor, isDark)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildSectionHeader('Skill Categories', textColor),
              ),
              const SizedBox(height: 16),
              SkillCategoryScreen(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                },
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSectionHeader('Featured Tutors', textColor),
              ),
              const SizedBox(height: 16),
              _buildFeaturedTutors(textColor, cardColor, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(Color textColor, Color subTextColor, Color cardBg, Color bg, String displayName, String photoUrl) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $displayName',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find skills to learn today',
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Avatar with online dot
        Stack(
          children: [
            Hero(
              tag: 'profile_icon',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  image: photoUrl.isNotEmpty ? DecorationImage(
                    image: NetworkImage(photoUrl),
                    fit: BoxFit.cover,
                  ) : null,
                  border: Border.all(
                    color: _accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    )
                  ]
                ),
                child: photoUrl.isEmpty ? Icon(
                  Icons.person,
                  color: textColor.withValues(alpha: 0.7),
                  size: 26,
                ) : null,
              ),
            ),
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: bg, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  // ── Search bar ──────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SkillListingScreen(initialSearch: value),
            ),
          );
        }
      },
      decoration: InputDecoration(
        hintText: 'Search skills, tutors...',
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF2DD4BF)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2DD4BF),
          ),
        ),
      ),
    );
  }

  // ── Quick actions ───────────────────────────────────────────────────
  Widget _buildQuickActions(Color textColor, bool isDark) {
    return Row(
      children: [
        _buildActionPill(
          label: 'Find Tutor',
          icon: Icons.search,
          isPrimary: true,
          isDark: isDark,
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(1); // Index 1 is Skills tab
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillListingScreen()),
              );
            }
          },
        ),
        const SizedBox(width: 10),
        _buildActionPill(
          label: 'Offer Skill',
          icon: Icons.add_circle_outline,
          isPrimary: false,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SkillPostScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildActionPill(
          label: 'My Sessions',
          icon: Icons.calendar_today,
          isPrimary: false,
          isDark: isDark,
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(3); // Index 3 is Sessions tab in main navigation
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bgColor = isPrimary 
        ? _accent 
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100);
        
    final borderColor = isPrimary
        ? _accent
        : (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05));
        
    final activeTextColor = const Color(0xFF0B1E3A);
    final inactiveTextColor = isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87;
    final color = isPrimary ? activeTextColor : inactiveTextColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBecomeTutorCTA(Color textColor, Color subTextColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark ? LinearGradient(
          colors: [_accent.withValues(alpha: 0.15), _accent.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.25)),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: _accent, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to share your skills?',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Become a tutor and help fellow students!',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: _accent.withValues(alpha: 0.5), size: 14),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BecomeTutorScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: const Color(0xFF0B1E3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'Apply to Tutoring',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Featured tutors ─────────────────────────────────────────────────
  Widget _buildFeaturedTutors(Color textColor, Color cardBg, bool isDark) {
    return SizedBox(
      height: 220,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tutors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5A0)));
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No featured tutors yet', style: TextStyle(color: textColor.withValues(alpha: 0.5))),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final t = docs[index].data() as Map<String, dynamic>;
              return _buildTutorCard(
                context: context,
                uid: t['uid'] ?? '',
                name: t['name'] ?? 'Tutor',
                skill: t['skills'] ?? 'General',
                rating: (t['rating'] ?? 5.0).toString(),
                photoUrl: t['photoUrl'] ?? '',
                isAvailable: t['available'] ?? true,
                rate: (t['rate'] ?? 1500.0).toDouble(),


                textColor: textColor,
                cardBg: cardBg,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTutorCard({
    required BuildContext context,
    required String uid,
    required String name,
    required String skill,
    required String rating,
    String? photoUrl,
    required bool isAvailable,
    required Color textColor,
    required Color cardBg,
    required bool isDark,
    required double rate,
  }) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorProfileScreen(
              uid: uid,
              name: name,
              skill: skill,
              rating: double.tryParse(rating) ?? 4.0,
              isAvailable: isAvailable,
              photoUrl: photoUrl,
              rate: rate,
            ),

          ),
        );
      },
      child: Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        gradient: isDark ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A2F50),
            cardBg,
          ],
        ) : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                  image: DecorationImage(
                    image: (photoUrl != null && photoUrl.isNotEmpty) 
                      ? NetworkImage(photoUrl) 
                      : NetworkImage('https://i.pravatar.cc/600?u=$name'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              if (isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Busy',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black38,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            name,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            skill,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                rating,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorProfileScreen(
                      uid: uid,
                      name: name,
                      skill: skill,
                      rating: double.tryParse(rating) ?? 4.0,
                      isAvailable: isAvailable,
                      rate: rate,
                    ),

                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent.withValues(alpha: 0.1),
                foregroundColor: _accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _accent.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: const Text(
                'Book',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
