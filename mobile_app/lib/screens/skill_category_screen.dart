import 'package:flutter/material.dart';

class SkillCategoryScreen extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String selectedCategory;

  const SkillCategoryScreen({
    super.key,
    required this.onCategorySelected,
    required this.selectedCategory,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.apps},
    {'name': 'Programming', 'icon': Icons.code},
    {'name': 'Design', 'icon': Icons.brush},
    {'name': 'Music', 'icon': Icons.music_note},
    {'name': 'Academic', 'icon': Icons.school},
    {'name': 'Language', 'icon': Icons.translate},
    {'name': 'Sports', 'icon': Icons.sports},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['name'];

          return GestureDetector(
            onTap: () => onCategorySelected(category['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2DD4BF).withOpacity(0.25)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2DD4BF)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? const Color(0xFF2DD4BF)
                        : Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2DD4BF)
                          : Colors.white54,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}