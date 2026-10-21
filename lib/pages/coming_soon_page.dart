import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Pantalla provisional para funciones que aún no están disponibles
class ComingSoonPage extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final String descripcion;

  const ComingSoonPage({
    super.key,
    required this.titulo,
    required this.icono,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: OfixColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, size: 44, color: OfixColors.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: OfixColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: OfixColors.warningSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Muy pronto',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
