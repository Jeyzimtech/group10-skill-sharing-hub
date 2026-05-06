import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/responsive.dart';
import 'settings_screen.dart';
import 'become_tutor_screen.dart';
import 'skill_post_screen.dart';
import '../auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color _accent = const Color(0xFF00E5A0);
  bool _isUploading = false;


  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? const Color(0xFF122240) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: AuthService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E5A0)));
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found', style: TextStyle(color: textColor)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'User';
          final email = data['email'] ?? '';
          final studentId = data['studentNumber'] ?? 'N/A';
          final dob = data['dob'] ?? 'N/A';
          final isTutor = data['isTutor'] ?? false;
          final photoUrl = data['photoUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildHeader(name, email, isTutor, photoUrl, textColor, subTextColor, cardColor),
                    const SizedBox(height: 32),
                    
                    Responsive(
                      mobile: Column(
                        children: [
                          _buildQuickStats(snapshot.data!.id, textColor, subTextColor),
                          const SizedBox(height: 32),
                          if (!isTutor) _buildBecomeTutorCard(context, isDark),
                          const SizedBox(height: 32),
                          _buildPersonalDetails(name, email, studentId, dob, textColor, subTextColor, cardColor),
                        ],
                      ),
                      tablet: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildQuickStats(snapshot.data!.id, textColor, subTextColor)),
                              const SizedBox(width: 32),
                              if (!isTutor) Expanded(child: _buildBecomeTutorCard(context, isDark)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildPersonalDetails(name, email, studentId, dob, textColor, subTextColor, cardColor),
                        ],
                      ),
                      desktop: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                _buildQuickStats(snapshot.data!.id, textColor, subTextColor),
                                const SizedBox(height: 32),
                                if (!isTutor) _buildBecomeTutorCard(context, isDark),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 2,
                            child: _buildPersonalDetails(name, email, studentId, dob, textColor, subTextColor, cardColor),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    _buildMySkills(context, isTutor ? (data['tutorProfile']?['skills'] ?? '') : '', textColor),
                    const SizedBox(height: 32),
                    _buildActions(context, textColor, isDark, name, photoUrl),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildHeader(String name, String email, bool isTutor, String photoUrl, Color textColor, Color subTextColor, Color cardBg) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: _accent.withValues(alpha: 0.1),
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty ? Text(
            name.isNotEmpty ? name[0] : 'U',
            style: TextStyle(color: _accent, fontSize: 40, fontWeight: FontWeight.bold),
          ) : null,
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: subTextColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isTutor ? 'Verified Tutor' : 'Student User',
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(String userId, Color textColor, Color subTextColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, sessionSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('skills')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, skillSnap) {
            final sessionCount = sessionSnap.hasData ? sessionSnap.data!.docs.length : 0;
            final skillCount = skillSnap.hasData ? skillSnap.data!.docs.length : 0;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Sessions\nBooked', sessionCount.toString(), textColor, subTextColor),
                Container(width: 1, height: 40, color: textColor.withValues(alpha: 0.1)),
                _buildStatItem('Skills\nOffered', skillCount.toString(), textColor, subTextColor),
                Container(width: 1, height: 40, color: textColor.withValues(alpha: 0.1)),
                _buildStatItem('Rating', '⭐ 4.9', textColor, subTextColor),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subTextColor,
            fontSize: 12,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBecomeTutorCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark ? LinearGradient(
          colors: [_accent.withValues(alpha: 0.2), _accent.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.school, color: _accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earn by Teaching',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join our tutor community and share your expertise.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Become a Tutor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(String name, String email, String studentId, String dob, Color textColor, Color subTextColor, Color cardBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textColor.withValues(alpha: 0.05)),
            boxShadow: [
              if (cardBg == Colors.white)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
            ]
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.person_outline, 'Full Name', name, textColor, subTextColor),
              Divider(color: textColor.withValues(alpha: 0.05), height: 1),
              _buildDetailRow(Icons.email_outlined, 'Email', email, textColor, subTextColor),
              Divider(color: textColor.withValues(alpha: 0.05), height: 1),
              _buildDetailRow(Icons.school_outlined, 'Student ID', studentId, textColor, subTextColor),
              Divider(color: textColor.withValues(alpha: 0.05), height: 1),
              _buildDetailRow(Icons.cake_outlined, 'Date of Birth', dob, textColor, subTextColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: subTextColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySkills(BuildContext context, String skillsString, Color textColor) {
    final skills = skillsString.isEmpty ? ['None yet'] : skillsString.split(',').map((s) => s.trim()).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Skills',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SkillPostScreen()),
                );
              },
              icon: Icon(Icons.add, size: 16, color: _accent),
              label: Text(
                'Add Skill',
                style: TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Color textColor, bool isDark, String currentName, String currentPhotoUrl) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _showEditProfileDialog(context, currentName, currentPhotoUrl),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(color: textColor.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, size: 20),
            label: const Text(
              'Log Out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E), // Destructive Red
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFE53E3E).withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentPhotoUrl) {
    final nameController = TextEditingController(text: currentName);
    final photoController = TextEditingController(text: currentPhotoUrl);
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF122240),
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(color: Color(0xFF00E5A0)),
                ),
              
              // Photo Upload Section
              GestureDetector(
                onTap: _isUploading ? null : () async {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setDialogState(() => _isUploading = true);
                    setState(() => _isUploading = true);
                    
                    final url = await CloudinaryService().uploadImage(File(image.path));
                    
                    if (url != null) {
                      photoController.text = url;
                    }
                    
                    setDialogState(() => _isUploading = false);
                    setState(() => _isUploading = false);
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: _accent.withValues(alpha: 0.1),
                  backgroundImage: photoController.text.isNotEmpty ? NetworkImage(photoController.text) : null,
                  child: photoController.text.isEmpty 
                    ? Icon(Icons.camera_alt, color: _accent, size: 30)
                    : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to change photo',
                style: TextStyle(color: _accent.withValues(alpha: 0.7), fontSize: 12),
              ),
              const SizedBox(height: 24),
              
              // Name field remains
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5A0))),
                ),
              ),
              const SizedBox(height: 16),
              // The Profile Photo URL text field has been removed as per user request
              // The image can still be changed by tapping the profile picture above.

            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: _isUploading ? null : () async {
                await AuthService.updateProfile(
                  name: nameController.text,
                  photoUrl: photoController.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A0)),
              child: const Text('Save', style: TextStyle(color: Color(0xFF0B1E3A))),
            ),
          ],
        ),
      ),
    );
  }
}

