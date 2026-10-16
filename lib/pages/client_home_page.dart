import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'create_service_page.dart';
import 'my_client_services_page.dart';
import 'profile_page.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late Future<List<dynamic>> serviciosFuture;
  String nombreUsuario ='';

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
    cargarNombre();
  }

  Future<List<dynamic>> cargarServicios() async {
    final resultado = await ApiService.listarServicios();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron caragar los servicios');
      
    }

    return resultado['data'];
  }

  Future<void> cargarNombre() async {
    final resultado = await ApiService.obtenerMiPerfil();

    if (!mounted) {
      return;
    }

    if (resultado['statusCode'] == 200) {
      setState(() {
        nombreUsuario = resultado['data']['nombre'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OFIX - Cliente'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreUsuario.isEmpty ? 'Hola 👋' : 'Hola, $nombreUsuario 👋',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '¿Qué servicio necesitas hoy?',
              style: TextStyle(
                fontSize: 16,
                color: OfixColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateServicePage(),
                  ),
                );

                if (!mounted) {
                  return;
                }

                setState(() {
                  serviciosFuture = cargarServicios();
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: OfixColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.home_repair_service_outlined,
                      color: Colors.white,
                      size: 40,
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Encuentra ayuda para tu hogar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Solicita un servicio de forma rápida y sencilla.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Mis servicios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<dynamic>>(
              future: serviciosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: OfixColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'No se pudieron cargar los servicios.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final servicios = snapshot.data ?? [];

                if (servicios.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: OfixColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 50,
                          color: OfixColors.textSecondary,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'Todavía no tienes servicios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: OfixColors.textPrimary,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Aquí aparecerán tus servicios solicitados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: OfixColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: servicios.map((servicio) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: OfixColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            servicio['titulo'] ?? '',
                            style: const TextStyle(
                              fontSize: 17,
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

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 18,
                                color: OfixColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                servicio['categoriaNombre'] ?? '',
                                style: const TextStyle(
                                  color: OfixColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: OfixColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  servicio['direccion'] ?? '',
                                  style: const TextStyle(
                                    color: OfixColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: OfixColors.background,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              servicio['estado'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: OfixColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
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
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
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
                builder: (_) => const MyClientServicesPage(),
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
}