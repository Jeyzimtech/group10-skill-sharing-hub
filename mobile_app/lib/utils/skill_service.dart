import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/skill.dart';

class SkillService {
  // Replace this with your actual backend URL when ready
  static const String baseUrl = 'https://your-api-url.com/api';

  // Fetch all skills
  static Future<List<Skill>> fetchSkills() async {
  // TODO: Replace with real API call when backend is ready
  // Returning mock data directly for now
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockSkills();
}

  // Post a new skill
  static Future<bool> postSkill(Skill skill) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/skills'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(skill.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      // Mock success while backend is not ready
      return true;
    }
  }

  // Search skills
  static Future<List<Skill>> searchSkills(String query, String category) async {
    final all = await fetchSkills();
    return all.where((skill) {
      final matchesQuery = skill.title.toLowerCase().contains(query.toLowerCase()) ||
          skill.description.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'All' || skill.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  // Mock data for development
  static List<Skill> _mockSkills() {
    return [
      Skill(id: '1', title: 'Python Programming', description: 'I can teach Python basics to advanced', category: 'Programming', postedBy: 'Mthabisi', createdAt: DateTime.now()),
      Skill(id: '2', title: 'Guitar Lessons', description: 'Acoustic guitar for beginners', category: 'Music', postedBy: 'Cleo', createdAt: DateTime.now()),
      Skill(id: '3', title: 'Math Tutoring', description: 'Calculus and Linear Algebra help', category: 'Academic', postedBy: 'John', createdAt: DateTime.now()),
      Skill(id: '4', title: 'Graphic Design', description: 'Figma and Canva design skills', category: 'Design', postedBy: 'Jane', createdAt: DateTime.now()),
      Skill(id: '5', title: 'French Language', description: 'Conversational French lessons', category: 'Language', postedBy: 'Pierre', createdAt: DateTime.now()),
    ];
  }
}