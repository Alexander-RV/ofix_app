import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'my_offers_page.dart';
import 'my_services_page.dart';
import 'profile_page.dart';
import 'service_offers_page.dart' show formatearPrecio;

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  late Future<List<dynamic>> serviciosFuture;

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
  }

  Future<List<dynamic>> cargarServicios() async {
    final resultado = await ApiService.listarServiciosDisponibles();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron cargar los servicios');
    }

    return resultado['data'];
  }

  void _refrescar() {
    setState(() {
      serviciosFuture = cargarServicios();
    });
  }

  Future<void> _abrirPagina(Widget pagina) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pagina),
    );

    if (!mounted) {
      return;
    }

    _refrescar();
  }

  String _formatearFecha(dynamic valor) {
    final fecha = DateTime.tryParse('$valor');

    if (fecha == null) {
      return '';
    }

    String dos(int n) => n.toString().padLeft(2, '0');

    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
        '${dos(fecha.hour)}:${dos(fecha.minute)}';
  }

  Future<void> _enviarOferta(dynamic servicio) async {
    final enviada = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EnviarOfertaDialog(servicio: servicio),
    );

    if (enviada != true || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oferta enviada correctamente')),
    );

    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OFIX - Trabajador'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refrescar();
          await serviciosFuture;
        },
        child: FutureBuilder<List<dynamic>>(
          future: serviciosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(40),
                children: const [
                  Text(
                    'No se pudieron cargar los servicios',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: OfixColors.error),
                  ),
                ],
              );
            }

            final servicios = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Solicitudes para ti',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Solicitudes de tus categorías. Envía tu mejor oferta.',
                  style: TextStyle(
                    fontSize: 16,
                    color: OfixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (servicios.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay solicitudes disponibles en tus categorías '
                      'por ahora. Desliza hacia abajo para actualizar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: OfixColors.textSecondary),
                    ),
                  ),
                ...servicios.map(
                  (servicio) => _buildServicioCard(servicio),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Mis ofertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Mis servicios',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            _abrirPagina(const MyOffersPage());
          }

          if (index == 2) {
            _abrirPagina(const MyServicesPage());
          }

          if (index == 3) {
            _abrirPagina(const ProfilePage());
          }
        },
      ),
    );
  }

  Widget _buildServicioCard(dynamic servicio) {
    final yaOfertado = servicio['yaOfertado'] == true;
    final totalOfertas = servicio['totalOfertas'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OfixColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            servicio['titulo'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: OfixColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            servicio['descripcion'] ?? '',
            style: const TextStyle(color: OfixColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 18,
                color: OfixColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                servicio['categoriaNombre'] ?? '',
                style: const TextStyle(color: OfixColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: OfixColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  servicio['direccion'] ?? '',
                  style: const TextStyle(color: OfixColors.textPrimary),
                ),
              ),
            ],
          ),
          if (servicio['fechaProgramada'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 18,
                  color: OfixColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(servicio['fechaProgramada']),
                  style: const TextStyle(color: OfixColors.textPrimary),
                ),
              ],
            ),
          ],
          if (servicio['presupuesto'] != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: OfixColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Presupuesto del cliente: '
                  '${formatearPrecio(servicio['presupuesto'])}',
                  style: const TextStyle(
                    color: OfixColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            totalOfertas == 1
                ? '1 oferta recibida'
                : '$totalOfertas ofertas recibidas',
            style: const TextStyle(
              fontSize: 13,
              color: OfixColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: yaOfertado
                ? const OutlinedButton(
                    onPressed: null,
                    child: Text('Oferta enviada'),
                  )
                : FilledButton.icon(
                    onPressed: () => _enviarOferta(servicio),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Enviar oferta'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EnviarOfertaDialog extends StatefulWidget {
  final Map<String, dynamic> servicio;

  const _EnviarOfertaDialog({required this.servicio});

  @override
  State<_EnviarOfertaDialog> createState() => _EnviarOfertaDialogState();
}

class _EnviarOfertaDialogState extends State<_EnviarOfertaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final _mensajeController = TextEditingController();

  bool enviando = false;
  String? errorServidor;

  @override
  void dispose() {
    _precioController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      enviando = true;
      errorServidor = null;
    });

    final precio = int.parse(_precioController.text.trim());

    final resultado = await ApiService.crearOferta(
      widget.servicio['id'],
      precio,
      _mensajeController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    final codigo = resultado['statusCode'];

    if (codigo == 200 || codigo == 201) {
      Navigator.pop(context, true);
      return;
    }

    final data = resultado['data'];

    setState(() {
      enviando = false;
      errorServidor = (data is Map && data['mensaje'] != null)
          ? data['mensaje'].toString()
          : 'No se pudo enviar la oferta';
    });
  }

  @override
  Widget build(BuildContext context) {
    final presupuesto = widget.servicio['presupuesto'];

    return AlertDialog(
      title: const Text('Enviar oferta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.servicio['titulo'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (presupuesto != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Presupuesto del cliente: ${formatearPrecio(presupuesto)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: OfixColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tu precio (COP)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final texto = (valor ?? '').trim();

                  if (texto.isEmpty) {
                    return 'Ingresa tu precio';
                  }

                  final numero = int.tryParse(texto);

                  if (numero == null || numero <= 0) {
                    return 'Debe ser mayor que cero';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mensajeController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Mensaje para el cliente (opcional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              if (errorServidor != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorServidor!,
                  style: const TextStyle(color: OfixColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: enviando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: enviando ? null : _enviar,
          child: enviando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar'),
        ),
      ],
    );
  }
}