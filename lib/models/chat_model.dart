import 'package:uuid/uuid.dart';

class ChatModel {
  final String id;
  final String? repliedToId;
  String msg;
  final int chatIndex;

  ChatModel(
      {required this.id,
      this.repliedToId,
      required this.msg,
      required this.chatIndex});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: Uuid().v4(),
        msg: json["msg"],
        chatIndex: json["chatIndex"],
      );
}
