import 'package:chatgpt_course/database/app_database.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import 'package:sembast/sembast.dart';

class ChatModelDao {
  static const String folderName = "chats";
  final _booksFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertChat(ChatModel chat) async {
    await _booksFolder.add(await _db, ChatModel.toJson(chat));
  }

  Future updateChat(ChatModel chat) async {
    final finder = Finder(filter: Filter.byKey(chat.id));
    await _booksFolder.update(await _db, ChatModel.toJson(chat),
        finder: finder);
  }

  Future delete(ChatModel chat) async {
    final finder = Finder(filter: Filter.byKey(chat.chatIndex));
    await _booksFolder.delete(await _db, finder: finder);
  }

  Future<List<ChatModel>> getAllChats() async {
    final recordSnapshot = await _booksFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final books = ChatModel.fromJson(snapshot.value);
      return books;
    }).toList();
  }
}
