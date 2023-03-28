import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/services/assets_manager.dart';
import 'package:flutter/material.dart';

import 'text_widget.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget(
      {super.key,
      required this.msg,
      required this.chatIndex,
      this.shouldAnimate = false});

  final String msg;
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
          // if (!isMe)
          //   Padding(
          //     padding: EdgeInsets.only(right: 8.0),
          //     child: CircleAvatar(
          //       child: Text('Other'),
          //     ),
          //   ),
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
                  // Got an image this widget will take over

                  chatIndex == 0
                      ? TextWidget(
                          label: msg, fontWeight: FontWeight.w500, fontSize: 16)
                      : shouldAnimate
                          ? DefaultTextStyle(
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                              child: AnimatedTextKit(
                                  isRepeatingAnimation: false,
                                  repeatForever: false,
                                  displayFullTextOnTap: true,
                                  totalRepeatCount: 1,
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      msg.trim(),
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                    ),
                                  ]),
                            )
                          : Text(
                              msg.trim(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  // fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                ],
              ),
            ),
          ),
          // if (isMe)
          //   Padding(
          //     padding: EdgeInsets.only(left: 8.0),
          //     child: CircleAvatar(
          //       child: Text('Me'),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
