import 'package:chatgpt_course/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  // List<ChatModel> chatList = [];
  List<ChatModel> chatList = [...dummyChatListData];

  /// used to get list of messages related to the current messageS
  /// typically replied in the chat
  List<ChatModel> _relatedMessageList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required ChatModel chatMessage}) {
    chatList.add(chatMessage);
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required ChatModel chatMessage, required String chosenModelId}) async {
    _relatedMessageList.clear();
    _getRelatedMessages(chatMessage: chatMessage);
    _relatedMessageList = _relatedMessageList.reversed.toList();

    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        relatedMessageList: _relatedMessageList,
        modelId: chosenModelId,
      ));
    } else {
      chatList.addAll(await ApiService.sendMessage(
        message: chatMessage.msg,
        modelId: chosenModelId,
      ));
    }
    notifyListeners();
  }

  void _getRelatedMessages({
    required ChatModel chatMessage,
  }) {
    _relatedMessageList.add(chatMessage);
    if (chatMessage.repliedToId != null) {
      _getRelatedMessages(
          chatMessage: chatList.firstWhere(
        (chat) => chat.id == chatMessage.repliedToId,
      ));
    }
  }
}
