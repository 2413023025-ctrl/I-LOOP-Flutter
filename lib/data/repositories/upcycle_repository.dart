import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/upcycle_post_model.dart';

class UpcycleRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<UpcyclePostModel>> getUpcyclePosts() async {
    final user = _client.auth.currentUser;

    final data = await _client.from('upcycle_posts').select('''
      *,
      profiles:author_id (id, full_name, avatar_url, city, items_saved_count, created_at)
    ''').order('created_at', ascending: false);

    List<String> myLikedPostIds = [];
    if (user != null) {
      final likesData = await _client
          .from('upcycle_likes')
          .select('post_id')
          .eq('user_id', user.id);
      myLikedPostIds = (likesData as List).map((e) => e['post_id'] as String).toList();
    }

    return (data as List).map((json) {
      final postId = json['id'] as String;
      return UpcyclePostModel.fromJson(
        json,
        isLiked: myLikedPostIds.contains(postId),
      );
    }).toList();
  }

  Future<String> uploadCoverImage(File file) async {
    final bytes = await file.readAsBytes();
    final fileExt = file.path.split('.').last;
    final fileName = 'upcycle_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final fullPath = 'public/$fileName';

    await _client.storage.from('upcycle-photos').uploadBinary(
          fullPath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );

    return _client.storage.from('upcycle-photos').getPublicUrl(fullPath);
  }

  Future<void> createPost({
    required String title,
    required String contentMaterials,
    required String contentSteps,
    required String coverImageUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');

    await _client.from('upcycle_posts').insert({
      'author_id': user.id,
      'title': title,
      'content_materials': contentMaterials,
      'content_steps': contentSteps,
      'cover_image_url': coverImageUrl,
    });
  }

  Future<bool> toggleLike(String postId, bool currentLiked) async {
    final user = _client.auth.currentUser;
    if (user == null) return currentLiked;

    if (currentLiked) {
      await _client.from('upcycle_likes').delete().match({
        'post_id': postId,
        'user_id': user.id,
      });
      await _client.rpc('decrement_upcycle_likes', params: {'target_post_id': postId});
      return false;
    } else {
      await _client.from('upcycle_likes').insert({
        'post_id': postId,
        'user_id': user.id,
      });
      await _client.rpc('increment_upcycle_likes', params: {'target_post_id': postId});
      return true;
    }
  }
}
