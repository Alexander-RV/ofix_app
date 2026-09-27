import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {

  final passwordActualController =
      TextEditingController();

  final nuevaPasswordController =
      TextEditingController();

  final confirmarPasswordController =
      TextEditingController();

  bool mostrarPasswordActual = false;
  bool mostrarNuevaPassword = false;
  bool mostrarConfirmarPassword = false;

  bool guardando = false;

  @override
  void dispose() {
    passwordActualController.dispose();
    nuevaPasswordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  bool passwordSegura(String password) {
    return password.length >= 8 &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password);
  }

  Future<void> cambiarPassword() async {
    final passwordActual =
        passwordActualController.text;

    final nuevaPassword =
        nuevaPasswordController.text;

    final confirmarPassword =
        confirmarPasswordController.text;

    if (passwordActual.isEmpty ||
        nuevaPassword.isEmpty ||
        confirmarPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todos los campos son obligatorios',
          ),
        ),
      );
      return;
    }

    if (!passwordSegura(nuevaPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La nueva contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial',
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
      guardando = true;
    });

    final resultado =
        await ApiService.cambiarPassword(
      passwordActual,
      nuevaPassword,
      confirmarPassword,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      guardando = false;
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
      final data = resultado['data'];

      String mensaje =
          'No se pudo actualizar la contraseña';

      if (data is Map &&
          data['mensaje'] != null) {
        mensaje = data['mensaje'].toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cambiar contraseña',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Seguridad de tu cuenta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Ingresa tu contraseña actual y crea una nueva contraseña segura.',
              style: TextStyle(
                fontSize: 15,
                color: OfixColors.textSecondary,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller:
                  passwordActualController,
              obscureText:
                  !mostrarPasswordActual,

              decoration: InputDecoration(
                labelText:
                    'Contraseña actual',

                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      mostrarPasswordActual =
                          !mostrarPasswordActual;
                    });
                  },
                  icon: Icon(
                    mostrarPasswordActual
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),

                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  nuevaPasswordController,
              obscureText:
                  !mostrarNuevaPassword,

              onChanged: (_) {
                setState(() {});
              },

              decoration: InputDecoration(
                labelText:
                    'Nueva contraseña',

                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      mostrarNuevaPassword =
                          !mostrarNuevaPassword;
                    });
                  },
                  icon: Icon(
                    mostrarNuevaPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),

                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            _buildPasswordRequirements(),

            const SizedBox(height: 16),

            TextField(
              controller:
                  confirmarPasswordController,
              obscureText:
                  !mostrarConfirmarPassword,

              decoration: InputDecoration(
                labelText:
                    'Confirmar nueva contraseña',

                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      mostrarConfirmarPassword =
                          !mostrarConfirmarPassword;
                    });
                  },
                  icon: Icon(
                    mostrarConfirmarPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),

                border:
                    const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    guardando
                        ? null
                        : cambiarPassword,

                child: guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Cambiar contraseña',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final password =
        nuevaPasswordController.text;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: OfixColors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'La contraseña debe tener:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  OfixColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          _buildRequirement(
            'Mínimo 8 caracteres',
            password.length >= 8,
          ),

          _buildRequirement(
            'Una letra mayúscula',
            RegExp(r'[A-Z]')
                .hasMatch(password),
          ),

          _buildRequirement(
            'Una letra minúscula',
            RegExp(r'[a-z]')
                .hasMatch(password),
          ),

          _buildRequirement(
            'Un número',
            RegExp(r'[0-9]')
                .hasMatch(password),
          ),

          _buildRequirement(
            'Un carácter especial',
            RegExp(
              r'[^A-Za-z0-9]',
            ).hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(
    String text,
    bool cumplido,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 6,
      ),

      child: Row(
        children: [
          Icon(
            cumplido
                ? Icons.check_circle
                : Icons.circle_outlined,

            size: 18,

            color: cumplido
                ? OfixColors.success
                : OfixColors.textSecondary,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: cumplido
                    ? OfixColors.success
                    : OfixColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}