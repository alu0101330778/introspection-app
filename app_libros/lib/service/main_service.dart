import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> verifyToken({
  required String baseUrl,
  required String token,
  http.Client? client, // <-- Añadido
}) async {
  client ??= http.Client(); // Usa el cliente proporcionado o uno nuevo
  final response = await client.get(
    Uri.parse("$baseUrl/auth/verify"),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}

Future<Map<String, dynamic>?> fetchUserInfo({
  required String baseUrl,
  required String userId,
  http.Client? client, // <-- Añadido
}) async {
  client ??= http.Client();
  final response = await client.get(
    Uri.parse("$baseUrl/users/info?id=$userId"),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return null;
}
