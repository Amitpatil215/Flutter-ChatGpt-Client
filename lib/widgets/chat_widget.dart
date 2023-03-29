import 'package:chatgpt_course/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

import 'text_widget.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required this.msg,
    required this.chatIndex,
    required this.repliedToMessage,
    this.shouldAnimate = false,
  });

  final String msg;
  final String repliedToMessage;
  final int chatIndex;
  final bool shouldAnimate;
  @override
  Widget build(BuildContext context) {
    final isMe = chatIndex == 0;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            !isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                // color: isMe ? Colors.white : Colors.blue[100],
                color: isMe ? cardColor : cardColor,
                borderRadius: BorderRadius.only(
                  topRight: isMe ? Radius.circular(0) : Radius.circular(20),
                  topLeft: isMe ? Radius.circular(20) : Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5),
                    if (isMe)
                      Text(
                        "You",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.deepOrange,
                        ),
                      ),
                    if (!isMe)
                      Text(
                        "Assistant",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                    SizedBox(height: 5),
                    if (repliedToMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black12,
                        ),
                        child: Text(
                          repliedToMessage,
                          maxLines: 2,
                        ),
                      ),
                    if (repliedToMessage.isNotEmpty && chatIndex == 0)
                      SizedBox(height: 5),
                    chatIndex == 0
                        ? TextWidget(
                            label: msg,
                            fontWeight: FontWeight.w500,
                            fontSize: 16)
                        : Column(
                            children: [
                              ...MarkdownGenerator(
                                config: MarkdownConfig(
                                  configs: [
                                    PConfig(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ).buildWidgets(msg.trim())
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
