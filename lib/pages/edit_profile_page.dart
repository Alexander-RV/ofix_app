import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> perfil;

  const EditProfilePage({
    super.key,
    required this.perfil,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.perfil['nombre'] ?? '',
    );

    apellidoController = TextEditingController(
      text: widget.perfil['apellido'] ?? '',
    );

    emailController = TextEditingController(
      text: widget.perfil['email'] ?? '',
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> guardarCambios() async {
    if (nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Todos los campos son obligatorios',
          ),
        ),
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    final resultado = await ApiService.actualizarMiPerfil(
      nombreController.text.trim(),
      apellidoController.text.trim(),
      emailController.text.trim(),
    );

    

    if (!mounted) {
      return;
    }

    setState(() {
      guardando = false;
    });

    if (resultado['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perfil actualizado correctamente',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar el perfil',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actualiza tus datos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Modifica la información de tu perfil.',
              style: TextStyle(
                fontSize: 15,
                color: OfixColors.textSecondary,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nombreController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: apellidoController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardando ? null : guardarCambios,
                child: guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}