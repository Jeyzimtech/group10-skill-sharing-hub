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
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: const Color(0xFF1E293B),
              selectedColor: const Color(0xFF2DD4BF),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
