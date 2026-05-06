import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config_keys.dart';

class AIService {
  static const String _apiKey = ConfigKeys.openRouterApiKey;
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'openrouter/owl-alpha';

  static Future<String> getChatResponse(List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://skillhub.nust.edu', // Optional but good for OpenRouter
          'X-Title': 'Funda Mwana AI Tutor',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Sorry, I couldn\'t understand that.';
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return 'I\'m having some technical trouble right now. Please try again later.';
      }
    } catch (e) {
      print('AI Service Error: $e');
      return 'I couldn\'t connect to my brain. Please check your internet connection.';
    }
  }
}
