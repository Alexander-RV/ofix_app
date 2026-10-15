import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CreateServicePage extends StatefulWidget {
  const CreateServicePage({super.key});

  @override
  State<CreateServicePage> createState() => _CreateServicePageState();
}

class _CreateServicePageState extends State<CreateServicePage> {
  final TextEditingController descripcionController =
      TextEditingController();

  final TextEditingController direccionController =
      TextEditingController();

  final TextEditingController presupuestoController =
      TextEditingController();

  List<Map<String, dynamic>> categorias = [];
  int? categoriaId;
  bool cargandoCategorias = true;
  String? errorCategorias;

  DateTime? fecha;
  TimeOfDay? hora;

  // 0 = Detalles, 1 = Confirmación, 2 = Enviado
  int paso = 0;
  bool enviando = false;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  @override
  void dispose() {
    descripcionController.dispose();
    direccionController.dispose();
    presupuestoController.dispose();
    super.dispose();
  }

  Future<void> cargarCategorias() async {
    setState(() {
      cargandoCategorias = true;
      errorCategorias = null;
    });

    try {
      final lista = await ApiService.listarCategoriasPublicas();

      if (!mounted) {
        return;
      }

      setState(() {
        categorias = lista;
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

  // ---------- utilidades ----------

  DateTime? get fechaHora {
    if (fecha == null || hora == null) {
      return null;
    }

    return DateTime(
      fecha!.year,
      fecha!.month,
      fecha!.day,
      hora!.hour,
      hora!.minute,
    );
  }

  String nombreCategoria() {
    final categoria = categorias.firstWhere(
      (c) => (c['id'] as num).toInt() == categoriaId,
      orElse: () => {'nombre': ''},
    );

    return categoria['nombre'].toString();
  }

  String formatoFecha(DateTime d) {
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');

    return '$dia/$mes/${d.year}';
  }

  String formatoPesos(int valor) {
    final texto = valor.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(texto[i]);
    }

    return '\$ ${buffer.toString()}';
  }

  // Solo dígitos del campo de presupuesto (null si está vacío).
  int? presupuestoIngresado() {
    final soloDigitos =
        presupuestoController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (soloDigitos.isEmpty) {
      return null;
    }

    return int.tryParse(soloDigitos);
  }

  // El título se arma con la categoría y el inicio de la descripción.
  String generarTitulo() {
    var resumen = descripcionController.text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    if (resumen.length > 60) {
      resumen = resumen.substring(0, 60);

      final corte = resumen.lastIndexOf(' ');
      if (corte > 20) {
        resumen = resumen.substring(0, corte);
      }

      resumen = '$resumen…';
    }

    var titulo = '${nombreCategoria()}: $resumen';

    if (titulo.length > 120) {
      titulo = titulo.substring(0, 120);
    }

    return titulo;
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

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

    return 'No se pudo crear la solicitud';
  }

  // ---------- acciones ----------

  Future<void> elegirFecha() async {
    final ahora = DateTime.now();

    final elegida = await showDatePicker(
      context: context,
      initialDate: fecha ?? ahora,
      firstDate: DateTime(ahora.year, ahora.month, ahora.day),
      lastDate: ahora.add(const Duration(days: 365)),
    );

    if (!mounted || elegida == null) {
      return;
    }

    setState(() {
      fecha = elegida;
    });
  }

  Future<void> elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: hora ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (!mounted || elegida == null) {
      return;
    }

    setState(() {
      hora = elegida;
    });
  }

  // Devuelve el primer error de validación o null si todo está bien.
  String? validarDetalles() {
    if (categoriaId == null) {
      return 'Selecciona el tipo de servicio';
    }

    if (descripcionController.text.trim().isEmpty) {
      return 'Cuéntanos qué necesitas';
    }

    if (direccionController.text.trim().isEmpty) {
      return 'Indica la ubicación del servicio';
    }

    if ((fecha == null) != (hora == null)) {
      return 'Selecciona la fecha y la hora, o deja ambas vacías';
    }

    final programada = fechaHora;
    if (programada != null && programada.isBefore(DateTime.now())) {
      return 'La fecha y la hora deben ser futuras';
    }

    final textoPresupuesto = presupuestoController.text.trim();
    if (textoPresupuesto.isNotEmpty) {
      final valor = presupuestoIngresado();

      if (valor == null || valor <= 0) {
        return 'El presupuesto debe ser mayor que cero';
      }
    }

    return null;
  }

  void continuar() {
    final error = validarDetalles();

    if (error != null) {
      mostrarMensaje(error);
      return;
    }

    setState(() {
      paso = 1;
    });
  }

  Future<void> enviar() async {
    setState(() {
      enviando = true;
    });

    try {
      final resultado = await ApiService.crearServicio(
        generarTitulo(),
        descripcionController.text.trim(),
        direccionController.text.trim(),
        categoriaId!,
        fechaProgramada: fechaHora,
        presupuesto: presupuestoIngresado(),
      );

      if (!mounted) {
        return;
      }

      if (resultado['statusCode'] == 200) {
        setState(() {
          paso = 2;
        });
      } else {
        mostrarMensaje(textoDeError(resultado['data']));
      }
    } catch (_) {
      if (mounted) {
        mostrarMensaje(
          'No se pudo conectar con el servidor. Intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  // ---------- interfaz ----------

  InputDecoration decoracion(
    String etiqueta, {
    String? hint,
    IconData? icono,
    String? prefijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: hint,
      prefixText: prefijo,
      prefixIcon: icono == null ? null : Icon(icono),
      filled: true,
      fillColor: OfixColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget indicadorPasos() {
    const etiquetas = ['Detalles', 'Confirmación', 'Enviado'];
    final inactivo = OfixColors.textSecondary.withValues(alpha: 0.25);
    final items = <Widget>[];

    for (var i = 0; i < 3; i++) {
      final activo = i <= paso;

      items.add(
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: activo ? OfixColors.primary : inactivo,
              child: i < paso
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: activo
                            ? Colors.white
                            : OfixColors.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              etiquetas[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: activo
                    ? OfixColors.primary
                    : OfixColors.textSecondary,
              ),
            ),
          ],
        ),
      );

      if (i < 2) {
        items.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Divider(
                thickness: 2,
                color: i < paso ? OfixColors.primary : inactivo,
              ),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget campoSeleccion({
    required String etiqueta,
    required String texto,
    required bool vacio,
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: decoracion(etiqueta, icono: icono),
        child: Text(
          texto,
          style: TextStyle(
            color: vacio
                ? OfixColors.textSecondary
                : OfixColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget pasoDetalles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Solicitar servicio',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: OfixColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Completa la información para enviar tu solicitud.',
          style: TextStyle(
            fontSize: 16,
            color: OfixColors.textSecondary,
          ),
        ),

        const SizedBox(height: 24),

        if (cargandoCategorias)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorCategorias != null)
          Row(
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
          )
        else
          DropdownButtonFormField<int>(
            initialValue: categoriaId,
            decoration: decoracion(
              'Servicio',
              icono: Icons.category_outlined,
            ),
            items: categorias.map((c) {
              return DropdownMenuItem<int>(
                value: (c['id'] as num).toInt(),
                child: Text(c['nombre'].toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                categoriaId = value;
              });
            },
          ),

        const SizedBox(height: 16),

        TextField(
          controller: descripcionController,
          maxLines: 4,
          maxLength: 300,
          decoration: decoracion(
            '¿Qué necesitas?',
            hint: 'Describe tu problema con el mayor detalle posible.',
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: direccionController,
          decoration: decoracion(
            'Ubicación',
            hint: 'Ej. Calle 10 #40-20, Medellín',
            icono: Icons.location_on_outlined,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: campoSeleccion(
                etiqueta: 'Fecha (opcional)',
                texto: fecha == null
                    ? 'Seleccionar'
                    : formatoFecha(fecha!),
                vacio: fecha == null,
                icono: Icons.calendar_today_outlined,
                onTap: elegirFecha,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: campoSeleccion(
                etiqueta: 'Hora (opcional)',
                texto: hora == null
                    ? 'Seleccionar'
                    : hora!.format(context),
                vacio: hora == null,
                icono: Icons.schedule_outlined,
                onTap: elegirHora,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextField(
          controller: presupuestoController,
          keyboardType: TextInputType.number,
          decoration: decoracion(
            'Presupuesto aproximado (opcional)',
            hint: '80000',
            prefijo: '\$ ',
          ),
        ),

        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: cargandoCategorias ? null : continuar,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget filaResumen(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              color: OfixColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: OfixColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget pasoConfirmacion() {
    final programada = fechaHora;
    final presupuesto = presupuestoIngresado();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirma tu solicitud',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: OfixColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Revisa que todo esté bien antes de enviarla.',
          style: TextStyle(
            fontSize: 16,
            color: OfixColors.textSecondary,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: OfixColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filaResumen('Servicio', nombreCategoria()),
              filaResumen(
                'Descripción',
                descripcionController.text.trim(),
              ),
              filaResumen(
                'Ubicación',
                direccionController.text.trim(),
              ),
              filaResumen(
                'Fecha y hora',
                programada == null
                    ? 'Sin definir'
                    : '${formatoFecha(programada)} · ${hora!.format(context)}',
              ),
              filaResumen(
                'Presupuesto aproximado',
                presupuesto == null
                    ? 'A convenir'
                    : formatoPesos(presupuesto),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Al enviarla, los profesionales de esta categoría podrán '
          'verla y enviarte ofertas. Tú decides cuál aceptar.',
          style: TextStyle(color: OfixColors.textSecondary),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: enviando ? null : enviar,
          child: enviando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar solicitud'),
        ),

        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: enviando
              ? null
              : () {
                  setState(() {
                    paso = 0;
                  });
                },
          child: const Text('Editar'),
        ),
      ],
    );
  }

  Widget pasoEnviado() {
    return Column(
      children: [
        const SizedBox(height: 24),

        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: OfixColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 52,
            color: OfixColors.success,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          '¡Solicitud enviada!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: OfixColors.textPrimary,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Los profesionales ya pueden ver tu solicitud. '
          'Te mostraremos aquí las ofertas que recibas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: OfixColors.textSecondary,
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Ver mis solicitudes'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar servicio'),
        automaticallyImplyLeading: paso != 2,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                indicadorPasos(),

                const SizedBox(height: 28),

                if (paso == 0) pasoDetalles(),
                if (paso == 1) pasoConfirmacion(),
                if (paso == 2) pasoEnviado(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}