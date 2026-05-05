import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';

class SkillService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<Skill>> fetchSkills() async {
    try {
      final snapshot = await _firestore
          .collection('skills')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Skill.fromJson(data);
      }).toList();
    } catch (_) {
      return _mockSkills();
    }
  }

  static Future<bool> postSkill(Skill skill) async {
    try {
      await _firestore.collection('skills').add({
        'title': skill.title,
        'description': skill.description,
        'category': skill.category,
        'postedBy': skill.postedBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Skill>> searchSkills(String query, String category) async {
    final all = await fetchSkills();
    return all.where((skill) {
      final matchesQuery = skill.title.toLowerCase().contains(query.toLowerCase()) ||
          skill.description.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'All' || skill.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

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
