import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchProductos({
  required String baseUrl,
  required Map<String, String> headers,
}) async {
  final uri = Uri.parse('$baseUrl/shop');
  final response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception('Error al cargar productos');
  }
}
