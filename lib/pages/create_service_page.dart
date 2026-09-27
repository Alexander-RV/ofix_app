import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class CreateServicePage extends StatefulWidget {
  const CreateServicePage({super.key});

  @override
  State<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  final TextEditingController tituloController =
      TextEditingController();

  final TextEditingController descripcionController =
      TextEditingController();

  final TextEditingController direccionController =
      TextEditingController();

  String? categoriaSeleccionada;

  final Map<String, int> categorias = {
    'Plomería': 2,
    'Carpintería': 3,
    'Pintura': 4,
    'Electricidad': 5,
    'Limpieza': 6,
  };

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar servicio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué necesitas?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Describe el servicio que necesitas para tu hogar.',
              style: TextStyle(
                fontSize: 16,
                color: OfixColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Título',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                hintText: 'Ej. Reparación de una fuga',
                filled: true,
                fillColor: OfixColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Descripción',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe detalladamente el problema...',
                filled: true,
                fillColor: OfixColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Dirección',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: direccionController,
              decoration: InputDecoration(
                hintText: 'Ej. Medellín, Antioquia',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                ),
                filled: true,
                fillColor: OfixColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Categoría',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: OfixColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: categoriaSeleccionada,
              decoration: InputDecoration(
                hintText: 'Selecciona una categoría',
                filled: true,
                fillColor: OfixColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: categorias.keys.map((categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  categoriaSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (tituloController.text.trim().isEmpty ||
                      descripcionController.text.trim().isEmpty ||
                      direccionController.text.trim().isEmpty ||
                      categoriaSeleccionada == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                      ),
                    );
                    return;
                  }

                  final categoriaId =
                      categorias[categoriaSeleccionada!]!;

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  final resultado =
                      await ApiService.crearServicio(
                    tituloController.text.trim(),
                    descripcionController.text.trim(),
                    direccionController.text.trim(),
                    categoriaId,
                  );

            
                  if (!mounted) {
                    return;
                  }

                  if (resultado['statusCode'] == 200) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Servicio solicitado correctamente',
                        ),
                      ),
                    );

                    navigator.pop();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No se pudo crear el servicio',
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Solicitar servicio',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}