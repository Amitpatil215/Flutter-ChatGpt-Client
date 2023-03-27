import 'package:chatgpt_course/services/shared_pref_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _apiKey;

  Future<String?> getApiKey() async {
    if (_apiKey != null) return _apiKey;
    return _apiKey = await SharedPrefService().getValue("api_key");
  }
}
