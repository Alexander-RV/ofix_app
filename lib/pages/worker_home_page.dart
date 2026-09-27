import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'my_services_page.dart';
import 'profile_page.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  late Future<List<dynamic>> serviciosFuture;

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
  }

  Future<List<dynamic>> cargarServicios() async {
    final resultado =
        await ApiService.listarServiciosDisponibles();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron cargar los servicios');
    }

    return resultado['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OFIX - Trabajador'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            serviciosFuture = cargarServicios();
          });

          await serviciosFuture;
        },
        child: FutureBuilder<List<dynamic>>(
          future: serviciosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'No se pudieron cargar los servicios',
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
                  'No hay servicios disponibles',
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Servicios disponibles',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Encuentra servicios que puedes aceptar.',
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
            );
          },
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Mis servicios',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyServicesPage(),
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilePage(),
              ),
            );
          }
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
              color: OfixColors.warning.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              servicio['estado'] ?? '',
              style: const TextStyle(
                color: OfixColors.warning,
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
                    await ApiService.aceptarServicio(
                  servicioId,
                );

                if (!mounted) {
                  return;
                }

                if (resultado['statusCode'] == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Servicio aceptado correctamente',
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
                        'No se pudo aceptar el servicio',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Aceptar servicio',
              ),
            ),
          ),
        ],
      ),
    );
  }
}