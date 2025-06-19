import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'inicial.dart';
import 'frase.dart';
import 'home.dart';
import 'auth.dart';
import 'perfil.dart';
import 'tienda.dart';
import 'service/main_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  String? nombreUsuario;
  String? userId;

  if (token != null) {
    try {
      final baseUrl = dotenv.env['API_BASE_URL']!;
      final verifyData = await verifyToken(baseUrl: baseUrl, token: token);

      if (verifyData != null) {
        userId = verifyData['userId'];

        final userData = await fetchUserInfo(baseUrl: baseUrl, userId: userId!);

        if (userData != null) {
          nombreUsuario = userData['username'];
        }
      }
    } catch (_) {
      // Token inválido o error en la red, dejar nombreUsuario como null
    }
  }

  runApp(MiApp(nombreUsuario: nombreUsuario));
}

class MiApp extends StatelessWidget {
  final String? nombreUsuario;

  const MiApp({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Bloquea el botón atrás en toda la app
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Libros',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthPage(), // O la pantalla inicial que uses
        routes: {
          '/inicial': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return PaginaInicial(
              nombreUsuario: args?['nombreUsuario'] ?? 'Usuario',
              inicial: args?['inicial'] ?? true,
            );
          },
          '/paginaFrase': (context) => const PaginaFrase(),
          '/home': (context) => const PaginaHome(),
          '/auth': (context) => const AuthPage(),
          '/perfil': (context) => const PaginaPerfil(),
          '/tienda': (context) => TiendaPage(),
        },
      ),
    );
  }
}
