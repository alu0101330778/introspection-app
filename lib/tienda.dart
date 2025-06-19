import 'package:flutter/material.dart';
import 'producto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/api_headers.dart';
import 'service/tienda_service.dart';

class TiendaPage extends StatefulWidget {
  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  String? selectedCategory;
  bool loading = true;
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();

  // Definición de categorías y sus iconos
  final List<Map<String, dynamic>> categories = [
    {'title': 'Tea', 'icon': Icons.local_cafe, 'key': 'tea'},
    {'title': 'Suplement', 'icon': Icons.eco, 'key': 'suplement'},
    {'title': 'Book', 'icon': Icons.book, 'key': 'book'},
    {
      'title': 'Aromatherapy',
      'icon': Icons.local_florist,
      'key': 'aromatherapy',
    },
  ];

  final Map<String, IconData> iconosPorCategoria = {
    'tea': Icons.local_cafe,
    'suplement': Icons.eco,
    'book': Icons.book,
    'aromatherapy': Icons.local_florist,
  };

  // Productos agrupados por categoría
  Map<String, List<Map<String, dynamic>>> productosPorCategoria = {
    'tea': [],
    'suplement': [],
    'book': [],
    'aromatherapy': [],
  };

  @override
  void initState() {
    super.initState();
    fetchProductosDesdeServicio();
    _searchController.addListener(() {
      setState(() {
        searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProductosDesdeServicio() async {
    setState(() {
      loading = true;
    });
    try {
      final headers = await getApiHeaders();
      final baseUrl = dotenv.env['API_BASE_URL']!;
      final productos = await fetchProductos(
        baseUrl: baseUrl,
        headers: headers,
      );
      productosPorCategoria = {
        'tea': [],
        'suplement': [],
        'book': [],
        'aromatherapy': [],
      };
      for (var producto in productos) {
        final categoria = (producto['category'] ?? '').toLowerCase();
        if (productosPorCategoria.containsKey(categoria)) {
          productosPorCategoria[categoria]!.add(producto);
        }
      }
    } catch (e) {
      productosPorCategoria = {
        'tea': [],
        'suplement': [],
        'book': [],
        'aromatherapy': [],
      };
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Bloquea el botón atrás
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Quita la flecha atrás
          title: const Text('Naturalis'),
          centerTitle: true,
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
          child:
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children:
                          categories
                              .where((item) {
                                final productos =
                                    productosPorCategoria[item['key']] ?? [];
                                return productos.isNotEmpty;
                              })
                              .map((item) {
                                final isSelected =
                                    selectedCategory == item['key'];
                                final productos =
                                    productosPorCategoria[item['key']] ?? [];
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory =
                                              isSelected ? null : item['key'];
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? const Color(
                                                    0xFF9575CD,
                                                  ).withOpacity(0.15)
                                                  : Colors.white.withOpacity(
                                                    0.95,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? const Color(0xFF9575CD)
                                                    : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item['icon'],
                                              size: 32,
                                              color: const Color(0xFF64B5F6),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              item['title'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF283593),
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              isSelected
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: const Color(0xFF9575CD),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isSelected && productos.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: productos.length,
                                          itemBuilder: (context, idx) {
                                            if (idx >= 5) {
                                              // Muestra solo los primeros 5 productos, el resto con scroll
                                              return Container(
                                                constraints:
                                                    const BoxConstraints(
                                                      maxHeight: 300,
                                                    ),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  itemCount:
                                                      productos.length - 5,
                                                  itemBuilder: (context, i) {
                                                    final producto =
                                                        productos[i + 5];
                                                    return _buildProductTile(
                                                      context,
                                                      producto,
                                                      item['icon'],
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                            final producto = productos[idx];
                                            return _buildProductTile(
                                              context,
                                              producto,
                                              item['icon'],
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              })
                              .toList(),
                    ),
                  ),
        ),
      ),
    );
  }

  // Devuelve todos los productos filtrados por el texto de búsqueda, sin agrupar por categoría

  Widget _buildProductTile(
    BuildContext context,
    Map<String, dynamic> producto,
    IconData icono,
  ) {
    final imageUrl = producto['image'];
    Widget leadingWidget;
    if (imageUrl != null && imageUrl is String && imageUrl.startsWith('http')) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
                  Icon(icono, size: 40, color: const Color(0xFF64B5F6)),
        ),
      );
    } else {
      leadingWidget = Icon(icono, size: 40, color: const Color(0xFF64B5F6));
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white.withOpacity(0.95),
      child: ListTile(
        leading: leadingWidget,
        title: Text(
          producto['name'] ?? producto['title'] ?? '',
          style: const TextStyle(color: Color(0xFF283593)),
        ),
        subtitle: Text(producto['description'] ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ProductPage(
                    title: producto['name'] ?? producto['title'] ?? '',
                    image: producto['image'],
                    description: producto['description'],
                    productData: producto,
                  ),
            ),
          );
        },
      ),
    );
  }
}
