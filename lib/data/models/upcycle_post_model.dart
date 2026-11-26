import 'profile_model.dart';

class UpcyclePostModel {
  final String id;
  final String authorId;
  final String title;
  final String contentMaterials;
  final String contentSteps;
  final String coverImageUrl;
  final int likesCount;
  final DateTime createdAt;
  final ProfileModel? author;
  final bool isLikedByMe;

  UpcyclePostModel({
    required this.id,
    required this.authorId,
    required this.title,
    required this.contentMaterials,
    required this.contentSteps,
    required this.coverImageUrl,
    this.likesCount = 0,
    required this.createdAt,
    this.author,
    this.isLikedByMe = false,
  });

  factory UpcyclePostModel.fromJson(Map<String, dynamic> json, {bool isLiked = false}) {
    ProfileModel? user;
    if (json['profiles'] != null && json['profiles'] is Map) {
      user = ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return UpcyclePostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      contentMaterials: json['content_materials'] as String? ?? '',
      contentSteps: json['content_steps'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      author: user,
      isLikedByMe: isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author_id': authorId,
      'title': title,
      'content_materials': contentMaterials,
      'content_steps': contentSteps,
      'cover_image_url': coverImageUrl,
    };
  }
}
