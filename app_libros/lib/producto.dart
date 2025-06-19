import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  final String title;
  final String? image;
  final String? description;
  final Map<String, dynamic>? productData;

  const ProductPage({
    required this.title,
    this.image,
    this.description,
    this.productData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = productData ?? {};
    final category = (data['category'] ?? '').toString().toLowerCase();

    // Obtener productos de la misma categoría (excepto el actual)
    final productosPorCategoria =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, List<Map<String, dynamic>>>?;
    final List<Map<String, dynamic>> relacionados =
        productosPorCategoria != null &&
                productosPorCategoria.containsKey(category)
            ? productosPorCategoria[category]!
                .where((p) => (p['name'] ?? p['title']) != title)
                .toList()
            : [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF64B5F6),
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        // No pongas automaticallyImplyLeading: false aquí
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF64B5F6), Color(0xFF9575CD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              if (image != null && image!.isNotEmpty)
                image!.startsWith('http')
                    ? Image.network(
                      image!,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.local_florist,
                            size: 100,
                            color: Color(0xFF64B5F6),
                          ),
                    )
                    : Image.asset(image!, height: 220, fit: BoxFit.contain)
              else
                const Icon(
                  Icons.local_florist,
                  size: 100,
                  color: Color(0xFF64B5F6),
                ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF283593),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description ??
                    "This is a natural and organic product beneficial for well-being.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF283593)),
              ),
              const SizedBox(height: 30),
              // Precio
              if (data['price'] != null)
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Color(0xFF9575CD)),
                    Text(
                      "${data['price']}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9575CD),
                      ),
                    ),
                  ],
                ),
              // Stock
              if (data['stock'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Color(0xFF64B5F6)),
                      const SizedBox(width: 6),
                      Text(
                        "Stock: ${data['stock']}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF283593),
                        ),
                      ),
                    ],
                  ),
                ),
              // Botón añadir al carrito
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9575CD),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Resto de propiedades adornadas
              ..._buildProductDetails(data),
              const SizedBox(height: 30),
              // Productos relacionados
              if (relacionados.isNotEmpty) ...[
                const Divider(
                  height: 32,
                  thickness: 1.2,
                  color: Color(0xFF9575CD),
                ),
                const Text(
                  "Productos de la misma categoría",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF283593),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: relacionados.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final prod = relacionados[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductPage(
                                    title: prod['name'] ?? prod['title'] ?? '',
                                    image: null,
                                    description: prod['description'],
                                    productData: prod,
                                  ),
                              settings: RouteSettings(
                                arguments: productosPorCategoria,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prod['name'] ?? prod['title'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF283593),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  prod['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9575CD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProductDetails(Map<String, dynamic> data) {
    final exclude = {
      '_id',
      'name',
      'title',
      'description',
      'price',
      'category',
      'stock',
      'image',
    };
    final iconMap = {
      'weight': Icons.scale,
      'scent': Icons.spa,
      'flavor': Icons.emoji_food_beverage,
      'volume': Icons.local_drink,
      'author': Icons.person,
      'publisher': Icons.business,
      'pages': Icons.menu_book,
      'language': Icons.language,
      'isbn': Icons.qr_code,
      'brand': Icons.label,
      'ingredients': Icons.list,
      'tags': Icons.sell,
    };

    List<Widget> widgets = [];
    data.forEach((key, value) {
      if (!exclude.contains(key) && value != null) {
        widgets.add(
          Card(
            color: Colors.white.withOpacity(0.92),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(
                iconMap[key] ?? Icons.info_outline,
                color: const Color(0xFF9575CD),
              ),
              title: Text(
                _capitalize(key),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF283593),
                ),
              ),
              subtitle:
                  value is List
                      ? Text(
                        value.join(', '),
                        style: const TextStyle(color: Color(0xFF283593)),
                      )
                      : Text(
                        value.toString(),
                        style: const TextStyle(color: Color(0xFF283593)),
                      ),
            ),
          ),
        );
      }
    });
    return widgets;
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
