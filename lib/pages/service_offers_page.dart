import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Formatea un valor como pesos colombianos: 85000 -> $85.000
String formatearPrecio(dynamic valor) {
  final numero = (valor is num) ? valor : (num.tryParse('$valor') ?? 0);
  final texto = numero.round().toString();
  final conPuntos = texto.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return '\$$conPuntos';
}

class ServiceOffersPage extends StatefulWidget {
  final Map<String, dynamic> servicio;

  const ServiceOffersPage({
    super.key,
    required this.servicio,
  });

  @override
  State<ServiceOffersPage> createState() => _ServiceOffersPageState();
}

class _ServiceOffersPageState extends State<ServiceOffersPage> {
  late Future<List<dynamic>> ofertasFuture;
  bool procesando = false;

  @override
  void initState() {
    super.initState();
    ofertasFuture = cargarOfertas();
  }

  String _mensajeError(Map<String, dynamic> resultado, String defecto) {
    final data = resultado['data'];

    if (data is Map && data['mensaje'] != null) {
      return data['mensaje'].toString();
    }

    return defecto;
  }

  Future<List<dynamic>> cargarOfertas() async {
    final resultado =
        await ApiService.listarOfertasDeServicio(widget.servicio['id']);

    if (resultado['statusCode'] != 200) {
      throw Exception(
        _mensajeError(resultado, 'No se pudieron cargar las ofertas'),
      );
    }

    return resultado['data'];
  }

  Future<void> _aceptar(dynamic oferta) async {
    final nombre = oferta['trabajadorNombre'] ?? 'este profesional';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aceptar oferta'),
        content: Text(
          '¿Aceptas la oferta de $nombre por '
          '${formatearPrecio(oferta['precio'])}?\n\n'
          'Las demás ofertas serán rechazadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aceptar oferta'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      procesando = true;
    });

    final resultado = await ApiService.aceptarOferta(oferta['id']);

    if (!mounted) {
      return;
    }

    setState(() {
      procesando = false;
    });

    if (resultado['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oferta aceptada. ¡Tu servicio está en proceso!'),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mensajeError(resultado, 'No se pudo aceptar la oferta'),
          ),
        ),
      );
    }
  }

  Future<void> _rechazar(dynamic oferta) async {
    setState(() {
      procesando = true;
    });

    final resultado = await ApiService.rechazarOferta(oferta['id']);

    if (!mounted) {
      return;
    }

    setState(() {
      procesando = false;
    });

    if (resultado['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta rechazada')),
      );

      setState(() {
        ofertasFuture = cargarOfertas();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _mensajeError(resultado, 'No se pudo rechazar la oferta'),
          ),
        ),
      );
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'ACEPTADA':
        return OfixColors.success;
      case 'RECHAZADA':
        return OfixColors.error;
      default:
        return OfixColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicio = widget.servicio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas recibidas'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ofertasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: OfixColors.error),
                ),
              ),
            );
          }

          final ofertas = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                ofertasFuture = cargarOfertas();
              });

              await ofertasFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  servicio['titulo'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                if (servicio['presupuesto'] != null)
                  Text(
                    'Tu presupuesto: ${formatearPrecio(servicio['presupuesto'])}',
                    style: const TextStyle(
                      color: OfixColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 20),
                if (ofertas.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: OfixColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 48,
                          color: OfixColors.textSecondary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aún no hay ofertas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: OfixColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Los profesionales de esta categoría verán tu '
                          'solicitud y te enviarán sus propuestas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: OfixColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ...ofertas.map((oferta) => _buildOfertaCard(oferta)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfertaCard(dynamic oferta) {
    final estado = (oferta['estado'] ?? '').toString();
    final nombre = (oferta['trabajadorNombre'] ?? 'Profesional').toString();
    final puedeDecidir =
        estado == 'PENDIENTE' && widget.servicio['estado'] == 'PENDIENTE';

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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: OfixColors.primary.withValues(alpha: 0.12),
                child: Text(
                  nombre.isEmpty ? '?' : nombre[0].toUpperCase(),
                  style: const TextStyle(
                    color: OfixColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: OfixColors.textPrimary,
                      ),
                    ),
                    if (oferta['trabajadorProfesion'] != null)
                      Text(
                        oferta['trabajadorProfesion'].toString(),
                        style: const TextStyle(
                          color: OfixColors.textSecondary,
                        ),
                      ),
                    if (oferta['trabajadorAnosExperiencia'] != null ||
                        oferta['trabajadorZona'] != null)
                      Text(
                        [
                          if (oferta['trabajadorAnosExperiencia'] != null)
                            '${oferta['trabajadorAnosExperiencia']} años de experiencia',
                          if (oferta['trabajadorZona'] != null)
                            oferta['trabajadorZona'].toString(),
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: OfixColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _colorEstado(estado).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _colorEstado(estado),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatearPrecio(oferta['precio']),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: OfixColors.darkBlue,
            ),
          ),
          if ((oferta['mensaje'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              oferta['mensaje'].toString(),
              style: const TextStyle(
                color: OfixColors.textSecondary,
              ),
            ),
          ],
          if (puedeDecidir) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: procesando ? null : () => _rechazar(oferta),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: OfixColors.success,
                    ),
                    onPressed: procesando ? null : () => _aceptar(oferta),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}