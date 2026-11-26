import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/upcycle_post_model.dart';
import '../data/repositories/upcycle_repository.dart';

class UpcycleProvider extends ChangeNotifier {
  final UpcycleRepository _repo = UpcycleRepository();

  List<UpcyclePostModel> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UpcyclePostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _repo.getUpcyclePosts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String title,
    required String materials,
    required String steps,
    required File coverImage,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final coverUrl = await _repo.uploadCoverImage(coverImage);
      await _repo.createPost(
        title: title,
        contentMaterials: materials,
        contentSteps: steps,
        coverImageUrl: coverUrl,
      );
      await fetchPosts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId, bool currentLiked) async {
    final newLiked = await _repo.toggleLike(postId, currentLiked);
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final old = _posts[index];
      _posts[index] = UpcyclePostModel(
        id: old.id,
        authorId: old.authorId,
        title: old.title,
        contentMaterials: old.contentMaterials,
        contentSteps: old.contentSteps,
        coverImageUrl: old.coverImageUrl,
        likesCount: newLiked ? old.likesCount + 1 : old.likesCount - 1,
        createdAt: old.createdAt,
        author: old.author,
        isLikedByMe: newLiked,
      );
      notifyListeners();
    }
  }
}
