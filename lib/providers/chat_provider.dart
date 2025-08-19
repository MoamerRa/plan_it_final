import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../services/firestore_service.dart';

class ChatProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<ChatMessage>>? _messageStream;
  // Add the missing declaration for the chat room stream
  Stream<List<ChatRoom>>? _chatRoomStream;
  // ===============================================

  Stream<List<ChatMessage>>? get messageStream => _messageStream;
  Stream<List<ChatRoom>>? get chatRoomStream => _chatRoomStream;

  void getMessages(String chatRoomId) {
    _messageStream = _firestoreService.getChatMessages(chatRoomId);
    notifyListeners();
  }

  void getChatRooms(String userId) {
    _chatRoomStream = _firestoreService.getChatRooms(userId);
    notifyListeners();
  }

  Future<void> sendMessage(
      String chatRoomId, String text, String senderId) async {
    await _firestoreService.sendMessage(chatRoomId, text, senderId);
  }

  Future<String> getOrCreateChatRoom(String userId, String vendorId) async {
    return await _firestoreService.getOrCreateChatRoom(userId, vendorId);
  }
}
