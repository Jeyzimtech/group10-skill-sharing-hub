import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';
import '../utils/skill_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class SkillPostScreen extends StatefulWidget {
  const SkillPostScreen({super.key});

  @override
  State<SkillPostScreen> createState() => _SkillPostScreenState();
}

class _SkillPostScreenState extends State<SkillPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Programming';
  bool _isLoading = false;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      final url = await CloudinaryService().uploadImage(File(image.path));
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });
      if (url == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submitSkill() async {
    setState(() => _isLoading = true);
    
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final userData = userDoc.data() ?? {};
    final name = userData['name'] ?? user?.displayName ?? 'User';
    final posterPhotoUrl = userData['photoUrl'] ?? user?.photoURL;


    final skill = Skill(
      id: '',
      userId: user?.uid ?? '',
      title: _titleController.text,
      description: _descController.text,
      category: _category,
      postedBy: name,
      imageUrl: _imageUrl,
      posterPhotoUrl: posterPhotoUrl,
      createdAt: DateTime.now(),
    );

    final success = await SkillService.postSkill(skill);

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Post New Skill', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What skill can you share?',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: textColor.withValues(alpha: 0.1)),
                          image: _imageUrl != null
                              ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageUrl == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: subTextColor, size: 40),
                                  const SizedBox(height: 8),
                                  Text('Add a Skill Photo', style: TextStyle(color: subTextColor)),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  CustomTextField(
                    label: 'Skill Title',
                    icon: Icons.title,
                    controller: _titleController,
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Category',
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: textColor.withValues(alpha: 0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        isExpanded: true,
                        style: TextStyle(color: textColor),
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
                    controller: _descController,
                  ),
                  const SizedBox(height: 40),
                  
                  Center(
                    child: CustomButton(
                      text: 'Post Skill',
                      isLoading: _isLoading,
                      onPressed: _submitSkill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
