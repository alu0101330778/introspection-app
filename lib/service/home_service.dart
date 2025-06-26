import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchLastSentenceByUser({
  required String baseUrl,
  required String userId,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/users/last?id=$userId');
  final response = await http.get(uri, headers: headers);
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}

Future<String?> fetchRandomImageUrl({
  required String baseUrl,
  required Map<String, String> headers,
}) async {
  final response = await http.get(Uri.parse('$baseUrl/random/'), headers: headers);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['url'] as String?;
  }
  return null;
}
