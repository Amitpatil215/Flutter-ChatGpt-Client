import 'package:flutter/material.dart';
import 'package:chatgpt_course/models/chat_model.dart';

Color scaffoldBackgroundColor = const Color(0xFF343541);
Color cardColor = const Color(0xFF444654);

List<ChatModel> dummyChatListData = [
  ChatModel(
    id: '1',
    repliedToId: null,
    msg: 'Hello, how are you?',
    chatIndex: 0,
  ),
  ChatModel(
    id: '2',
    repliedToId: null,
    msg: 'I\'m good, thanks! How about you?',
    chatIndex: 1,
  ),
  ChatModel(
    id: '3',
    repliedToId: '1',
    msg: 'I\'m doing well, thanks for asking.',
    chatIndex: 0,
  ),
  ChatModel(
    id: '4',
    repliedToId: null,
    msg:
        "Sure, here's a boilerplate code for a Flutter app:\n\n```dart\nimport 'package:flutter/material.dart';\n\nvoid main() {\n  runApp(MyApp());\n}\n\nclass MyApp extends StatelessWidget {\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      title: 'My App',\n      theme: ThemeData(\n        primarySwatch: Colors.blue,\n        visualDensity: VisualDensity.adaptivePlatformDensity,\n      ),\n      home: MyHomePage(),\n    );\n  }\n}\n\nclass MyHomePage extends StatefulWidget {\n  @override\n  _MyHomePageState createState() => _MyHomePageState();\n}\n\nclass _MyHomePageState extends State<MyHomePage> {\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(\n        title: Text('My App'),\n      ),\n      body: Center(\n        child: Text(\n          'Hello, world!',\n          style: TextStyle(fontSize: 24),\n        ),\n      ),\n    );\n  }\n}\n```\n\nThis code sets up a basic Flutter app with a `MaterialApp` widget as the root of the widget tree, a `MyHomePage` widget as the home screen, and an `AppBar` with a title. The `MyHomePage` widget is a `StatefulWidget`, which means it has mutable state that can change over time. In this case, the state is not used, and the widget simply displays a centered text widget.",
    chatIndex: 1,
  ),
  ChatModel(
    id: '5',
    repliedToId: '4',
    msg: 'No, I missed it. Who won?',
    chatIndex: 0,
  ),
  ChatModel(
    id: '6',
    repliedToId: null,
    msg: 'I have some exciting news to share!',
    chatIndex: 1,
  ),
  ChatModel(
    id: '7',
    repliedToId: null,
    msg: 'What is it?',
    chatIndex: 0,
  ),
  ChatModel(
    id: '8',
    repliedToId: '6',
    msg: 'I got accepted into my dream college!',
    chatIndex: 1,
  ),
  ChatModel(
    id: '9',
    repliedToId: null,
    msg: 'That\'s amazing, congratulations!',
    chatIndex: 0,
  ),
];

// List<DropdownMenuItem<String>>? get getModelsItem {
//   List<DropdownMenuItem<String>>? modelsItems =
//       List<DropdownMenuItem<String>>.generate(
//           models.length,
//           (index) => DropdownMenuItem(
//               value: models[index],
//               child: TextWidget(
//                 label: models[index],
//                 fontSize: 15,
//               )));
//   return modelsItems;
// }

// final chatMessages = [
//   {
//     "msg": "Hello who are you?",
//     "chatIndex": 0,
//   },
//   {
//     "msg":
//         "Hello, I am ChatGPT, a large language model developed by OpenAI. I am here to assist you with any information or questions you may have. How can I help you today?",
//     "chatIndex": 1,
//   },
//   {
//     "msg": "What is flutter?",
//     "chatIndex": 0,
//   },
//   {
//     "msg":
//         "Flutter is an open-source mobile application development framework created by Google. It is used to develop applications for Android, iOS, Linux, Mac, Windows, and the web. Flutter uses the Dart programming language and allows for the creation of high-performance, visually attractive, and responsive apps. It also has a growing and supportive community, and offers many customizable widgets for building beautiful and responsive user interfaces.",
//     "chatIndex": 1,
//   },
//   {
//     "msg": "Okay thanks",
//     "chatIndex": 0,
//   },
//   {
//     "msg":
//         "You're welcome! Let me know if you have any other questions or if there's anything else I can help you with.",
//     "chatIndex": 1,
//   },
// ];
