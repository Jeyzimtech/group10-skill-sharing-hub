import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../utils/skill_service.dart';
import '../screens/skill_category_screen.dart';
import '../screens/skill_post_screen.dart';

class SkillListingScreen extends StatefulWidget {
  const SkillListingScreen({super.key});

  @override
  State<SkillListingScreen> createState() => _SkillListingScreenState();
}

class _SkillListingScreenState extends State<SkillListingScreen> {
  List<Skill> _skills = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    setState(() => _isLoading = true);
    final skills = await SkillService.searchSkills(
      _searchController.text,
      _selectedCategory,
    );
    setState(() {
      _skills = skills;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Skill Sharing Hub',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2DD4BF)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SkillPostScreen(),
                ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _loadSkills(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search skills...',
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
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2DD4BF),
                  ),
                ),
              ),
            ),
          ),

          // Category filter
          SkillCategoryScreen(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
              _loadSkills();
            },
          ),

          const SizedBox(height: 10),

          // Skills list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2DD4BF),
                    ),
                  )
                : _skills.isEmpty
                    ? const Center(
                        child: Text(
                          'No skills found',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2DD4BF),
                        onRefresh: _loadSkills,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _skills.length,
                          itemBuilder: (context, index) {
                            return _buildSkillCard(_skills[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  skill.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2DD4BF).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  skill.category,
                  style: const TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            skill.description,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                skill.postedBy,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 14, color: Colors.white38),
              const SizedBox(width: 4),
              Text(
                '${skill.createdAt.day}/${skill.createdAt.month}/${skill.createdAt.year}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}