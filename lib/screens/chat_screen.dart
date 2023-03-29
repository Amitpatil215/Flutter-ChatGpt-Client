import 'dart:developer';

import 'package:chatgpt_course/constants/api_consts.dart';
import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import 'package:chatgpt_course/providers/auth_provider.dart';
import 'package:chatgpt_course/providers/chats_provider.dart';
import 'package:chatgpt_course/screens/setting_screen.dart';
import 'package:chatgpt_course/services/services.dart';
import 'package:chatgpt_course/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/models_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/text_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  @override
  void initState() {
    _initAppConstants();
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future _initAppConstants() async {
    final apiKey =
        await Provider.of<AuthProvider>(context, listen: false).getApiKey();
    ApiConstants.API_KEY = apiKey ?? "";
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.chatnobg),
        ),
        title: const Text("ChatGPT"),
        actions: [
          IconButton(
            onPressed: () async {
              //navigate to SettingsScreen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const SettingsScreen();
              }));
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (BuildContext context, int index) {
                  String _repliedToText =
                      chatProvider.getChatList[index].repliedToId != null
                          ? chatProvider.getChatList
                              .firstWhere((chat) =>
                                  chat.id ==
                                  chatProvider.getChatList[index].repliedToId)
                              .msg
                          : "";
                  return Dismissible(
                    key: Key(Uuid().v4()),
                    direction: DismissDirection.startToEnd,
                    dismissThresholds: {
                      DismissDirection.startToEnd: 0.1,
                    },
                    onUpdate: (DismissUpdateDetails details) {
                      if (details.reached && !details.previousReached) {
                        log("Replying to message");
                      }
                    },
                    confirmDismiss: (direction) {
                      // do not actually dismiss the widget
                      return Future.value(false);
                    },
                    background: Container(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.reply_outlined, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    child: ChatWidget(
                      msg: chatProvider.getChatList[index].msg,
                      chatIndex: chatProvider.getChatList[index].chatIndex,
                      repliedToMessage: _repliedToText,
                      shouldAnimate:
                          chatProvider.getChatList.length - 1 == index,
                    ),
                    // Other chat bubble properties
                  );
                },
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        controller: textEditingController,
                        onSaved: (value) async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;

        textEditingController.clear();
        focusNode.unfocus();
      });
      ChatModel _newChatMessage = ChatModel(
          id: Uuid().v4(),
          // just for testing adding all the previous messages to the reply to id
          repliedToId: Provider.of<ChatProvider>(context, listen: false)
                      .chatList
                      .length !=
                  0
              ? Provider.of<ChatProvider>(context, listen: false)
                  .chatList
                  .last
                  .id
              : null,
          msg: msg,
          chatIndex: 0);

      chatProvider.addUserMessage(chatMessage: _newChatMessage);

      await chatProvider.sendMessageAndGetAnswers(
          chatMessage: _newChatMessage,
          chosenModelId: modelsProvider.getCurrentModel);
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
