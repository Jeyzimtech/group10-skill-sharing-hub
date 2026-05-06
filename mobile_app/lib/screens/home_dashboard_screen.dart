import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'skill_listing_screen.dart';
import 'skill_post_screen.dart';
import 'skill_category_screen.dart';
import 'tutor_profile_screen.dart';

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
  static const _bg = Color(0xFF0B1E3A);
  static const _accent = Color(0xFF00E5A0);
  static const _cardBg = Color(0xFF122240);

  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }

  static const List<Map<String, dynamic>> _tutors = [
    {'name': 'Mthabisi', 'skill': 'Python Programming', 'rating': '4.9', 'available': true, 'imageUrl': 'https://randomuser.me/api/portraits/men/32.jpg'},
    {'name': 'Cleo', 'skill': 'Guitar Lessons', 'rating': '4.8', 'available': true, 'imageUrl': 'https://randomuser.me/api/portraits/women/44.jpg'},
    {'name': 'John', 'skill': 'Calculus Tutoring', 'rating': '4.5', 'available': false, 'imageUrl': 'https://randomuser.me/api/portraits/men/46.jpg'},
    {'name': 'Jane', 'skill': 'UI/UX Design', 'rating': '5.0', 'available': true, 'imageUrl': 'https://randomuser.me/api/portraits/women/68.jpg'},
    {'name': 'Pierre', 'skill': 'French Language', 'rating': '4.7', 'available': true, 'imageUrl': 'https://randomuser.me/api/portraits/men/22.jpg'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildHeader(),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildSectionHeader('Skill Categories'),
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
                child: _buildSectionHeader('Featured Tutors'),
              ),
              const SizedBox(height: 16),
              _buildFeaturedTutors(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $_userName 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find skills to learn today',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Avatar with online dot
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cardBg,
                border: Border.all(
                  color: _accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white.withValues(alpha: 0.7),
                size: 26,
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
                  border: Border.all(color: _bg, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Search bar (matches Skill Hub exactly) ──────────────────────────
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search skills, tutors...',
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF2DD4BF)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
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
  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionPill(
          label: 'Find Tutor',
          icon: Icons.search,
          isPrimary: true,
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
          onTap: () {
            if (widget.onNavigateTab != null) {
              widget.onNavigateTab!(2); // Index 2 is Sessions tab
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
    required VoidCallback onTap,
  }) {
    final bgColor = isPrimary 
        ? _accent 
        : Colors.white.withValues(alpha: 0.05);
        
    final borderColor = isPrimary
        ? _accent
        : Colors.white.withValues(alpha: 0.15);
        
    final textColor = isPrimary 
        ? _bg 
        : Colors.white.withValues(alpha: 0.85);

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
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
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

  // ── Section header ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Featured tutors ─────────────────────────────────────────────────
  Widget _buildFeaturedTutors() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tutors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final t = _tutors[index];
          return _buildTutorCard(
            context: context,
            name: t['name'] as String,
            skill: t['skill'] as String,
            rating: t['rating'] as String,
            imageUrl: t['imageUrl'] as String,
            isAvailable: t['available'] as bool,
          );
        },
      ),
    );
  }

  Widget _buildTutorCard({
    required BuildContext context,
    required String name,
    required String skill,
    required String rating,
    required String imageUrl,
    required bool isAvailable,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorProfileScreen(
              name: name,
              skill: skill,
              rating: double.tryParse(rating) ?? 4.0,
              isAvailable: isAvailable,
            ),
          ),
        );
      },
      child: Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A2F50),
            _cardBg,
          ],
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white70,
                  size: 28,
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
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Busy',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            skill,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
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
                style: const TextStyle(
                  color: Colors.white,
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
                      name: name,
                      skill: skill,
                      rating: double.tryParse(rating) ?? 4.0,
                      isAvailable: isAvailable,
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
