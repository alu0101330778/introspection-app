import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> postUserEmotions({
  required String baseUrl,
  required String userId,
  required List<String> emociones,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/users/emotions');
  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode({'userId': userId, 'emotions': emociones}),
  );
  return response.statusCode == 200;
}
