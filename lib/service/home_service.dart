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
