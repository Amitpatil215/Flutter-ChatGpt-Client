import 'package:chatgpt_course/services/shared_pref_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  late SharedPreferences _prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _isLoading = true;
    });
    
    final apiKey = SharedPrefService().getValue('api_key');
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    await SharedPrefService().setValue('api_key', _apiKeyController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'API Key',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your API key',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _saveApiKey,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey[900],
                      textStyle: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
