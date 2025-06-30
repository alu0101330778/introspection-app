import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'utils/api_headers.dart';
import 'service/perfil_service.dart';
import 'package:google_fonts/google_fonts.dart'; // Añade esta línea

class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({super.key});

  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  Map<String, dynamic>? usuario;
  bool cargando = true;
  final storage = const FlutterSecureStorage();

  // NUEVO: Estados locales para los switches
  bool? enableEmotions;
  bool? randomReflexion;
  bool actualizando = false;

  // Variables de paginación para el gráfico temporal
  int diasPorPagina = 7;
  int paginaActual = 0;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final id = await storage.read(key: 'userId');
    final baseUrl = dotenv.env['API_BASE_URL']!;
    try {
      final headers = await getApiHeaders();
      final result = await fetchUserInfo(
        baseUrl: baseUrl,
        userId: id!,
        headers: headers,
      );
      if (result['statusCode'] == 200) {
        final data = result['body'];
        setState(() {
          usuario = data;
          cargando = false;
          // NUEVO: Inicializa los switches
          enableEmotions = data['enableEmotions'] ?? false;
          randomReflexion = data['randomReflexion'] ?? false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  // NUEVO: Función para actualizar settings
  Future<void> actualizarSettings() async {
    setState(() => actualizando = true);
    final userId = await storage.read(key: 'userId');
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final headers = await getApiHeaders();
    final result = await updateUserSettings(
      baseUrl: baseUrl,
      userId: userId!,
      enableEmotions: enableEmotions!,
      randomReflexion: randomReflexion!,
      headers: headers,
    );
    setState(() => actualizando = false);
    if (result['statusCode'] == 200) {
      await storage.write(key: 'enableEmotions', value: enableEmotions.toString());
      await storage.write(key: 'randomReflexion', value: randomReflexion.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración actualizada')),
      );
      await cargarUsuario();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error actualizando configuración')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text("Error al cargar usuario")),
      );
    }

    final emociones = Map<String, double>.from(
      (usuario!['emotions'] ?? {}).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      ),
    );

    final frasesFavoritas = List<Map<String, dynamic>>.from(
      usuario!['favoriteSentences'] ?? [],
    );

    final datosUsuario = {
      'Nombre': usuario!['username'],
      'Email': usuario!['email'],
    };

    // --- NUEVO: Procesar emotionsByDay para el gráfico temporal normalizado y paginable ---
    final List<dynamic> emotionsByDay = usuario!['emotionsByDay'] ?? [];
    final rawList = dotenv.env['EMOTIONS'];
    final emocionesValidas =
        rawList != null
            ? (jsonDecode(rawList) as List<dynamic>)
                .map((e) => e.toString().toLowerCase())
                .toList()
            : <String>[];

    // Calcula el rango de días a mostrar
    int totalDias = emotionsByDay.length;
    int start = (totalDias - diasPorPagina - paginaActual * diasPorPagina)
        .clamp(0, totalDias);
    int end = (totalDias - paginaActual * diasPorPagina).clamp(0, totalDias);
    final emocionesDiasMostrados = emotionsByDay.sublist(start, end);

    // Prepara los datos para el gráfico: cada emoción tendrá una lista de valores normalizados por día
    Map<String, List<FlSpot>> emotionSeries = {};
    for (int i = 0; i < emocionesDiasMostrados.length; i++) {
      final day = emocionesDiasMostrados[i];
      final counts = Map<String, dynamic>.from(day['counts'] ?? {});
      for (final em in emocionesValidas) {
        final valor =
            (counts[em[0].toUpperCase() + em.substring(1)] ?? 0.0).toDouble();
        emotionSeries.putIfAbsent(em, () => []);
        // El eje X es el índice del día en la ventana mostrada
        emotionSeries[em]!.add(FlSpot(i.toDouble(), valor));
      }
    }

    final emocionesMostradas =
        emocionesValidas
            .where((em) => emotionSeries[em]!.any((spot) => spot.y > 0))
            .toList();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Perfil', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
          backgroundColor: const Color(0xFF64B5F6),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF9575CD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos del usuario',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF283593),
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...datosUsuario.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${e.key}: ${e.value}',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )),
                      const Divider(height: 24),
                      // NUEVO: Switches para enableEmotions y randomReflexion
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Preguntar por emociones",
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                          Switch(
                            value: enableEmotions ?? false,
                            onChanged: (v) => setState(() => enableEmotions = v),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Reflexión aleatoria",
                            style: GoogleFonts.montserrat(fontSize: 15),
                          ),
                          Switch(
                            value: randomReflexion ?? false,
                            onChanged: (v) => setState(() => randomReflexion = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: ElevatedButton.icon(
                          icon: actualizando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            actualizando ? "Guardando..." : "Actualizar datos",
                            style: GoogleFonts.montserrat(),
                          ),
                          onPressed: actualizando ? null : actualizarSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: const Text(
                    'Frases favoritas',
                    style: TextStyle(color: Color(0xFF283593)),
                  ),
                  children:
                      frasesFavoritas.isNotEmpty
                          ? frasesFavoritas.map((frase) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    frase['title'] ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF9575CD),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    if ((frase['body'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 4.0,
                                        ),
                                        child: Text(
                                          frase['body'] ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF283593),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    if ((frase['end'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 4.0,
                                        ),
                                        child: Text(
                                          frase['end'] ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF64B5F6),
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    // Botón eliminar favorito
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 8.0,
                                      ),
                                      child: Center(
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: "Eliminar de favoritos",
                                          onPressed: () async {
                                            final userId = await storage.read(
                                              key: 'userId',
                                            );
                                            final sentenceId = frase['_id'];
                                            if (userId != null &&
                                                sentenceId != null) {
                                              final baseUrl =
                                                  dotenv.env['API_BASE_URL']!;
                                              final headers =
                                                  await getApiHeaders();
                                              final result =
                                                  await removeFavoriteSentence(
                                                    baseUrl: baseUrl,
                                                    userId: userId,
                                                    sentenceId: sentenceId,
                                                    headers: headers,
                                                  );
                                              if (result['statusCode'] == 200) {
                                                await cargarUsuario();
                                                setState(() {});
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No se pudo eliminar la frase de favoritos',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                          : [
                            const ListTile(
                              title: Text("No hay frases favoritas."),
                            ),
                          ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Promedio de emociones registradas",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF283593)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: RadarEmociones(emociones: emociones),
              ),
              const SizedBox(height: 30),
              const Text(
                "Evolución de emociones en el tiempo (últimos 7 días)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF283593),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child:
                    emocionesMostradas.isEmpty
                        ? const Center(
                          child: Text(
                            "No hay registros suficientes para mostrar el gráfico temporal.",
                          ),
                        )
                        : Column(
                          children: [
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx >= 0 &&
                                              idx <
                                                  emocionesDiasMostrados
                                                      .length) {
                                            final dateStr =
                                                emocionesDiasMostrados[idx]['date'];
                                            if (dateStr != null) {
                                              final date = DateTime.tryParse(
                                                dateStr,
                                              );
                                              if (date != null) {
                                                return Text(
                                                  "${date.day}/${date.month}",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                );
                                              }
                                              return Text(
                                                dateStr,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              );
                                            }
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  minX: 0,
                                  maxX:
                                      emocionesDiasMostrados.isNotEmpty
                                          ? (emocionesDiasMostrados.length - 1)
                                              .toDouble()
                                          : 1,
                                  minY: 0,
                                  maxY: 1,
                                  lineBarsData:
                                      emocionesMostradas.map((em) {
                                        final color = _colorForEmotion(em);
                                        return LineChartBarData(
                                          spots: emotionSeries[em]!,
                                          isCurved: true,
                                          color: color,
                                          barWidth: 2,
                                          dotData: FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: false,
                                          ),
                                        );
                                      }).toList(),
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor:
                                          (LineBarSpot touchedSpot) =>
                                              Colors.white,
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((spot) {
                                          final em =
                                              emocionesMostradas[spot.barIndex];
                                          return LineTooltipItem(
                                            '$em: ${(spot.y * 100).toStringAsFixed(0)}%',
                                            TextStyle(
                                              color: _colorForEmotion(em),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Botones para navegar entre páginas de días
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed:
                                      paginaActual <
                                              (totalDias / diasPorPagina)
                                                      .ceil() -
                                                  1
                                          ? () {
                                            setState(() {
                                              paginaActual++;
                                            });
                                          }
                                          : null,
                                ),
                                Text(
                                  "Días ${start + 1} - $end de $totalDias",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF283593),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed:
                                      paginaActual > 0
                                          ? () {
                                            setState(() {
                                              paginaActual--;
                                            });
                                          }
                                          : null,
                                ),
                              ],
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Asigna un color a cada emoción para el gráfico temporal
  Color _colorForEmotion(String emotion) {
    switch (emotion) {
      case 'esperanza':
        return Colors.green;
      case 'ansiedad':
        return Colors.red;
      case 'felicidad':
        return Colors.orange;
      case 'amor':
        return Colors.pink;
      case 'sorpresa':
        return Colors.blue;
      case 'miedo':
        return Colors.grey;
      case 'humor':
        return Colors.teal;
      case 'tristeza':
        return Colors.indigo;
      case 'vergüenza':
        return Colors.brown;
      case 'compasion':
        return Colors.purple;
      case 'alegria':
        return Colors.amber;
      case 'ira':
        return Colors.deepOrange;
      default:
        return Colors.black;
    }
  }
}

class RadarEmociones extends StatelessWidget {
  final Map<String, double> emociones;

  const RadarEmociones({super.key, required this.emociones});

  @override
  Widget build(BuildContext context) {
    final rawList = dotenv.env['EMOTIONS'];
    if (rawList == null) return const Text("No se pudieron cargar emociones");

    final emocionesValidas =
        (jsonDecode(rawList) as List<dynamic>)
            .map((e) => e.toString().toLowerCase())
            .toList();

    final labelsFiltradas =
        emocionesValidas.where((em) => emociones[em] != null).toList();
    final valores = labelsFiltradas.map((em) => emociones[em]!).toList();

    // Mostrar mensaje si hay menos de 3 emociones distintas
    if (labelsFiltradas.length < 3) {
      return const Center(
        child: Text("Registra al menos 3 emociones para ver el gráfico."),
      );
    }

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        titlePositionPercentageOffset: 0.1,
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 10),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: const BorderSide(color: Color(0xFF9575CD), width: 2),
        getTitle:
            (index, angle) => RadarChartTitle(
              text:
                  labelsFiltradas[index][0].toUpperCase() +
                  labelsFiltradas[index].substring(1),
              angle: angle,
            ),
        dataSets: [
          RadarDataSet(
            dataEntries: valores.map((v) => RadarEntry(value: v)).toList(),
            fillColor: const Color(0xFF9575CD).withAlpha((0.3 * 255).toInt()),
            borderColor: const Color(0xFF9575CD),
            borderWidth: 2,
            entryRadius: 3,
          ),
        ],
      ),
    );
  }
}
