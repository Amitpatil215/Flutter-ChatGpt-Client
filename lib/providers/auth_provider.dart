import 'package:chatgpt_course/services/shared_pref_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _apiKey;
  int? _maxToken;

  Future<String?> getApiKey() async {
    if (_apiKey != null) return _apiKey;
    return _apiKey = await SharedPrefService().getValue("api_key");
  }
  Future<int?> getMaxToken() async {
    if (_maxToken != null) return _maxToken;
    return _maxToken = await SharedPrefService().getValue("token_count");
  }
}
