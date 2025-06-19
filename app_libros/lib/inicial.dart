import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utils/api_headers.dart';
import 'service/inicial_service.dart';

class PaginaInicial extends StatefulWidget {
  final String nombreUsuario;
  final bool inicial;
  const PaginaInicial({
    required this.nombreUsuario,
    required this.inicial,
    super.key,
  });

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial>
    with TickerProviderStateMixin {
  String currentMessage = '';
  bool showMapa = false;
  bool mensaje1Visible = false;
  bool mensaje2Visible = false;
  final List<String> emociones =
      (jsonDecode(dotenv.env['EMOTIONS']!) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
  List<String> emocionesSeleccionadas = [];

  @override
  void initState() {
    super.initState();

    if (widget.inicial) {
      // 1. Mostrar "Bienvenido Juan"
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => mensaje1Visible = true);
      });

      // 2. Ocultar "Bienvenido Juan"
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => mensaje1Visible = false);
      });

      // 3. Mostrar "¿Cómo te sientes hoy?"
      Future.delayed(const Duration(seconds: 4), () {
        setState(() {
          currentMessage = "¿Cómo te sientes hoy?";
          mensaje2Visible = true;
        });
      });
      // 4. Mostrar mapa
      Future.delayed(const Duration(seconds: 6), () {
        setState(() => showMapa = true);
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          currentMessage = "¿Cómo te sientes?";
          mensaje2Visible = true;
        });
      });
      // 4. Mostrar mapa
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => showMapa = true);
      });
    }
  }

  void toggleEmocion(String emocion) {
    setState(() {
      if (emocionesSeleccionadas.contains(emocion)) {
        emocionesSeleccionadas.remove(emocion);
      } else if (emocionesSeleccionadas.length < 3) {
        emocionesSeleccionadas.add(emocion);
      }
    });
  }

  void confirmar() async {
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');

    try {
      final headers = await getApiHeaders();
      final ok = await postUserEmotions(
        baseUrl: baseUrl,
        userId: userId!,
        emociones: emocionesSeleccionadas,
        headers: headers,
      );

      if (ok) {
        Navigator.pushNamed(
          context,
          '/paginaFrase',
          arguments: {'userId': userId, 'emociones': emocionesSeleccionadas},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar las emociones.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar al servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Bloquea el botón atrás
      child: Scaffold(
        body: SizedBox.expand(
          child: Container(
            // Gradiente
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF64B5F6), // azul más pigmentado
                  Color(0xFF9575CD), // morado suave
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // "Bienvenido Juan"
                      AnimatedOpacity(
                        opacity: mensaje1Visible ? 1 : 0,
                        duration: const Duration(seconds: 2),
                        child: Text(
                          "Gracias, ${widget.nombreUsuario}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF283593), // azul oscuro
                          ),
                        ),
                      ),
                      // "¿Cómo te sientes hoy?"
                      AnimatedOpacity(
                        opacity: mensaje2Visible ? 1 : 0,
                        duration: const Duration(seconds: 2),
                        child: Text(
                          currentMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF283593),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Fade del mapa completo
                  AnimatedOpacity(
                    opacity: showMapa ? 1 : 0,
                    duration: const Duration(seconds: 2),
                    child:
                        showMapa
                            ? Column(
                              children: [
                                const Text(
                                  "Elige tus emociones:",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF283593),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children:
                                        emociones.map((e) {
                                          final seleccionada =
                                              emocionesSeleccionadas.contains(
                                                e,
                                              );
                                          return ChoiceChip(
                                            label: Text(e),
                                            selected: seleccionada,
                                            onSelected: (_) => toggleEmocion(e),
                                            // Botones y chips seleccionados
                                            selectedColor: const Color(
                                              0xFF9575CD,
                                            ), // morado suave
                                            backgroundColor: Colors.white,
                                            labelStyle: TextStyle(
                                              color:
                                                  seleccionada
                                                      ? Color(0xFF283593)
                                                      : Colors.black87,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                ElevatedButton(
                                  onPressed:
                                      emocionesSeleccionadas.isNotEmpty
                                          ? confirmar
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFE1BEE7,
                                    ), // lila suave
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            )
                            : const SizedBox.shrink(),
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
