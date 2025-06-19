import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:app_libros/service/main_service.dart';

void main() {
  group('main_service', () {
    const baseUrl = 'http://loquesea:3000';

    test('verifyToken returns user data on 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'userId': '123', 'valid': true}), 200);
      });

      final result = await verifyToken(
        baseUrl: baseUrl,
        token: 'testtoken',
        client: mockClient, // <-- Aquí se pasa el mock
      );
      expect(result, isNotNull);
      expect(result!['userId'], '123');
      expect(result['valid'], true);
    });

    test('verifyToken returns null on non-200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final result = await verifyToken(
        baseUrl: baseUrl,
        token: 'badtoken',
        client: mockClient,
      );
      expect(result, isNull);
    });

    test('fetchUserInfo returns user info on 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'id': '123', 'name': 'Test User'}),
          200,
        );
      });

      final result = await fetchUserInfo(
        baseUrl: baseUrl,
        userId: '123',
        client: mockClient,
      );
      expect(result, isNotNull);
      expect(result!['id'], '123');
      expect(result['name'], 'Test User');
    });

    test('fetchUserInfo returns null on non-200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      final result = await fetchUserInfo(
        baseUrl: baseUrl,
        userId: 'notfound',
        client: mockClient,
      );
      expect(result, isNull);
    });
  });
}
