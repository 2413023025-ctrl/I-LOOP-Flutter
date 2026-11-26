import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repo = ChatRepository();

  List<ChatRoomModel> _rooms = [];
  bool _isLoading = false;

  List<ChatRoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;

  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      _rooms = await _repo.getMyChatRooms();
    } catch (e) {
      debugPrint('Error fetching chat rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ChatRoomModel> getOrCreateRoom({
    required String targetUserId,
    String? itemId,
  }) async {
    final room = await _repo.getOrCreateChatRoom(
      targetUserId: targetUserId,
      itemId: itemId,
    );
    await fetchRooms();
    return room;
  }

  Stream<List<MessageModel>> streamMessages(String roomId) {
    return _repo.streamMessages(roomId);
  }

  Future<void> sendMessage(String roomId, String text) async {
    await _repo.sendMessage(chatRoomId: roomId, content: text);
  }
}
