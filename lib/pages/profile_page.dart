import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> perfilFuture;

  @override
  void initState() {
    super.initState();
    perfilFuture = cargarPerfil();
  }

  Future<Map<String, dynamic>> cargarPerfil() async {
    final resultado = await ApiService.obtenerMiPerfil();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudo cargar el perfil');
    }

    return resultado['data'];
  }

  Future<void> editarPerfil(
    Map<String, dynamic> perfil,
  ) async {
    final actualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          perfil: perfil,
        ),
      ),
    );

    if (actualizado == true && mounted) {
      setState(() {
        perfilFuture = cargarPerfil();
      });
    }
  }

  Future<void> cambiarPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChangePasswordPage(),
      ),
    );
  }

  Future<void> cerrarSesion() async {
    await ApiService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const OfixWelcomePage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar el perfil',
                style: TextStyle(
                  color: OfixColors.error,
                ),
              ),
            );
          }

          final perfil = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: OfixColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: OfixColors.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '${perfil['nombre']} ${perfil['apellido']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  perfil['rol'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: OfixColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'Nombre',
                  value: perfil['nombre'] ?? '',
                ),

                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'Apellido',
                  value: perfil['apellido'] ?? '',
                ),

                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: 'Correo electrónico',
                  value: perfil['email'] ?? '',
                ),

                _buildInfoCard(
                  icon: Icons.badge_outlined,
                  title: 'Rol',
                  value: perfil['rol'] ?? '',
                ),

                _buildInfoCard(
                  icon: Icons.check_circle_outline,
                  title: 'Estado de la cuenta',
                  value: perfil['activo'] == true
                      ? 'Activa'
                      : 'Inactiva',
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      editarPerfil(perfil);
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text(
                      'Editar perfil',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: cambiarPassword,
                    icon: const Icon(
                      Icons.lock_outline,
                    ),
                    label: const Text(
                      'Cambiar contraseña',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: cerrarSesion,
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text(
                      'Cerrar sesión',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OfixColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: OfixColors.primary,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: OfixColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OfixColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}