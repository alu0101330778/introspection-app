import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> loginUser({
  required http.Client client,
  required String baseUrl,
  required String email,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/auth/login');
  final response = await client.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}

Future<Map<String, dynamic>> registerUser({
  required http.Client client,
  required String baseUrl,
  required String username,
  required String email,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/auth/register');
  final response = await client.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    }),
  );
  return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
}
