import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Misma política de contraseña que el backend.
  static final RegExp _passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).+$');
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _profesionController = TextEditingController();
  final _anosController = TextEditingController();
  final _zonaController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _rol = 'CLIENTE'; // 'CLIENTE' o 'TRABAJADOR'
  bool _verPassword = false;
  bool _enviando = false;

  List<Map<String, dynamic>> _categorias = [];
  final Set<int> _categoriasSeleccionadas = {};
  bool _cargandoCategorias = false;
  String? _errorCategorias;

  bool get _esProfesional => _rol == 'TRABAJADOR';

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _profesionController.dispose();
    _anosController.dispose();
    _zonaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _cargandoCategorias = true;
      _errorCategorias = null;
    });

    try {
      final categorias = await ApiService.listarCategoriasPublicas();
      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        _cargandoCategorias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorCategorias = 'No se pudieron cargar las categorías.';
        _cargandoCategorias = false;
      });
    }
  }

  void _cambiarRol(String rol) {
    setState(() => _rol = rol);
    // Las categorías solo se necesitan para profesionales.
    if (rol == 'TRABAJADOR' && _categorias.isEmpty && !_cargandoCategorias) {
      _cargarCategorias();
    }
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  // Devuelve el primer error encontrado o null si todo está bien.
  String? _validar() {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmar = _confirmController.text;

    if (nombre.isEmpty || apellido.isEmpty) {
      return 'Ingresa tu nombre y apellido';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Ingresa un correo electrónico válido';
    }
    if (password.length < 8 || !_passwordRegex.hasMatch(password)) {
      return 'La contraseña debe tener mínimo 8 caracteres, con mayúscula, '
          'minúscula, número y símbolo';
    }
    if (password != confirmar) {
      return 'Las contraseñas no coinciden';
    }

    if (_esProfesional) {
      if (_profesionController.text.trim().isEmpty) {
        return 'Indica tu profesión u oficio';
      }
      final anos = int.tryParse(_anosController.text.trim());
      if (anos == null || anos < 0 || anos > 60) {
        return 'Los años de experiencia deben estar entre 0 y 60';
      }
      if (_zonaController.text.trim().isEmpty) {
        return 'Indica tu zona de trabajo';
      }
      if (_categoriasSeleccionadas.isEmpty) {
        return 'Selecciona al menos una categoría de servicio';
      }
    }
    return null;
  }

  Future<void> _registrar() async {
    final error = _validar();
    if (error != null) {
      _mostrarMensaje(error);
      return;
    }

    setState(() => _enviando = true);

    try {
      final resultado = await ApiService.registrarUsuario(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rol: _rol,
        profesion: _profesionController.text.trim(),
        anosExperiencia: int.tryParse(_anosController.text.trim()),
        descripcionProfesional: _descripcionController.text.trim(),
        zonaTrabajo: _zonaController.text.trim(),
        categoriaIds: _categoriasSeleccionadas.toList(),
      );

      if (!mounted) return;

      final status = resultado['statusCode'] as int;
      final data = resultado['data'];

      if (status == 200 || status == 201) {
        _mostrarMensaje('Cuenta creada. Ya puedes iniciar sesión.');
        Navigator.pop(context, true);
        return;
      }

      _mostrarMensaje(_textoDeError(data));
    } catch (_) {
      if (!mounted) return;
      _mostrarMensaje(
          'No se pudo conectar con el servidor. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // Convierte la respuesta 400 del backend en un texto legible.
  String _textoDeError(dynamic data) {
    if (data is Map) {
      final errores = data['errores'];
      if (errores is Map && errores.isNotEmpty) {
        return errores.values.first.toString();
      }
      if (data['mensaje'] != null) {
        return data['mensaje'].toString();
      }
    }
    return 'No se pudo crear la cuenta.';
  }

  InputDecoration _decoracion(String etiqueta, {Widget? sufijo}) {
    return InputDecoration(
      labelText: etiqueta,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: sufijo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    TextInputType? teclado,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: _decoracion(etiqueta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OfixColors.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: OfixColors.background,
        foregroundColor: OfixColors.darkBlue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '¿Cómo quieres usar Ofix?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: OfixColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'CLIENTE',
                        label: Text('Necesito un servicio'),
                        icon: Icon(Icons.person_outline),
                      ),
                      ButtonSegment(
                        value: 'TRABAJADOR',
                        label: Text('Soy profesional'),
                        icon: Icon(Icons.handyman_outlined),
                      ),
                    ],
                    selected: {_rol},
                    onSelectionChanged: (seleccion) =>
                        _cambiarRol(seleccion.first),
                  ),
                  const SizedBox(height: 24),

                  _campo(_nombreController, 'Nombre'),
                  _campo(_apellidoController, 'Apellido'),
                  _campo(_emailController, 'Correo electrónico',
                      teclado: TextInputType.emailAddress),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: !_verPassword,
                      decoration: _decoracion(
                        'Contraseña',
                        sufijo: IconButton(
                          icon: Icon(_verPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _verPassword = !_verPassword),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: TextField(
                      controller: _confirmController,
                      obscureText: !_verPassword,
                      decoration: _decoracion('Confirmar contraseña'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18, left: 4),
                    child: Text(
                      'Mínimo 8 caracteres, con mayúscula, minúscula, '
                      'número y símbolo.',
                      style: TextStyle(
                        fontSize: 12,
                        color: OfixColors.textSecondary,
                      ),
                    ),
                  ),

                  if (_esProfesional) ..._seccionProfesional(),

                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _enviando ? null : _registrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OfixColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _enviando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Crear cuenta'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _seccionProfesional() {
    return [
      const Divider(height: 32),
      const Text(
        'Tu perfil profesional',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: OfixColors.textPrimary,
        ),
      ),
      const SizedBox(height: 14),
      _campo(_profesionController, 'Profesión u oficio (ej. Plomero)'),
      _campo(_anosController, 'Años de experiencia',
          teclado: TextInputType.number),
      _campo(_zonaController, 'Zona de trabajo (ej. Laureles, Medellín)'),
      _campo(_descripcionController, 'Descripción (opcional)',
          maxLines: 3, maxLength: 500),
      const SizedBox(height: 4),
      const Text(
        'Categorías en las que trabajas',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: OfixColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      _bloqueCategorias(),
      const SizedBox(height: 18),
    ];
  }

  Widget _bloqueCategorias() {
    if (_cargandoCategorias) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorCategorias != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _errorCategorias!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: _cargarCategorias,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categorias.map((categoria) {
        final id = (categoria['id'] as num).toInt();
        final seleccionada = _categoriasSeleccionadas.contains(id);
        return FilterChip(
          label: Text(categoria['nombre'].toString()),
          selected: seleccionada,
          onSelected: (valor) {
            setState(() {
              if (valor) {
                _categoriasSeleccionadas.add(id);
              } else {
                _categoriasSeleccionadas.remove(id);
              }
            });
          },
        );
      }).toList(),
    );
  }
}