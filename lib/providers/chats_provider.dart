import 'dart:async';
import 'dart:developer';

// ignore: unused_import
import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/dao/chat_model_dao.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  // List<ChatModel> chatList = [...dummyChatListData];

  ChatModelDao _chatModelDao = ChatModelDao();

  StreamSubscription<String>? _onGoningStreamListner;
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

  // get ongoing stream
  StreamSubscription<String>? get getOnGoingStream {
    return _onGoningStreamListner;
  }

  // get stored messages from dao
  Future<void> getStoredMessages() async {
    chatList = await _chatModelDao.getAllChats();
    notifyListeners();
  }

  void addUserMessage({required ChatModel chatMessage}) async {
    log("Adding user message");
    chatList.add(chatMessage);
    await _chatModelDao.insertChat(chatMessage);
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required ChatModel chatMessage, required String chosenModelId}) async {
    _relatedMessageList.clear();
    _getRelatedMessages(chatMessage: chatMessage);
    _relatedMessageList = _relatedMessageList.reversed.toList();
    // add system message
    log("Adding system promt message");
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
      log("Creating new stream");
      _onGoningStreamListner = ApiService.sendMessageStream(
        relatedMessageList: _relatedMessageList,
        modelId: chosenModelId,
      ).listen((event) {
        chatList.last.msg += event;
        notifyListeners();
      });
      _onGoningStreamListner?.onDone(() async {
        log("Generating response done");
        closeStream();
        await _chatModelDao.insertChat(chatList.last);
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
    log("Getting related messages");
    _relatedMessageList.add(chatMessage);
    if (chatMessage.repliedToId != null) {
      _getRelatedMessages(
          chatMessage: chatList.firstWhere(
        (chat) => chat.id == chatMessage.repliedToId,
      ));
    }
  }

  //close on going stream
  void closeStream() {
    log("Closing stream");
    if (isStreamActive()) {
      _onGoningStreamListner?.cancel();
      _onGoningStreamListner = null;
      notifyListeners();
    }
  }

  //check if stream is active
  bool isStreamActive() {
    if (_onGoningStreamListner == null) return false;
    return !_onGoningStreamListner!.isPaused;
  }
}
