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
    return Skill(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      postedBy: json['posted_by'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'posted_by': postedBy,
    };
  }
}