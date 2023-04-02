import 'dart:developer';

import 'package:chatgpt_course/constants/api_consts.dart';
import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import 'package:chatgpt_course/providers/auth_provider.dart';
import 'package:chatgpt_course/providers/chats_provider.dart';
import 'package:chatgpt_course/screens/setting_screen.dart';
import 'package:chatgpt_course/widgets/chat_widget.dart';
import 'package:chatgpt_course/widgets/reply_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _isReplingToId;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  @override
  void initState() {
    _initAppConstants();
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode(
      onKey: _handleKeyPress,
    );
    super.initState();
  }

  KeyEventResult _handleKeyPress(FocusNode focusNode, RawKeyEvent event) {
    // handles submit on enter
    if (event.isKeyPressed(LogicalKeyboardKey.enter) && !event.isShiftPressed) {
      // handled means that the event will not propagate
      sendMessageFCT();
      return KeyEventResult.handled;
    }
    // ignore every other keyboard event including SHIFT+ENTER
    return KeyEventResult.ignored;
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
    final maxTokens =
        await Provider.of<AuthProvider>(context, listen: false).getMaxToken();

    ApiConstants.API_KEY = apiKey ?? ApiConstants.API_KEY;
    ApiConstants.MAX_TOKENS = maxTokens ?? ApiConstants.MAX_TOKENS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.chatnobg),
        ),
        title: const Text("Personified"),
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
          // IconButton(
          //   onPressed: () async {
          //     await Services.showModalSheet(context: context);
          //   },
          //   icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          // ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child:
                  Consumer<ChatProvider>(builder: (context, chatProvider, wi) {
                return ListView.builder(
                  controller: _listScrollController,
                  reverse: true,
                  itemCount: chatProvider.getChatList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final chatList = chatProvider.getChatList.reversed.toList();
                    String _repliedToText = chatList[index].repliedToId != null
                        ? chatList
                            .firstWhere((chat) =>
                                chat.id == chatList[index].repliedToId)
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

                          setState(() {
                            _isReplingToId = chatList[index].id;
                          });
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
                        msg: chatList[index].msg,
                        chatIndex: chatList[index].chatIndex,
                        repliedToMessage: _repliedToText,
                        shouldAnimate: chatList.length - 1 == index,
                      ),
                      // Other chat bubble properties
                    );
                  },
                );
              }),
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
            if (_isReplingToId != null) ...[
              ReplyMessageWidget(
                message: Provider.of<ChatProvider>(context, listen: false)
                    .chatList
                    .firstWhere(
                      (chat) => chat.id == _isReplingToId,
                    ),
                onCancelReply: () {
                  setState(() {
                    _isReplingToId = null;
                  });
                },
              ),
              const SizedBox(
                height: 5,
              ),
            ],
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
                          await sendMessageFCT();
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "How can I help you",
                            hintStyle: TextStyle(color: Colors.grey)),
                        maxLines: 4,
                        minLines: 1,
                        onFieldSubmitted: (val) async {
                          await sendMessageFCT();
                        },
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    Consumer<ChatProvider>(
                        builder: (context, chatProvider, wii) {
                      return IconButton(
                          onPressed: () async {
                            if (chatProvider.getOnGoingStream?.isPaused ??
                                true) {
                              await sendMessageFCT();
                            } else {
                              _stopGeneratingMessages();
                            }
                          },
                          icon: Icon(
                            chatProvider.getOnGoingStream?.isPaused ?? true
                                ? Icons.send
                                : Icons.stop,
                            color: Colors.white,
                          ));
                    })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future scrollListToEND() async {
    return await _listScrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT() async {
    final ModelsProvider modelsProvider =
        Provider.of<ModelsProvider>(context, listen: false);
    final ChatProvider chatProvider =
        Provider.of<ChatProvider>(context, listen: false);
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
      //first scroll to the end of the list
      await scrollListToEND();
      ChatModel _newChatMessage = ChatModel(
          id: Uuid().v4(),
          // just for testing adding all the previous messages to the reply to id
          repliedToId: _isReplingToId,
          msg: msg,
          chatIndex: 0);

      chatProvider.addUserMessage(chatMessage: _newChatMessage);

      setState(() {
        _isReplingToId = null;
      });
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
        _isTyping = false;
      });
    }
  }

  void _stopGeneratingMessages() {
    Provider.of<ChatProvider>(context, listen: false).closeStream();
  }
}
