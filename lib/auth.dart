import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'inicial.dart';
import 'service/auth_service.dart';

class AuthPage extends StatefulWidget {
  final http.Client? httpClient; // <-- Añade esto

  const AuthPage({super.key, this.httpClient});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final TextEditingController _loginEmail = TextEditingController();
  final TextEditingController _loginPassword = TextEditingController();
  final TextEditingController _registerName = TextEditingController();
  final TextEditingController _registerEmail = TextEditingController();
  final TextEditingController _registerPassword = TextEditingController();

  final storage = const FlutterSecureStorage();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> login() async {
    final client = widget.httpClient ?? http.Client();
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final result = await loginUser(
      client: client,
      baseUrl: baseUrl,
      email: _loginEmail.text,
      password: _loginPassword.text,
    );
    final data = result['body'];

    if (result['statusCode'] == 200 && data['token'] != null) {
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'userId', value: data['userId']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión iniciada correctamente')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PaginaInicial(nombreUsuario: data['username'], inicial: true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Error al iniciar sesión')),
      );
    }
  }

  Future<void> register() async {
    final client = widget.httpClient ?? http.Client();
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final result = await registerUser(
      client: client,
      baseUrl: baseUrl,
      username: _registerName.text,
      email: _registerEmail.text,
      password: _registerPassword.text,
    );
    final data = result['body'];

    if (result['statusCode'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Usuario registrado')),
      );
      _tabController.animateTo(0); // Cambia a la pestaña de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Error al registrar usuario'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Bloquea el botón atrás
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Quita la flecha atrás
          title: const Text("Autenticación"),
          backgroundColor: const Color(0xFF9575CD),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: "Iniciar sesión"), Tab(text: "Registrarse")],
            indicatorColor: Color(0xFF283593),
          ),
        ),
        body: Container(
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
          child: TabBarView(
            controller: _tabController,
            children: [
              // Login form
              Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _loginEmail,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                            ),
                            validator:
                                (value) =>
                                    value != null && value.contains('@')
                                        ? null
                                        : 'Email inválido',
                          ),
                          TextFormField(
                            controller: _loginPassword,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                            ),
                            obscureText: true,
                            validator:
                                (value) =>
                                    value != null && value.length >= 6
                                        ? null
                                        : 'Mínimo 6 caracteres',
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_loginFormKey.currentState!.validate()) {
                                login();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF9575CD,
                              ), // morado suave
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Entrar"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Register form
              Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _registerFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _registerName,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                            ),
                            validator:
                                (value) =>
                                    value != null && value.isNotEmpty
                                        ? null
                                        : 'Nombre requerido',
                          ),
                          TextFormField(
                            controller: _registerEmail,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                            ),
                            validator:
                                (value) =>
                                    value != null && value.contains('@')
                                        ? null
                                        : 'Email inválido',
                          ),
                          TextFormField(
                            controller: _registerPassword,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                            ),
                            obscureText: true,
                            validator:
                                (value) =>
                                    value != null && value.length >= 6
                                        ? null
                                        : 'Mínimo 6 caracteres',
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_registerFormKey.currentState!.validate()) {
                                register();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF9575CD,
                              ), // morado suave
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Crear cuenta"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
