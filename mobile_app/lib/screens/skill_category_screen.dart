import 'package:flutter/material.dart';

class SkillCategoryScreen extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const SkillCategoryScreen({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categories = [
    'All',
    'Programming',
    'Music',
    'Academic',
    'Design',
    'Language',
    'Sports',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
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
                    ? const Color(0xFF2DD4BF).withValues(alpha: 0.25)
                    : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2DD4BF)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              checkmarkColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF2DD4BF) : Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
