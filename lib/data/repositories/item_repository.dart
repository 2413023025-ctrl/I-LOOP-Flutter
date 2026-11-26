import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';

class ItemRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ItemModel>> getItems({
    ListingType? filterType,
    String? category,
    String? searchQuery,
    String? city,
  }) async {
    var query = _client.from('items').select('''
      *,
      profiles:owner_id (id, full_name, avatar_url, city, campus_or_area, items_saved_count, created_at),
      item_images (image_url, sort_order)
    ''');

    if (filterType != null) {
      query = query.eq('listing_type', filterType.name);
    }
    if (category != null && category != 'Semua') {
      query = query.eq('category', category);
    }
    if (city != null && city != 'Semua') {
      query = query.eq('city', city);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('title', '%${searchQuery.trim()}%');
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((json) => ItemModel.fromJson(json)).toList();
  }

  Future<List<ItemModel>> getMyItems({String? userId}) async {
    final uid = userId ?? _client.auth.currentUser?.id;
    if (uid == null) return [];

    final data = await _client.from('items').select('''
      *,
      profiles:owner_id (id, full_name, avatar_url, city, campus_or_area, items_saved_count, created_at),
      item_images (image_url, sort_order)
    ''').eq('owner_id', uid).order('created_at', ascending: false);

    return (data as List).map((json) => ItemModel.fromJson(json)).toList();
  }

  Future<ItemModel?> getItemById(String id) async {
    final data = await _client.from('items').select('''
      *,
      profiles:owner_id (id, full_name, avatar_url, city, campus_or_area, items_saved_count, created_at),
      item_images (image_url, sort_order)
    ''').eq('id', id).maybeSingle();

    if (data == null) return null;
    return ItemModel.fromJson(data);
  }

  Future<String> uploadImage(File file, String pathPrefix) async {
    final bytes = await file.readAsBytes();
    final fileExt = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pathPrefix}.$fileExt';
    final fullPath = 'public/$fileName';

    await _client.storage.from('item-photos').uploadBinary(
          fullPath,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$fileExt'),
        );

    return _client.storage.from('item-photos').getPublicUrl(fullPath);
  }

  Future<ItemModel> createItem({
    required String title,
    required String description,
    required ListingType listingType,
    required double price,
    String? swapWishlist,
    required String category,
    required String condition,
    required String city,
    String? areaNotes,
    required List<String> imageUrls,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Pengguna belum login.');

    final primaryImg = imageUrls.isNotEmpty ? imageUrls.first : null;

    final insertedItem = await _client.from('items').insert({
      'owner_id': user.id,
      'title': title,
      'description': description,
      'listing_type': listingType.name,
      'price': listingType == ListingType.sell ? price : 0.0,
      'swap_wishlist': swapWishlist,
      'category': category,
      'condition': condition,
      'status': 'available',
      'city': city,
      'area_notes': areaNotes,
      'primary_image_url': primaryImg,
    }).select().single();

    final itemId = insertedItem['id'] as String;

    // Masukkan list foto tambahan jika ada
    if (imageUrls.isNotEmpty) {
      final imageRows = imageUrls.asMap().entries.map((entry) {
        return {
          'item_id': itemId,
          'image_url': entry.value,
          'sort_order': entry.key,
        };
      }).toList();

      await _client.from('item_images').insert(imageRows);
    }

    return ItemModel.fromJson(insertedItem);
  }

  Future<void> updateItemStatus(String itemId, ItemStatus status) async {
    await _client.from('items').update({
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', itemId);

    // Jika item selesai terjual/ditukar/diberikan, tambahkan skor eco-impact
    if (status == ItemStatus.completed) {
      final item = await _client.from('items').select('owner_id').eq('id', itemId).single();
      final ownerId = item['owner_id'] as String;

      await _client.rpc('increment_items_saved', params: {'user_id': ownerId});
    }
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from('items').delete().eq('id', itemId);
  }
}
