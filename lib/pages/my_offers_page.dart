import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'service_offers_page.dart' show formatearPrecio;

class MyOffersPage extends StatefulWidget {
  const MyOffersPage({super.key});

  @override
  State<MyOffersPage> createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  late Future<List<dynamic>> ofertasFuture;
  bool procesando = false;

  @override
  void initState() {
    super.initState();
    ofertasFuture = cargarOfertas();
  }

  Future<List<dynamic>> cargarOfertas() async {
    final resultado = await ApiService.listarMisOfertas();

    if (resultado['statusCode'] != 200) {
      throw Exception('No se pudieron cargar tus ofertas');
    }

    return resultado['data'];
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'ACEPTADA':
        return OfixColors.success;
      case 'RECHAZADA':
        return OfixColors.error;
      case 'RETIRADA':
        return OfixColors.textSecondary;
      default:
        return OfixColors.warning;
    }
  }

  Future<void> _retirar(dynamic oferta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirar oferta'),
        content: const Text(
          '¿Seguro que quieres retirar esta oferta? '
          'El cliente ya no podrá aceptarla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Retirar'),
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

    final resultado = await ApiService.retirarOferta(oferta['id']);

    if (!mounted) {
      return;
    }

    setState(() {
      procesando = false;
    });

    if (resultado['statusCode'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta retirada')),
      );

      setState(() {
        ofertasFuture = cargarOfertas();
      });
    } else {
      final data = resultado['data'];
      final mensaje = (data is Map && data['mensaje'] != null)
          ? data['mensaje'].toString()
          : 'No se pudo retirar la oferta';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis ofertas'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            ofertasFuture = cargarOfertas();
          });

          await ofertasFuture;
        },
        child: FutureBuilder<List<dynamic>>(
          future: ofertasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(40),
                children: const [
                  Text(
                    'No se pudieron cargar tus ofertas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: OfixColors.error),
                  ),
                ],
              );
            }

            final ofertas = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Mis ofertas',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sigue el estado de las propuestas que enviaste.',
                  style: TextStyle(
                    fontSize: 16,
                    color: OfixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (ofertas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Todavía no has enviado ofertas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: OfixColors.textSecondary),
                    ),
                  ),
                ...ofertas.map((oferta) => _buildOfertaCard(oferta)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOfertaCard(dynamic oferta) {
    final estado = (oferta['estado'] ?? '').toString();
    final color = _colorEstado(estado);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  oferta['servicioTitulo'] ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: OfixColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 18,
                color: OfixColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                oferta['categoriaNombre'] ?? '',
                style: const TextStyle(color: OfixColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatearPrecio(oferta['precio']),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: OfixColors.darkBlue,
            ),
          ),
          if ((oferta['mensaje'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              oferta['mensaje'].toString(),
              style: const TextStyle(color: OfixColors.textSecondary),
            ),
          ],
          if (estado == 'ACEPTADA') ...[
            const SizedBox(height: 12),
            const Text(
              '¡Te eligieron! Encuentra el servicio en "Mis servicios".',
              style: TextStyle(
                color: OfixColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (estado == 'PENDIENTE') ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: procesando ? null : () => _retirar(oferta),
                child: const Text('Retirar oferta'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}