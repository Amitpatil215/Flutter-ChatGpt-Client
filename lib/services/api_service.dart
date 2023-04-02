import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgpt_course/constants/api_consts.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import 'package:chatgpt_course/models/models_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("${ApiConstants.BASE_URL}/models"),
        headers: {'Authorization': 'Bearer ${ApiConstants.API_KEY}'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp ${value["id"]}");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message using ChatGPT API
  static Future<List<ChatModel>> sendMessageGPT(
      {required List<ChatModel> relatedMessageList,
      required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("${ApiConstants.BASE_URL}/chat/completions"),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.API_KEY}',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": relatedMessageList
                .map((chat) => {
                      "role": chat.chatIndex == 0
                          ? "user"
                          : chat.chatIndex == 1
                              ? "assistant"
                              : "system",
                      "content": chat.msg,
                    })
                .toList(),
            "temperature": 0.5,
            "n": 1,
            "max_tokens": 300,
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            id: Uuid().v4(),
            repliedToId: relatedMessageList.last.id,
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message to ChatGPT and receives the streamed response in chunk
  /// Courtesy : https://github.com/alfianlosari/chatgpt_api_dart/blob/main/lib/src/chatgptclient.dart#L102
  static Stream<String> sendMessageStream(
      {required List<ChatModel> relatedMessageList,
      required String modelId}) async* {
    final request = http.Request(
        "POST", Uri.parse("${ApiConstants.BASE_URL}/chat/completions"))
      ..headers.addAll({
        'Authorization': 'Bearer ${ApiConstants.API_KEY}',
        "Content-Type": "application/json"
      });
    request.body = jsonEncode(
      {
        "model": modelId,
        "messages": relatedMessageList
            .map((chat) => {
                  "role": chat.chatIndex == 0
                      ? "user"
                      : chat.chatIndex == 1
                          ? "assistant"
                          : "system",
                  "content": chat.msg,
                })
            .toList(),
        "temperature": 0.5,
        "n": 1,
        "max_tokens": 300,
        "stream": true,
      },
    );

    final response = await request.send();
    final statusCode = response.statusCode;
    final byteStream = response.stream;

    if (!(statusCode >= 200 && statusCode < 300)) {
      var error = "";
      await for (final byte in byteStream) {
        final decoded = utf8.decode(byte).trim();
        final map = jsonDecode(decoded) as Map;
        final errorMessage = map["error"]["message"] as String;
        error += errorMessage;
      }
      throw Exception(
          "($statusCode) ${error.isEmpty ? "Bad Response" : error}");
    }

    var responseText = "";
    await for (final byte in byteStream) {
      var decoded = utf8.decode(byte);
      final strings = decoded.split("data: ");
      for (final string in strings) {
        final trimmedString = string.trim();
        if (trimmedString.isNotEmpty && !trimmedString.endsWith("[DONE]")) {
          final map = jsonDecode(trimmedString) as Map;
          final choices = map["choices"] as List;

          final delta = choices[0]["delta"];
          if (delta["content"] != null) {
            final content = delta["content"] as String;
            responseText += content;
            print("content- > $content");
            yield content;
          }
        }
      }
    }

    if (responseText.isNotEmpty) {
      // _appendToHistoryList(text, responseText);
    }
  }

  // Send Message fct
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("${ApiConstants.BASE_URL}/completions"),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.API_KEY}',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "prompt": message,
            "max_tokens": ApiConstants.max_tokens,
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            id: Uuid().v4(),
            msg: jsonResponse["choices"][index]["text"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
