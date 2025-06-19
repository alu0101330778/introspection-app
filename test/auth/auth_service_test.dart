import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:app_libros/service/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('AuthService', () {
    const baseUrl = 'http://loquesea:3000';

    group('loginUser', () {
      test('returns token and user info on success', () async {
        final client = MockClient();
        const email = 'juan@email.com';
        const password = '123456';
        final responseBody = {
          'token': 'fake-token',
          'userId': 'user123',
          'username': 'Juan',
        };

        when(
          client.post(
            Uri.parse('$baseUrl/auth/login'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            '{"token":"fake-token","userId":"user123","username":"Juan"}',
            200,
          ),
        );

        final result = await loginUser(
          client: client,
          baseUrl: baseUrl,
          email: email,
          password: password,
        );

        expect(result['statusCode'], 200);
        expect(result['body'], responseBody);
      });

      test('returns error message on failure', () async {
        final client = MockClient();
        const email = 'juan@email.com';
        const password = 'wrongpass';

        when(
          client.post(
            Uri.parse('$baseUrl/auth/login'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async =>
              http.Response('{"message":"Credenciales inválidas"}', 401),
        );

        final result = await loginUser(
          client: client,
          baseUrl: baseUrl,
          email: email,
          password: password,
        );

        expect(result['statusCode'], 401);
        expect(result['body']['message'], 'Credenciales inválidas');
      });
    });

    group('registerUser', () {
      test('returns user info on success', () async {
        final client = MockClient();
        const username = 'Juan';
        const email = 'juan@email.com';
        const password = '123456';

        when(
          client.post(
            Uri.parse('$baseUrl/auth/register'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"message":"Usuario registrado"}', 201),
        );

        final result = await registerUser(
          client: client,
          baseUrl: baseUrl,
          username: username,
          email: email,
          password: password,
        );

        expect(result['statusCode'], 201);
        expect(result['body']['message'], 'Usuario registrado');
      });

      test('returns error message on failure', () async {
        final client = MockClient();
        const username = 'Juan';
        const email = 'juan@email.com';
        const password = '123456';

        when(
          client.post(
            Uri.parse('$baseUrl/auth/register'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response('{"message":"Email ya registrado"}', 400),
        );

        final result = await registerUser(
          client: client,
          baseUrl: baseUrl,
          username: username,
          email: email,
          password: password,
        );

        expect(result['statusCode'], 400);
        expect(result['body']['message'], 'Email ya registrado');
      });
    });
  });
}
