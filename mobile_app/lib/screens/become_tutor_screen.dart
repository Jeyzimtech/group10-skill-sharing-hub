import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class BecomeTutorScreen extends StatefulWidget {
  const BecomeTutorScreen({super.key});

  @override
  State<BecomeTutorScreen> createState() => _BecomeTutorScreenState();
}

class _BecomeTutorScreenState extends State<BecomeTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _rateController = TextEditingController();
  final _expController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _bioController.dispose();
    _skillsController.dispose();
    _rateController.dispose();
    _expController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isLoading = true);
    
    try {
      await AuthService.becomeTutor(
        bio: _bioController.text,
        skills: _skillsController.text,
        rate: double.tryParse(_rateController.text) ?? 0.0,
        experience: double.tryParse(_expController.text) ?? 0.0,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Congratulations! You are now a verified tutor.'),
          backgroundColor: Color(0xFF00E5A0),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text('Become a Tutor', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                    'Share your expertise',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help others learn while earning rewards.',
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  
                  CustomTextField(
                    label: 'Professional Bio',
                    icon: Icons.person_outline,
                    controller: _bioController,
                  ),
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    label: 'Skills (e.g. Python, Design)',
                    icon: Icons.psychology_outlined,
                    controller: _skillsController,
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Rate (Rs/hr)',
                          icon: Icons.payments_outlined,
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'Experience (Yrs)',
                          icon: Icons.work_outline,
                          controller: _expController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  Center(
                    child: CustomButton(
                      text: 'Submit Application',
                      onPressed: _submit,
                      isLoading: _isLoading,
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
                  child: CircularProgressIndicator(color: Color(0xFF00E5A0)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
