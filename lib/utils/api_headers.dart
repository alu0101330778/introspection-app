import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, String>> getApiHeaders() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final apiKey = dotenv.env['API_KEY'];

  if (token != null && token.isNotEmpty) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  } else if (apiKey != null && apiKey.isNotEmpty) {
    return {'x-api-key': apiKey, 'Content-Type': 'application/json'};
  } else {
    return {'Content-Type': 'application/json'};
  }
}
