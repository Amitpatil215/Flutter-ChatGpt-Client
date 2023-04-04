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
        id: json["id"],
        repliedToId: json["repliedToId"],
        msg: json["msg"],
        chatIndex: json["chatIndex"],
      );

  static Map<String, dynamic> toJson(ChatModel chat) => {
        "id": chat.id,
        "repliedToId": chat.repliedToId,
        "msg": chat.msg,
        "chatIndex": chat.chatIndex,
      };
}
