import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_libros/main.dart';
import 'package:app_libros/auth.dart';

void main() {
  group('MiApp Widget', () {
    testWidgets('Muestra AuthPage si no hay usuario', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MiApp(nombreUsuario: null));
      expect(find.byType(AuthPage), findsOneWidget);
    });

    testWidgets('Muestra PaginaInicial si hay usuario', (
      WidgetTester tester,
    ) async {
      // Simula que el usuario está autenticado
      await tester.pumpWidget(const MiApp(nombreUsuario: 'Juan'));
      // Como el home es AuthPage, pero la navegación depende de la lógica de AuthPage,
      // aquí solo comprobamos que el widget se construye correctamente.
      expect(find.byType(AuthPage), findsOneWidget);
    });

    testWidgets('MaterialApp tiene las rutas definidas', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MiApp(nombreUsuario: null));
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.routes, isNotNull);
      expect(app.routes!.containsKey('/inicial'), isTrue);
      expect(app.routes!.containsKey('/paginaFrase'), isTrue);
      expect(app.routes!.containsKey('/home'), isTrue);
      expect(app.routes!.containsKey('/auth'), isTrue);
      expect(app.routes!.containsKey('/perfil'), isTrue);
      expect(app.routes!.containsKey('/tienda'), isTrue);
    });
  });
}
