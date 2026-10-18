import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Logo de texto "OFIX" (hasta que tengamos el logo en imagen)
class OfixLogo extends StatelessWidget {
  final double size;
  final Color color;

  const OfixLogo({
    super.key,
    this.size = 28,
    this.color = OfixColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'OFIX',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: color,
      ),
    );
  }
}

// Tarjeta blanca con borde fino; si recibe onTap, es pulsable
class OfixCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const OfixCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: OfixColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OfixColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Chip de estado con colores según el estado de un servicio u oferta
class EstadoChip extends StatelessWidget {
  final String estado;

  const EstadoChip(this.estado, {super.key});

  // (texto, color del texto, color de fondo)
  (String, Color, Color) _estilo() {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return ('Pendiente', const Color(0xFFB45309), OfixColors.warningSoft);
      case 'EN_PROCESO':
        return ('En progreso', OfixColors.primary, OfixColors.primarySoft);
      case 'COMPLETADO':
        return ('Completado', const Color(0xFF15803D), OfixColors.successSoft);
      case 'ACEPTADA':
        return ('Aceptada', const Color(0xFF15803D), OfixColors.successSoft);
      case 'CANCELADO':
      case 'RECHAZADA':
        return (
          estado.toUpperCase() == 'CANCELADO' ? 'Cancelado' : 'Rechazada',
          OfixColors.error,
          OfixColors.errorSoft,
        );
      case 'RETIRADA':
        return ('Retirada', OfixColors.textSecondary, const Color(0xFFF1F5F9));
      default:
        return (estado, OfixColors.textSecondary, const Color(0xFFF1F5F9));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (texto, color, fondo) = _estilo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Título de sección con enlace opcional a la derecha ("Ver todas →")
class OfixSectionHeader extends StatelessWidget {
  final String titulo;
  final String? accion;
  final VoidCallback? onAccion;

  const OfixSectionHeader({
    super.key,
    required this.titulo,
    this.accion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        if (accion != null)
          TextButton(
            onPressed: onAccion,
            child: Text('$accion →'),
          ),
      ],
    );
  }
}

// Cuadro de estadística (ej. "3 Solicitudes activas")
class OfixStatTile extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final Color color;

  const OfixStatTile({
    super.key,
    required this.valor,
    required this.etiqueta,
    this.color = OfixColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return OfixCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 12,
              color: OfixColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Estado vacío: icono + mensaje cuando no hay datos
class OfixEmptyState extends StatelessWidget {
  final IconData icono;
  final String mensaje;

  const OfixEmptyState({
    super.key,
    required this.icono,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: OfixColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 32, color: OfixColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: OfixColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// Limita el ancho del contenido y lo centra en pantallas grandes (web/PC)
class OfixMaxWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const OfixMaxWidth({
    super.key,
    this.maxWidth = 480,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}