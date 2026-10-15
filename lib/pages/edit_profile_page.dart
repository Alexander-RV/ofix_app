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

  // Datos profesionales (solo para TRABAJADOR)
  late TextEditingController profesionController;
  late TextEditingController anosController;
  late TextEditingController zonaController;
  late TextEditingController descripcionController;

  List<Map<String, dynamic>> categorias = [];
  final Set<int> categoriasSeleccionadas = {};
  bool cargandoCategorias = false;
  String? errorCategorias;

  bool guardando = false;

  bool get esProfesional => widget.perfil['rol'] == 'TRABAJADOR';

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

    profesionController = TextEditingController(
      text: widget.perfil['profesion'] ?? '',
    );

    anosController = TextEditingController(
      text: '${widget.perfil['anosExperiencia'] ?? ''}',
    );

    zonaController = TextEditingController(
      text: widget.perfil['zonaTrabajo'] ?? '',
    );

    descripcionController = TextEditingController(
      text: widget.perfil['descripcionProfesional'] ?? '',
    );

    if (esProfesional) {
      cargarCategorias();
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    profesionController.dispose();
    anosController.dispose();
    zonaController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  // Carga las categorías activas y marca las que el profesional ya tiene.
  Future<void> cargarCategorias() async {
    setState(() {
      cargandoCategorias = true;
      errorCategorias = null;
    });

    try {
      final lista = await ApiService.listarCategoriasPublicas();

      // El perfil trae los nombres; los emparejamos con sus ids.
      final nombresActuales = ((widget.perfil['categorias'] as List?) ?? [])
          .map((e) => e.toString())
          .toSet();

      if (!mounted) {
        return;
      }

      setState(() {
        categorias = lista;
        categoriasSeleccionadas
          ..clear()
          ..addAll(
            lista
                .where((c) => nombresActuales.contains(c['nombre']))
                .map((c) => (c['id'] as num).toInt()),
          );
        cargandoCategorias = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorCategorias = 'No se pudieron cargar las categorías.';
        cargandoCategorias = false;
      });
    }
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  // Devuelve el primer error de validación o null si todo está bien.
  String? validar() {
    if (nombreController.text.trim().isEmpty ||
        apellidoController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      return 'Nombre, apellido y correo son obligatorios';
    }

    if (esProfesional) {
      if (profesionController.text.trim().isEmpty) {
        return 'Indica tu profesión u oficio';
      }

      final anos = int.tryParse(anosController.text.trim());
      if (anos == null || anos < 0 || anos > 60) {
        return 'Los años de experiencia deben estar entre 0 y 60';
      }

      if (zonaController.text.trim().isEmpty) {
        return 'Indica tu zona de trabajo';
      }

      if (categoriasSeleccionadas.isEmpty) {
        return 'Selecciona al menos una categoría de servicio';
      }
    }

    return null;
  }

  // Convierte la respuesta de error del backend en un texto legible.
  String textoDeError(dynamic data) {
    if (data is Map) {
      final errores = data['errores'];

      if (errores is Map && errores.isNotEmpty) {
        return errores.values.first.toString();
      }

      if (data['mensaje'] != null) {
        return data['mensaje'].toString();
      }
    }

    return 'No se pudo actualizar el perfil';
  }

  Future<void> guardarCambios() async {
    final error = validar();

    if (error != null) {
      mostrarMensaje(error);
      return;
    }

    setState(() {
      guardando = true;
    });

    final resultado = await ApiService.actualizarMiPerfil(
      nombreController.text.trim(),
      apellidoController.text.trim(),
      emailController.text.trim(),
      profesion: esProfesional ? profesionController.text.trim() : null,
      anosExperiencia: esProfesional
          ? int.tryParse(anosController.text.trim())
          : null,
      descripcionProfesional:
          esProfesional ? descripcionController.text.trim() : null,
      zonaTrabajo: esProfesional ? zonaController.text.trim() : null,
      categoriaIds:
          esProfesional ? categoriasSeleccionadas.toList() : null,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      guardando = false;
    });

    if (resultado['statusCode'] == 200) {
      mostrarMensaje('Perfil actualizado correctamente');

      Navigator.pop(context, true);
    } else {
      mostrarMensaje(textoDeError(resultado['data']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
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
                  textInputAction: esProfesional
                      ? TextInputAction.next
                      : TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                if (esProfesional) ...seccionProfesional(),

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
        ),
      ),
    );
  }

  List<Widget> seccionProfesional() {
    return [
      const SizedBox(height: 30),

      const Text(
        'Perfil profesional',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: OfixColors.textPrimary,
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: profesionController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Profesión u oficio',
          prefixIcon: Icon(Icons.handyman_outlined),
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: anosController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Años de experiencia',
          prefixIcon: Icon(Icons.timeline),
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: zonaController,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Zona de trabajo',
          prefixIcon: Icon(Icons.location_on_outlined),
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 16),

      TextField(
        controller: descripcionController,
        maxLines: 3,
        maxLength: 500,
        decoration: const InputDecoration(
          labelText: 'Descripción (opcional)',
          prefixIcon: Icon(Icons.notes_outlined),
          border: OutlineInputBorder(),
        ),
      ),

      const SizedBox(height: 8),

      const Text(
        'Categorías en las que trabajas',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: OfixColors.textPrimary,
        ),
      ),

      const SizedBox(height: 8),

      bloqueCategorias(),
    ];
  }

  Widget bloqueCategorias() {
    if (cargandoCategorias) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorCategorias != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              errorCategorias!,
              style: const TextStyle(color: OfixColors.error),
            ),
          ),
          TextButton(
            onPressed: cargarCategorias,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categorias.map((categoria) {
        final id = (categoria['id'] as num).toInt();

        return FilterChip(
          label: Text(categoria['nombre'].toString()),
          selected: categoriasSeleccionadas.contains(id),
          onSelected: (valor) {
            setState(() {
              if (valor) {
                categoriasSeleccionadas.add(id);
              } else {
                categoriasSeleccionadas.remove(id);
              }
            });
          },
        );
      }).toList(),
    );
  }
}