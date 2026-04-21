class ReviewModel {
  final String id;
  final String rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  
  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
  });
}