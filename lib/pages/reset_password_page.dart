import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final nuevaPasswordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();

  bool cargando = false;
  bool mostrarNueva = false;
  bool mostrarConfirmacion = false;

  @override
  void dispose() {
    nuevaPasswordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  bool get passwordValida {
    final password = nuevaPasswordController.text;

    return password.length >= 8 &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^A-Za-z\d]').hasMatch(password);
  }

  Future<void> restablecerPassword() async {
    final nuevaPassword =
        nuevaPasswordController.text;

    final confirmarPassword =
        confirmarPasswordController.text;

    if (!passwordValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La contraseña no cumple los requisitos',
          ),
        ),
      );
      return;
    }

    if (nuevaPassword != confirmarPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden',
          ),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    final resultado =
        await ApiService.restablecerPassword(
      widget.token,
      nuevaPassword,
      confirmarPassword,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      cargando = false;
    });

    if (resultado['statusCode'] == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Contraseña actualizada correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo restablecer la contraseña',
          ),
        ),
      );
    }
  }

  Widget requisito(
    String texto,
    bool cumplido,
  ) {
    return Row(
      children: [
        Icon(
          cumplido
              ? Icons.check_circle
              : Icons.cancel,
          size: 18,
          color: cumplido
              ? OfixColors.success
              : OfixColors.error,
        ),
        const SizedBox(width: 8),
        Text(
          texto,
          style: TextStyle(
            color: cumplido
                ? OfixColors.success
                : OfixColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final password =
        nuevaPasswordController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva contraseña',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.lock_reset,
              size: 70,
              color: OfixColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Restablecer contraseña',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingresa una nueva contraseña para tu cuenta.',
              style: TextStyle(
                fontSize: 16,
                color: OfixColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Nueva contraseña',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: OfixColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nuevaPasswordController,
              obscureText: !mostrarNueva,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    mostrarNueva
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarNueva = !mostrarNueva;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            requisito(
              'Mínimo 8 caracteres',
              password.length >= 8,
            ),
            const SizedBox(height: 6),
            requisito(
              'Una letra minúscula',
              RegExp(r'[a-z]').hasMatch(password),
            ),
            const SizedBox(height: 6),
            requisito(
              'Una letra mayúscula',
              RegExp(r'[A-Z]').hasMatch(password),
            ),
            const SizedBox(height: 6),
            requisito(
              'Un número',
              RegExp(r'\d').hasMatch(password),
            ),
            const SizedBox(height: 6),
            requisito(
              'Un carácter especial',
              RegExp(r'[^A-Za-z\d]')
                  .hasMatch(password),
            ),
            const SizedBox(height: 24),
            const Text(
              'Confirmar contraseña',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: OfixColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller:
                  confirmarPasswordController,
              obscureText: !mostrarConfirmacion,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    mostrarConfirmacion
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      mostrarConfirmacion =
                          !mostrarConfirmacion;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cargando
                    ? null
                    : restablecerPassword,
                child: cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Actualizar contraseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}