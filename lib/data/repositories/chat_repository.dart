import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ChatRoomModel>> getMyChatRooms() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client.from('chat_rooms').select('''
      *,
      user_one_profile:user_one (id, full_name, avatar_url, city, items_saved_count, created_at),
      user_two_profile:user_two (id, full_name, avatar_url, city, items_saved_count, created_at)
    ''').or('user_one.eq.${user.id},user_two.eq.${user.id}').order('last_message_at', ascending: false);

    return (data as List)
        .map((json) => ChatRoomModel.fromJson(json, user.id))
        .toList();
  }

  Future<ChatRoomModel> getOrCreateChatRoom({
    required String targetUserId,
    String? itemId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Silakan login terlebih dahulu.');

    // Cek apakah chat room sudah pernah dibuat
    var query = _client.from('chat_rooms').select('''
      *,
      user_one_profile:user_one (id, full_name, avatar_url, city, items_saved_count, created_at),
      user_two_profile:user_two (id, full_name, avatar_url, city, items_saved_count, created_at)
    ''').or('and(user_one.eq.${user.id},user_two.eq.$targetUserId),and(user_one.eq.$targetUserId,user_two.eq.${user.id})');

    if (itemId != null) {
      query = query.eq('item_id', itemId);
    }

    final existing = await query.maybeSingle();

    if (existing != null) {
      return ChatRoomModel.fromJson(existing, user.id);
    }

    // Jika belum ada, buat baru
    final newRoom = await _client.from('chat_rooms').insert({
      'user_one': user.id,
      'user_two': targetUserId,
      'item_id': itemId,
      'last_message': 'Memulai obrolan',
      'last_message_at': DateTime.now().toIso8601String(),
    }).select('''
      *,
      user_one_profile:user_one (id, full_name, avatar_url, city, items_saved_count, created_at),
      user_two_profile:user_two (id, full_name, avatar_url, city, items_saved_count, created_at)
    ''').single();

    return ChatRoomModel.fromJson(newRoom, user.id);
  }

  Stream<List<MessageModel>> streamMessages(String chatRoomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: true)
        .map((list) => list.map((json) => MessageModel.fromJson(json)).toList());
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('messages').insert({
      'chat_room_id': chatRoomId,
      'sender_id': user.id,
      'content': content,
      'is_read': false,
    });

    // Update last message di chat room
    await _client.from('chat_rooms').update({
      'last_message': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', chatRoomId);
  }
}
