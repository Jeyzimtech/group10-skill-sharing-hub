import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../utils/skill_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SkillPostScreen extends StatefulWidget {
  const SkillPostScreen({super.key});

  @override
  State<SkillPostScreen> createState() => _SkillPostScreenState();
}

class _SkillPostScreenState extends State<SkillPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = 'Programming';
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final skill = Skill(
      id: '',
      title: _title,
      description: _description,
      category: _category,
      postedBy: 'User', // In a real app, this would be the logged-in user's name
      createdAt: DateTime.now(),
    );

    final success = await SkillService.postSkill(skill);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post skill')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Post New Skill', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What skill can you share?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Skill Title',
                icon: Icons.title,
                onChanged: (v) => _title = v,
                // Add validation if needed
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    dropdownColor: const Color(0xFF1E293B),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2DD4BF)),
                    items: <String>['Programming', 'Music', 'Academic', 'Design', 'Language', 'Sports', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => _category = newValue);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description',
                icon: Icons.description,
                // Multi-line would be better here, but CustomTextField is currently single-line
                onChanged: (v) => _description = v,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'POST SKILL',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
