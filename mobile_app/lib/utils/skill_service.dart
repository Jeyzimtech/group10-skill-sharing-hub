import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';

class SkillService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<Skill>> fetchSkills({String? category, String? query}) async {
    try {
      Query q = _firestore.collection('skills').orderBy('createdAt', descending: true);

      if (category != null && category != 'All') {
        q = q.where('category', isEqualTo: category);
      }

      final snapshot = await q.get();

      List<Skill> skills = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Skill.fromJson(data);
      }).toList();

      if (query != null && query.isNotEmpty) {
        skills = skills.where((s) => 
          s.title.toLowerCase().contains(query.toLowerCase()) || 
          s.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      return skills;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> postSkill(Skill skill) async {
    try {
      await _firestore.collection('skills').add({
        'userId': skill.userId,
        'title': skill.title,
        'description': skill.description,
        'category': skill.category,
        'postedBy': skill.postedBy,
        'imageUrl': skill.imageUrl,
        'posterPhotoUrl': skill.posterPhotoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
