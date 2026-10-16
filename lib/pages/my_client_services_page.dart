import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'service_offers_page.dart';

class MyClientServicesPage extends StatefulWidget {
  const MyClientServicesPage({super.key});

  @override
  State<MyClientServicesPage> createState() => _MyClientServicesPageState();
}

class _MyClientServicesPageState extends State<MyClientServicesPage> {
  late Future<List<dynamic>> serviciosFuture;

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
  }

  Future<List<dynamic>> cargarServicios() async {
    final resultado = await ApiService.listarServicios();

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
                'No tienes servicios registrados',
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
                  'Consulta el estado de tus servicios.',
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

          if (servicio['trabajadorNombre'] != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: OfixColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trabajador: ${servicio['trabajadorNombre']}',
                    style: const TextStyle(
                      color: OfixColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (servicio['precioAcordado'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: OfixColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Precio acordado: '
                    '${formatearPrecio(servicio['precioAcordado'])}',
                    style: const TextStyle(
                      color: OfixColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (servicio['estado'] == 'PENDIENTE') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceOffersPage(servicio: servicio),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    serviciosFuture = cargarServicios();
                  });
                },
                icon: const Icon(Icons.local_offer_outlined),
                label: Text(
                  'Ver ofertas (${servicio['totalOfertas'] ?? 0})',
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final servicioId = servicio['id'];

                  final resultado =
                      await ApiService.cancelarServicio(servicioId);

                  if (!mounted) {
                    return;
                  }

                  if (resultado['statusCode'] == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Servicio cancelado correctamente',
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
                          'No se pudo cancelar el servicio',
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Cancelar servicio',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}