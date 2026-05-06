import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../utils/skill_service.dart';
import '../screens/skill_post_screen.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillListingScreen extends StatefulWidget {
  final String? initialSearch;
  const SkillListingScreen({super.key, this.initialSearch});

  @override
  State<SkillListingScreen> createState() => _SkillListingScreenState();
}

class _SkillListingScreenState extends State<SkillListingScreen> {
  List<Skill> _skills = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    final skills = await SkillService.fetchSkills(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      query: _searchController.text,
    );
    if (mounted) {
      setState(() {
        _skills = skills;
        _isLoading = false;
      });
    }
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
        title: Text('Discover Skills', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2DD4BF)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkillPostScreen()),
              );
              _loadSkills();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search skills...',
                hintStyle: TextStyle(color: subTextColor),
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
                    color: textColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              onSubmitted: (_) => _loadSkills(),
            ),
          ),

          // Categories
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'All',
                'Programming',
                'Design',
                'Academic',
                'Music',
                'Language',
                'Sports',
              ].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _loadSkills();
                    },
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                    selectedColor: const Color(0xFF2DD4BF),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Skills list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))
                : _skills.isEmpty
                    ? Center(child: Text('No skills found', style: TextStyle(color: subTextColor)))
                    : RefreshIndicator(
                        color: const Color(0xFF2DD4BF),
                        onRefresh: _loadSkills,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _skills.length,
                                itemBuilder: (context, index) {
                                  return _buildSkillCard(_skills[index], isDark, textColor, subTextColor);
                                },
                              );
                            } else {
                              return GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: constraints.maxWidth < 1000 ? 2 : 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.8,
                                ),
                                itemCount: _skills.length,
                                itemBuilder: (context, index) {
                                  return _buildSkillCard(_skills[index], isDark, textColor, subTextColor);
                                },
                              );
                            }
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Skill skill, bool isDark, Color textColor, Color subTextColor) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return GestureDetector(
      onTap: () {
        if (skill.userId.isEmpty || skill.userId == currentUserId) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              otherUserId: skill.userId,
              otherUserName: skill.postedBy,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.08)),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
                  backgroundImage: (skill.posterPhotoUrl != null && skill.posterPhotoUrl!.isNotEmpty)
                      ? NetworkImage(skill.posterPhotoUrl!)
                      : NetworkImage('https://i.pravatar.cc/100?u=${skill.postedBy}'),
                ),
                const SizedBox(width: 8),
                Text(skill.postedBy, style: TextStyle(color: subTextColor, fontSize: 12)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Skill',
                    style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              skill.title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              skill.description,
              style: TextStyle(color: subTextColor, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                if (skill.userId != currentUserId) ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: skill.userId,
                            otherUserName: skill.postedBy,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, size: 16, color: Color(0xFF2DD4BF)),
                    label: const Text('Message', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ] else
                  Text('My Post', style: TextStyle(color: subTextColor.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
