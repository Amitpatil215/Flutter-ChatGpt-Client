// ignore: unused_import
import 'package:chatgpt_course/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  // List<ChatModel> chatList = [...dummyChatListData];
  ChatModel _systemMessage = ChatModel(
      id: Uuid().v4(),
      msg:
          "Act as a you are multi talented personal chat bot for helping me in coding, copywriting and in general life. Avoid telling me you are a AI bot, I know it already personify yourself as humanoid bot. Current date and time: ${DateTime.now()}",
      chatIndex: 3);

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
    // add system message
    _relatedMessageList.insert(0, _systemMessage);
    // make a request to the API
    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      //? Code for non stream response
      /* chatList.addAll(await ApiService.sendMessageGPT(
        relatedMessageList: _relatedMessageList,
        modelId: chosenModelId,
      )); */

      //? Code for streamed response
      chatList.add(ChatModel(
        id: Uuid().v4(),
        repliedToId: chatList.last.id,
        msg: "",
        chatIndex: 1,
      ));
      ApiService.sendMessageStream(
        relatedMessageList: _relatedMessageList,
        modelId: chosenModelId,
      ).listen((event) {
        chatList.last.msg += event;
        notifyListeners();
      });
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
