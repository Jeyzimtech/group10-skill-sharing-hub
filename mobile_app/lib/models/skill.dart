import 'package:cloud_firestore/cloud_firestore.dart';

class Skill {
  final String id;
  final String title;
  final String description;
  final String category;
  final String postedBy;
  final DateTime createdAt;

  Skill({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.postedBy,
    required this.createdAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    final timestamp = json['createdAt'];
    DateTime createdAt;

    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is String) {
      createdAt = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Skill(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      postedBy: json['postedBy'] ?? json['posted_by'] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'postedBy': postedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
