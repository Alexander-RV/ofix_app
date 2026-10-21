import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ofix_widgets.dart';
import '../widgets/servicio_utils.dart';
import 'service_offers_page.dart';

class MyClientServicesPage extends StatefulWidget {
  const MyClientServicesPage({super.key});

  @override
  State<MyClientServicesPage> createState() => _MyClientServicesPageState();
}

class _MyClientServicesPageState extends State<MyClientServicesPage> {
  late Future<List<dynamic>> serviciosFuture;

  // Filtro activo: TODOS o un estado del servicio
  String filtro = 'TODOS';

  // (valor del estado, texto del chip)
  static const List<(String, String)> _filtros = [
    ('TODOS', 'Todos'),
    ('PENDIENTE', 'Pendientes'),
    ('EN_PROCESO', 'En progreso'),
    ('COMPLETADO', 'Completados'),
    ('CANCELADO', 'Cancelados'),
  ];

  @override
  void initState() {
    super.initState();
    serviciosFuture = cargarServicios();
  }

  // Trae los servicios del cliente, del más reciente al más antiguo
  Future<List<dynamic>> cargarServicios() async {
    final resultado = await ApiService.listarServicios();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron cargar tus servicios');
    }

    final lista = List<dynamic>.from(resultado['data']);

    lista.sort(
      (a, b) => ((b['id'] ?? 0) as num).compareTo((a['id'] ?? 0) as num),
    );

    return lista;
  }

  void _recargar() {
    setState(() {
      serviciosFuture = cargarServicios();
    });
  }

  // Pide confirmación y cancela el servicio
  Future<void> _cancelar(dynamic servicio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar la solicitud?'),
        content: const Text(
          'Se rechazarán las ofertas pendientes y la solicitud dejará '
          'de estar disponible para los profesionales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: OfixColors.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    final resultado = await ApiService.cancelarServicio(servicio['id']);

    if (!mounted) {
      return;
    }

    if (resultado['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio cancelado correctamente')),
      );

      _recargar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cancelar el servicio')),
      );
    }
  }

  // Abre las ofertas de la solicitud y refresca al volver
  Future<void> _verOfertas(dynamic servicio) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceOffersPage(servicio: servicio),
      ),
    );

    if (!mounted) {
      return;
    }

    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: serviciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No se pudieron cargar tus solicitudes',
                    style: TextStyle(color: OfixColors.error),
                  ),
                  TextButton(
                    onPressed: _recargar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final todos = snapshot.data ?? [];

          // Aplica el filtro elegido
          final servicios = filtro == 'TODOS'
              ? todos
              : todos.where((s) => s['estado'] == filtro).toList();

          return OfixMaxWidth(
            maxWidth: 760,
            child: RefreshIndicator(
              onRefresh: () async {
                _recargar();
                await serviciosFuture;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _filtrosEstado(),
                  const SizedBox(height: 16),
                  if (servicios.isEmpty)
                    OfixEmptyState(
                      icono: Icons.assignment_outlined,
                      mensaje: todos.isEmpty
                          ? 'No tienes solicitudes registradas.'
                          : 'No tienes solicitudes en este estado.',
                    )
                  else
                    ...servicios.map(_buildServicioCard),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Fila de chips para filtrar por estado
  Widget _filtrosEstado() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _filtros)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.$2),
                selected: filtro == f.$1,
                showCheckmark: false,
                backgroundColor: OfixColors.white,
                selectedColor: OfixColors.primarySoft,
                side: const BorderSide(color: OfixColors.border),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: filtro == f.$1
                      ? OfixColors.primary
                      : OfixColors.textSecondary,
                ),
                onSelected: (_) {
                  setState(() {
                    filtro = f.$1;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // Línea con icono y texto dentro de la tarjeta
  Widget _dato(IconData icono, String texto, {bool fuerte = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, size: 18, color: OfixColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: OfixColors.textPrimary,
                fontWeight: fuerte ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicioCard(dynamic servicio) {
    final categoria = (servicio['categoriaNombre'] ?? '').toString();
    final estado = (servicio['estado'] ?? '').toString();
    final descripcion = (servicio['descripcion'] ?? '').toString();
    final (color, fondo) = colorCategoria(categoria);
    final fecha = formatearFechaServicio(servicio['fechaProgramada']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: OfixCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: icono, título/categoría y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: fondo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconoCategoria(categoria), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (servicio['titulo'] ?? '').toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoria,
                        style: const TextStyle(
                          fontSize: 13,
                          color: OfixColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                EstadoChip(estado),
              ],
            ),

            if (descripcion.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                descripcion,
                style: const TextStyle(
                  color: OfixColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 14),

            _dato(
              Icons.location_on_outlined,
              (servicio['direccion'] ?? '').toString(),
            ),

            if (fecha != null) _dato(Icons.event_outlined, fecha),

            if (servicio['trabajadorNombre'] != null)
              _dato(
                Icons.person_outline,
                'Profesional: ${servicio['trabajadorNombre']}',
              ),

            // Si ya hay precio acordado se muestra ese; si no, el presupuesto
            if (servicio['precioAcordado'] != null)
              _dato(
                Icons.payments_outlined,
                'Precio acordado: '
                '${formatearPrecio(servicio['precioAcordado'])}',
                fuerte: true,
              )
            else if (servicio['presupuesto'] != null)
              _dato(
                Icons.savings_outlined,
                'Tu presupuesto: ${formatearPrecio(servicio['presupuesto'])}',
              ),

            // Acciones solo para solicitudes pendientes
            if (estado == 'PENDIENTE') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _verOfertas(servicio),
                  icon: const Icon(Icons.local_offer_outlined),
                  label: Text(
                    'Ver ofertas (${servicio['totalOfertas'] ?? 0})',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelar(servicio),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OfixColors.error,
                    side: const BorderSide(color: OfixColors.error),
                  ),
                  child: const Text('Cancelar solicitud'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}