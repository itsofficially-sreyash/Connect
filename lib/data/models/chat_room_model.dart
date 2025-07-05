import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final Timestamp? lastMessageTime;
  final Map<String, Timestamp>? lastReadTime;
  final Map<String, String>? participantsName;
  final bool isTyping;
  final String? isTypingUserId;
  final bool isCallActive;

  ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    Map<String, Timestamp>? lastReadTime,
    Map<String, String>? participantsName,
    this.isTyping = false,
    this.isTypingUserId,
    this.isCallActive = false,
  }) : lastReadTime = lastReadTime ?? {},
       participantsName = participantsName ?? {};

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data["participants"]),
      lastMessage: data["lastMessage"],
      lastMessageSenderId: data["lastMessageSenderId"],
      lastMessageTime: data["lastMessageTime"],
      lastReadTime: Map<String, Timestamp>.from(data["lastReadTime"]?? {}),
      participantsName: Map<String, String>.from(data["participantsName"]?? {}),
      isTyping: data["isTyping"]?? false,
      isTypingUserId: data["isTypingUserId"],
      isCallActive: data["isCallActive"]?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "participants": participants,
      "lastMessage": lastMessage,
      "lastMessageSenderId": lastMessageSenderId,
      "lastReadTime": lastReadTime,
      "participantsName": participantsName,
      "isTyping": isTyping,
      "isTypingUserId": isTypingUserId,
      "isCallActive": isCallActive,
    };
  }
}
