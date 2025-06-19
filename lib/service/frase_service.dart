import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchFraseByUser({
  required String baseUrl,
  required String userId,
  required List<String> emociones,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/sentences/getByUser');
  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode({'userId': userId, 'emotions': emociones}),
  );
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}

Future<Map<String, dynamic>> addFavoriteSentence({
  required String baseUrl,
  required String userId,
  required String sentenceId,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/users/favorite');
  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode({'userId': userId, 'sentenceId': sentenceId}),
  );
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}
