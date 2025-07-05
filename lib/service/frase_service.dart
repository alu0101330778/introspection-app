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

Future<Map<String, dynamic>> fetchFraseByUserFixed({
  required String userId,
  required String baseUrl,
  required List<String> emociones,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/sentences/getByIA');
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
  String? sentenceId,
  String? title,
  required Map<String, String> headers,
}) async {
  if (sentenceId == null && (title == null || title.isEmpty)) {
    return {
      'statusCode': 400,
      'body': {'message': 'Se requiere sentenceId o title'}
    };
  }

  final uri = Uri.parse('$baseUrl/users/favorite');

  final body = {
    'userId': userId,
    if (sentenceId != null) 'sentenceId': sentenceId,
    if (sentenceId == null && title != null) 'title': title,
  };

  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(body),
  );

  return {
    'statusCode': response.statusCode,
    'body': jsonDecode(response.body),
  };
}
