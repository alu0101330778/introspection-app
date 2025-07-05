import 'package:app_libros/inicial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utils/api_headers.dart';
import 'service/frase_service.dart';

class PaginaFrase extends StatefulWidget {
  const PaginaFrase({super.key});

  @override
  State<PaginaFrase> createState() => _PaginaFraseState();
}

class _PaginaFraseState extends State<PaginaFrase> {
  String? title;
  String? body;
  String? end;

  List<String>? emocionesRecibidas;
  bool yaInicializado = false;

  bool mostrarTitle = false;
  bool mostrarBody = false;
  bool mostrarEnd = false;
  bool mostrarBoton = false;
  bool fondoFinal = false;

  final storage = const FlutterSecureStorage();
  bool guardandoFavorito = false;
  bool favoritoGuardado = false;

  String? sentenceId; // Añade esto a tus variables de estado

  bool enableEmotions = false;
  bool randomReflexion = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!yaInicializado) {
      final data =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (data != null) {
        emocionesRecibidas = List<String>.from(data['emociones'] ?? []);
        final userId = data['userId'];
        if (userId != null) {
          obtenerFraseDesdeBackend(userId);
        } else {
          setState(() {
            title = 'Error';
            body = 'No se recibió el ID del usuario.';
            inicializarAnimaciones();
          });
        }
      } else {
        setState(() {
          title = 'Error';
          body = 'No se recibieron datos.';
          inicializarAnimaciones();
        });
      }

      yaInicializado = true;
    }
  }

  void inicializarAnimaciones() async {
    if (!mounted) return;
    setState(() => mostrarTitle = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => mostrarBody = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => mostrarEnd = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      mostrarBoton = true;
      fondoFinal = true;
    });
  }

  Future<void> obtenerFraseDesdeBackend(String userId) async {
    final data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final emociones = emocionesRecibidas ?? [];
    randomReflexion = data?['randomReflexion'] ?? true;
    enableEmotions = data?['enableEmotions'] ?? true;

    try {
      final baseUrl = dotenv.env['API_BASE_URL']!;
      final headers = await getApiHeaders();
      Map<String, dynamic> result;

      if (randomReflexion) {
        result = await fetchFraseByUser(
          baseUrl: baseUrl,
          userId: userId,
          emociones: emociones,
          headers: headers,
        );
      } else {
        result = await fetchFraseByUserFixed(
          baseUrl: baseUrl,
          userId: userId,
          emociones: emociones,
          headers: headers,
        );
      }

      if (result['statusCode'] == 200) {
        final data = result['body'];
        setState(() {
          title = data['title'];
          body = (data['body'] as String).replaceAll(r'\n', '\n');
          end = data['end'];
          sentenceId = data['_id'];
          fondoFinal = true;
        });
        inicializarAnimaciones();
      } else {
        throw Exception('Error del servidor');
      }
    } catch (e) {
      setState(() {
        title = "Error";
        body = "No se pudo conectar con el servidor.";
        fondoFinal = true;
        mostrarTitle = true;
        mostrarBody = true;
        mostrarEnd = true;
        mostrarBoton = true;
      });
    }
  }

  Future<void> agregarAFavoritos() async {
  setState(() {
    guardandoFavorito = true;
  });

  try {
    final userId = await storage.read(key: 'userId');
    if (userId != null) {
      final baseUrl = dotenv.env['API_BASE_URL']!;
      final headers = await getApiHeaders();

      final result = await addFavoriteSentence(
        baseUrl: baseUrl,
        userId: userId,
        sentenceId: sentenceId,
        title: sentenceId == null ? title : null,
        headers: headers,
      );

      if (result['statusCode'] == 200) {
        setState(() {
          favoritoGuardado = true;
        });
      } else {
        // Opcional: mostrar error
        print("Error al guardar favorito: ${result['body']}");
      }
    }
  } catch (e) {
    print("Excepción al guardar favorito: $e");
  } finally {
    setState(() {
      guardandoFavorito = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Bloquea el botón atrás
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Quita la flecha atrás
          title: const Text("Frase"),
          backgroundColor: const Color(0xFF9575CD),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF9575CD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: mostrarTitle ? 1 : 0,
                    duration: const Duration(seconds: 2),
                    child: Text(
                      title ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF283593),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: mostrarBody ? 1 : 0,
                    duration: const Duration(seconds: 2),
                    child: Text(
                      body ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF283593),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: mostrarEnd ? 1 : 0,
                    duration: const Duration(seconds: 2),
                    child: Text(
                      end ?? "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF5E35B1), // lila más fuerte
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedOpacity(
                    opacity: mostrarBoton ? 1 : 0,
                    duration: const Duration(seconds: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => PaginaInicial(
                                                                      nombreUsuario: '',
                                                                      inicial: false,
                                                                      enableEmotions: enableEmotions,
                                                                      randomReflexion: randomReflexion,
                                                                    ),
                                                                  ),
                                                                ),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Volver"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE1BEE7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/home');
                          },
                          icon: const Icon(Icons.home),
                          label: const Text("Inicio"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE1BEE7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Solo el icono de corazón para favoritos
                        ElevatedButton(
                          onPressed:
                              favoritoGuardado || guardandoFavorito
                                  ? null
                                  : agregarAFavoritos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                favoritoGuardado
                                    ? Colors.red[100]
                                    : const Color(0xFF9575CD),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Icon(
                            favoritoGuardado
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favoritoGuardado ? Colors.red : Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
