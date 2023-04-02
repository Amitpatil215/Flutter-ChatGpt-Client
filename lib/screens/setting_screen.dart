import 'package:chatgpt_course/constants/api_consts.dart';
import 'package:chatgpt_course/services/shared_pref_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _tokenCountController = TextEditingController();

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
    final tokenCount = SharedPrefService().getValue('token_count');
    if (apiKey != null) {
      _apiKeyController.text = apiKey;
    }
    _tokenCountController.text = (tokenCount ?? ApiConstants.MAX_TOKENS).toString();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    await SharedPrefService().setValue('api_key', _apiKeyController.text);
    ApiConstants.API_KEY = _apiKeyController.text;
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved')),
    );
  }

  Future<void> _saveTokenCount() async {
    await SharedPrefService()
        .setValue('token_count', int.parse(_tokenCountController.text));
    ApiConstants.MAX_TOKENS = int.parse(_tokenCountController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token count saved')),
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
                  const Text(
                    'Token Count',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _tokenCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter the number of tokens',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _saveApiKey();
                      _saveTokenCount();
                    },
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
