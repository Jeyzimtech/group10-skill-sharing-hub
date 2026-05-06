import 'package:cloud_firestore/cloud_firestore.dart';

class Skill {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String postedBy;
  final String? imageUrl;
  final String? posterPhotoUrl;
  final DateTime createdAt;

  Skill({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.postedBy,
    required this.createdAt,
    this.imageUrl,
    this.posterPhotoUrl,
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
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      postedBy: json['postedBy'] ?? json['posted_by'] ?? '',
      imageUrl: json['imageUrl'],
      posterPhotoUrl: json['posterPhotoUrl'],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'postedBy': postedBy,
      'imageUrl': imageUrl,
      'posterPhotoUrl': posterPhotoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
