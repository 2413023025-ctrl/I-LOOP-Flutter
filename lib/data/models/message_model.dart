import 'profile_model.dart';

class ChatRoomModel {
  final String id;
  final String? itemId;
  final String userOne;
  final String userTwo;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final ProfileModel? otherUser;

  ChatRoomModel({
    required this.id,
    this.itemId,
    required this.userOne,
    required this.userTwo,
    this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
    this.otherUser,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    ProfileModel? other;
    if (json['user_one_profile'] != null && json['user_one'] != currentUserId) {
      other = ProfileModel.fromJson(json['user_one_profile'] as Map<String, dynamic>);
    } else if (json['user_two_profile'] != null && json['user_two'] != currentUserId) {
      other = ProfileModel.fromJson(json['user_two_profile'] as Map<String, dynamic>);
    }

    return ChatRoomModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String?,
      userOne: json['user_one'] as String,
      userTwo: json['user_two'] as String,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      otherUser: other,
    );
  }
}

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
    };
  }
}
