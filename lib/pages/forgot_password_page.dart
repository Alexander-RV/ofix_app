import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController =
      TextEditingController();

  bool enviando = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> recuperarPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu correo electrónico'),
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    final resultado =
        await ApiService.solicitarRecuperacion(email);

    if (!mounted) {
      return;
    }

    setState(() {
      enviando = false;
    });

    if (resultado['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada correctamente',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo procesar la solicitud',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.lock_reset,
              size: 70,
              color: OfixColors.primary,
            ),

            const SizedBox(height: 24),

            const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ingresa el correo electrónico asociado '
              'a tu cuenta para recuperar tu contraseña.',
              style: TextStyle(
                fontSize: 16,
                color: OfixColors.textSecondary,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Correo electrónico',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'correo@ejemplo.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviando
                    ? null
                    : recuperarPassword,
                child: enviando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar enlace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Volver al inicio de sesión',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}