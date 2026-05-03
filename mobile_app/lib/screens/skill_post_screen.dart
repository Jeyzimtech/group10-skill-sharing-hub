import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../utils/skill_service.dart';
import '../screens/skill_category_screen.dart';

class SkillPostScreen extends StatefulWidget {
  const SkillPostScreen({super.key});

  @override
  State<SkillPostScreen> createState() => _SkillPostScreenState();
}

class _SkillPostScreenState extends State<SkillPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedCategory = 'Programming';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitSkill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final skill = Skill(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      postedBy: _nameController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await SkillService.postSkill(skill);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill posted successfully!'),
          backgroundColor: Color(0xFF2DD4BF),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to post skill. Try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2DD4BF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post a Skill',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share what you can teach',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Your Name
              _buildLabel('Your Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Mthabisi',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 20),

              // Skill Title
              _buildLabel('Skill Title'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hint: 'e.g. Python Programming',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a skill title' : null,
              ),
              const SizedBox(height: 20),

              // Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Describe what you can teach and your experience...',
                maxLines: 4,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 20),

              // Category
              _buildLabel('Category'),
              const SizedBox(height: 12),
              SkillCategoryScreen(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 40),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitSkill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    disabledBackgroundColor:
                        const Color(0xFF2DD4BF).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Post Skill',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}