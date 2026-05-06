import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../main.dart'; // To access themeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF00E5A0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('PREFERENCES', accent),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, mode, __) {
                  return Switch(
                    value: mode == ThemeMode.dark,
                    onChanged: (v) {
                      themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeThumbColor: accent,
                  );
                },
              ),
            ),
            _buildSettingTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (v) {
                  setState(() => _notificationsEnabled = v);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(v ? 'Notifications enabled' : 'Notifications disabled'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: accent,
                    ),
                  );
                },
                activeThumbColor: accent,
              ),
            ),
            _buildSettingTile(
              icon: Icons.language_outlined,
              title: 'Language',
              trailing: Text(_selectedLanguage, style: const TextStyle(color: accent)),
              onTap: () => _showLanguagePicker(context),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('ABOUT THE APP', accent),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'App Version',
              trailing: const Text('v1.0.4 (Beta)', style: TextStyle(color: Colors.white38)),
            ),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: 'App License',
              onTap: () => _showLicense(context),
            ),
            _buildSettingTile(
              icon: Icons.groups_outlined,
              title: 'Developers',
              subtitle: 'Developed by NUST Student Group 10',
              onTap: () => _showDevelopers(context),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('SUPPORT & FEEDBACK', accent),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              onTap: () => _showFeedbackDialog(context, 'Report a Bug'),
            ),
            _buildSettingTile(
              icon: Icons.feedback_outlined,
              title: 'Suggest Improvements',
              subtitle: 'Help us make Skill Hub better!',
              onTap: () => _showFeedbackDialog(context, 'Suggest Improvements'),
            ),

            const SizedBox(height: 32),
            StreamBuilder<DocumentSnapshot>(
              stream: AuthService.getUserData(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final isTutor = data['isTutor'] ?? false;
                  
                  if (isTutor) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('DANGER ZONE', Colors.redAccent),
                        const SizedBox(height: 12),
                        _buildSettingTile(
                          icon: Icons.person_remove_outlined,
                          title: 'Leave Tutoring',
                          subtitle: 'You will no longer be listed as a tutor.',
                          trailing: const Icon(Icons.chevron_right, color: Colors.redAccent, size: 20),
                          onTap: () => _showLeaveTutorDialog(context),
                        ),
                      ],
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.hub_outlined, color: accent, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'SKILL SHARING HUB',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveTutorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF122240),
        title: const Text('Leave Tutoring?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to stop being a tutor? This will remove your tutor profile and you will no longer be visible in the tutor listings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.leaveTutor();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You have successfully left the tutoring program.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('LEAVE TUTOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF122240) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 22),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)) : null,
        trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.black26, size: 20),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languages = ['English', 'Urdu', 'Spanish', 'French', 'Arabic'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...languages.map((lang) => ListTile(
              title: Text(lang, textAlign: TextAlign.center),
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
              },
              selected: _selectedLanguage == lang,
              selectedTileColor: const Color(0xFF00E5A0).withValues(alpha: 0.1),
            )),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe below:'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter details...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Color(0xFF00E5A0)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A0)),
            child: const Text('SUBMIT', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showLicense(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('License', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'MIT License\n\nCopyright (c) 2024 NUST Student Group 10\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software...',
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Color(0xFF00E5A0))),
          ),
        ],
      ),
    );
  }

  void _showDevelopers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Developers', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF00E5A0),
              child: Icon(Icons.groups, color: Color(0xFF0B1E3A), size: 40),
            ),
            SizedBox(height: 16),
            Text(
              'NUST Student Group 10',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'This application was developed as a final year project to facilitate skill sharing within the NUST community.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GREAT!', style: TextStyle(color: Color(0xFF00E5A0))),
          ),
        ],
      ),
    );
  }
}
