import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MyServicesPage extends StatefulWidget {
  const MyServicesPage({super.key});

  @override
  State<MyServicesPage> createState() => _MyServicesPageState();
}

class _MyServicesPageState extends State<MyServicesPage> {
  late Future<List<dynamic>> serviciosFuture;

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
  }

  Future<List<dynamic>> cargarServicios() async {
    final resultado = await ApiService.listarMisServicios();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron cargar tus servicios');
    }

    return resultado['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis servicios'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: serviciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudieron cargar tus servicios',
                style: TextStyle(
                  color: OfixColors.error,
                ),
              ),
            );
          }

          final servicios = snapshot.data ?? [];

          if (servicios.isEmpty) {
            return const Center(
              child: Text(
                'No tienes servicios asignados',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                serviciosFuture = cargarServicios();
              });

              await serviciosFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Mis servicios',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Servicios que has aceptado.',
                  style: TextStyle(
                    fontSize: 16,
                    color: OfixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ...servicios.map(
                  (servicio) => _buildServicioCard(servicio),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicioCard(dynamic servicio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OfixColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            servicio['titulo'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: OfixColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            servicio['descripcion'] ?? '',
            style: const TextStyle(
              color: OfixColors.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 18,
                color: OfixColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                servicio['categoriaNombre'] ?? '',
                style: const TextStyle(
                  color: OfixColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: OfixColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  servicio['direccion'] ?? '',
                  style: const TextStyle(
                    color: OfixColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: OfixColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              servicio['estado'] ?? '',
              style: const TextStyle(
                color: OfixColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final servicioId = servicio['id'];

                final resultado =
                    await ApiService.finalizarServicio(servicioId);

                if (!mounted) {
                  return;
                }

                if (resultado['statusCode'] == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Servicio finalizado correctamente',
                      ),
                    ),
                  );

                  setState(() {
                    serviciosFuture = cargarServicios();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se pudo finalizar el servicio',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Finalizar servicio',
              ),
            ),
          ),
        ],
      ),
    );
  }
}