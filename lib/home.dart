import 'package:app_libros/perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'tienda.dart';
import 'utils/api_headers.dart';
import 'service/home_service.dart';

class PaginaHome extends StatefulWidget {
  const PaginaHome({super.key});

  @override
  State<PaginaHome> createState() => _PaginaHomeState();
}

class _PaginaHomeState extends State<PaginaHome> {
  int _selectedIndex = 0;
  final storage = const FlutterSecureStorage();

  String? title;
  String? body;
  String? end;
  String? username;
  bool cargandoFrase = true;

  @override
  void initState() {
    super.initState();
    cargarFraseUsuario();
  }

  Future<void> cargarFraseUsuario() async {
    final id = await storage.read(key: 'userId');
    final headers = await getApiHeaders();
    final baseUrl = dotenv.env['API_BASE_URL']!;
    cargandoFrase = true;
    try {
      final result = await fetchLastSentenceByUser(
        baseUrl: baseUrl,
        userId: id!,
        headers: headers,
      );
      if (result['statusCode'] == 200) {
        final data = result['body'];
        setState(() {
          title = data['lastSentence']['title'];
          body = (data['lastSentence']['body'] as String).replaceAll(
            r'\n',
            '\n',
          );
          end = data['lastSentence']['end'];
          cargandoFrase = false;
          username = data['username'];
        });
      } else {
        setState(() {
          title = 'Error';
          body = 'No se recibieron datos.';
          end = 'Error';
          cargandoFrase = false;
        });
      }
    } catch (e) {
      setState(() {
        title = e.toString();
        body = "";
        end = "";
        cargandoFrase = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      final enableEmotionsStr = await storage.read(key: 'enableEmotions');
      final randomReflexionStr = await storage.read(key: 'randomReflexion');
      final enableEmotions = enableEmotionsStr == null ? true : enableEmotionsStr == 'true';
      final randomReflexion = randomReflexionStr == null ? true : randomReflexionStr == 'true';

      Navigator.pushNamed(
        context,
        '/inicial',
        arguments: {
          'nombreUsuario': username ?? 'Usuario',
          'inicial': false,
          'enableEmotions': enableEmotions,
          'randomReflexion': randomReflexion,
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    await storage.deleteAll();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Frase'),
    BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tienda'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // Página de inicio con gradiente y scroll de contenido variado
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF64B5F6), // azul pigmentado
              Color(0xFF9575CD), // morado suave
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              cargandoFrase
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                    children: [
                      // Título de la sección de la última frase generada
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Última frase generada",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E), // azul oscuro
                          ),
                        ),
                      ),
                      // Última frase generada (desplegable)
                      Card(
                        color: Colors.white.withOpacity(0.97),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            title ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A237E), // azul oscuro
                            ),
                            textAlign: TextAlign.center,
                          ),
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              body ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF212121), // texto oscuro
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              end ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF283593), // azul más oscuro
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Título de la sección de texto de la semana
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Texto de la semana",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      // Sección: Texto de la semana
                      Card(
                        color: Colors.white.withOpacity(0.97),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: const Text(
                            "Podemos expresarnos de varias maneras...\nA través de la palabra, de una mirada, de un gesto, desde una emoción, desde el silencio, con la música, con el baile, con nuestra vibración y mucho más...\nSi lo piensas bien estás todo el tiempo expresándote, emitiendo energía y vibración...\nTodos nosotros a parte de ser expresiones, también somos receptores...\nLas personas se quejan de lo que reciben, pero ¿qué es lo que están emitiendo...?\nPuede que me digas...yo no emito mal rollo, yo soy buena persona, pero te diré que lo mismo no lo expresas, pero lo tienes guardado, que en definitiva es lo mismo.\nCon todo esto quiero llegar a que observes como estás vibrando...¿ hay amor en tu corazón o resentir? Aquello que guardes vibrará tan alto, o más, que aquello que expresas... Esa herida se representará de alguna manera en tu cuerpo físico, en tu entorno y también por sincronicidad atraerá a otros que tengan tu misma herida.\nSuelta tu dolor, deja ir tu resentir y conviértete en una persona calmada, pacífica, agradecida, llena de amor.\nMe dirás que es difícil...y lo será si así lo crees y no compruebas como se siente liberándote...\nHay una forma de ser una persona pacífica contigo y con tu entorno,y es no quedarte con nada que te haga daño, déjalo ir y abrázate de nuevo a la serenidad,al amor, a la paz.\nUn ejemplo sería un insulto, puedes recogerlo y hacerte daño con él o puedes dejarlo en la boca de quien lo dijo, sabiendo que solo está expresando su dolor y su herida, luego abrázate y háblate con amor.\nTú decides, quedarte con la pena y ser prisionero de ella o soltarla y vivir en amor y en libertad.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF212121), // texto oscuro
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Título de la sección del botón interactivo
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Botón interactivo",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                      // Sección: Botón interactivo
                      _InteractiveResourceSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
        ),
      ),
      const PaginaPerfil(),
      const Placeholder(),
      TiendaPage(),
    ];

    return WillPopScope(
      onWillPop: () async => false, // Bloquea el botón atrás
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Quita la flecha atrás
          backgroundColor: const Color(0xFF64B5F6),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('App de Introspección'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: _logout,
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF9575CD),
          unselectedItemColor: const Color(0xFF64B5F6),
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

// Widget para la sección interactiva
class _InteractiveResourceSection extends StatefulWidget {
  @override
  State<_InteractiveResourceSection> createState() =>
      _InteractiveResourceSectionState();
}

class _InteractiveResourceSectionState
    extends State<_InteractiveResourceSection> {
  bool recursoRecibido = false;
  String? imageUrl;
  bool cargando = false;

  Future<void> obtenerImagen() async {
    setState(() {
      cargando = true;
    });
    try {
      final headers = await getApiHeaders();
      final baseUrl = dotenv.env['API_BASE_URL']!;
      final url = await fetchRandomImageUrl(baseUrl: baseUrl, headers: headers);
      setState(() {
        imageUrl = url;
        recursoRecibido = true;
        cargando = false;
      });
    } catch (_) {
      setState(() {
        cargando = false;
        recursoRecibido = false;
        imageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la imagen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.97),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: cargando
              ? const CircularProgressIndicator()
              : recursoRecibido && imageUrl != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          imageUrl!,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 80, color: Color(0xFF64B5F6)),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9575CD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: obtenerImagen,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        child: Text(
                          "Púlsame",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
