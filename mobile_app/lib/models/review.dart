import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String tutorUid;
  final String reviewerName;
  final String reviewerPhotoUrl;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.tutorUid,
    required this.reviewerName,
    required this.reviewerPhotoUrl,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      tutorUid: data['tutorUid'] ?? '',
      reviewerName: data['reviewerName'] ?? 'Anonymous',
      reviewerPhotoUrl: data['reviewerPhotoUrl'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 5.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tutorUid': tutorUid,
      'reviewerName': reviewerName,
      'reviewerPhotoUrl': reviewerPhotoUrl,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
