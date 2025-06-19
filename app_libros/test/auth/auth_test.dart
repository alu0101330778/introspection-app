import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_libros/auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthPage Widget (funcional, sin peticiones)', () {
    testWidgets('Muestra las pestañas de login y registro', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
    });

    testWidgets('Validación de login: campos vacíos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Email inválido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('Validación de login: email inválido', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'noemail',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123456',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('Validación de login: contraseña corta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'test@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('Validación de registro: campos vacíos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      expect(find.text('Nombre requerido'), findsOneWidget);
      expect(find.text('Email inválido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('Validación de registro: email inválido', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Juan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'noemail',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123456',
      );
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('Validación de registro: contraseña corta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'),
        'Juan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'juan@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123',
      );
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('Validación de registro: nombre vacío', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AuthPage()));
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), '');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'),
        'juan@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        '123456',
      );
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();
      expect(find.text('Nombre requerido'), findsOneWidget);
    });

    testWidgets(
      'Cambiar entre pestañas mantiene los datos de los formularios',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: AuthPage()));
        // Login
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Correo'),
          'login@email.com',
        );
        await tester.tap(find.text('Registrarse'));
        await tester.pumpAndSettle();
        // Registro
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre'),
          'Juan',
        );
        await tester.tap(find.text('Iniciar sesión'));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextFormField, 'Correo'), findsOneWidget);
        expect(find.text('login@email.com'), findsOneWidget);
        await tester.tap(find.text('Registrarse'));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextFormField, 'Nombre'), findsOneWidget);
        expect(find.text('Juan'), findsOneWidget);
      },
    );
  });
}
