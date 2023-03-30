import 'package:chatgpt_course/models/chat_model.dart';
import 'package:flutter/material.dart';

class ReplyMessageWidget extends StatelessWidget {
  final ChatModel message;
  final VoidCallback onCancelReply;

  const ReplyMessageWidget({
    required this.message,
    required this.onCancelReply,
  }) : super();

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                color: Colors.green,
                width: 4,
              ),
              const SizedBox(width: 8),
              Expanded(child: buildReplyMessage()),
            ],
          ),
        ),
      );

  Widget buildReplyMessage() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${message.chatIndex == 0 ? 'You' : 'Assistant'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
                onTap: onCancelReply,
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.msg,
            maxLines: 3,
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      );
}
