import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchUserInfo({
  required String baseUrl,
  required String userId,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/users/info?id=$userId');
  final response = await http.get(uri, headers: headers);
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}

Future<Map<String, dynamic>> removeFavoriteSentence({
  required String baseUrl,
  required String userId,
  required String sentenceId,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/users/favorite');
  final response = await http.put(
    uri,
    headers: headers,
    body: jsonEncode({'userId': userId, 'sentenceId': sentenceId}),
  );
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}

Future<Map<String, dynamic>> updateUserSettings({
  required String baseUrl,
  required String userId,
  required bool enableEmotions,
  required bool randomReflexion,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/users/settings');
  final response = await http.patch(
    uri,
    headers: headers,
    body: jsonEncode({
      'userId': userId,
      'enableEmotions': enableEmotions,
      'randomReflexion': randomReflexion,
    }),
  );
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}
