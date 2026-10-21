import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Icono según el nombre de la categoría (si no hay coincidencia, uno genérico)
IconData iconoCategoria(String nombre) {
  final n = nombre.toLowerCase();

  if (n.contains('electr')) return Icons.bolt;
  if (n.contains('plom')) return Icons.plumbing;
  if (n.contains('limpi')) return Icons.cleaning_services;
  if (n.contains('pint')) return Icons.format_paint;
  if (n.contains('jard')) return Icons.yard;
  if (n.contains('carpint')) return Icons.carpenter;
  if (n.contains('cerraj')) return Icons.key;
  if (n.contains('aire') || n.contains('climat')) return Icons.ac_unit;
  if (n.contains('mudanz') || n.contains('transp')) {
    return Icons.local_shipping;
  }
  if (n.contains('tecn') || n.contains('técn') || n.contains('comput')) {
    return Icons.computer;
  }

  return Icons.handyman;
}

// (color del icono, color de fondo)
const List<(Color, Color)> _paleta = [
  (OfixColors.primary, OfixColors.primarySoft),
  (OfixColors.warning, OfixColors.warningSoft),
  (OfixColors.success, OfixColors.successSoft),
  (OfixColors.error, OfixColors.errorSoft),
  (OfixColors.darkBlue, Color(0xFFE6ECF7)),
];

// Misma categoría = mismo color siempre (se calcula con el nombre)
(Color, Color) colorCategoria(String nombre) {
  var suma = 0;

  for (final c in nombre.codeUnits) {
    suma += c;
  }

  return _paleta[suma % _paleta.length];
}

const List<String> _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

// "10 sep 2025, 10:00 a. m." (solo la fecha si no trae hora).
// Devuelve null si no hay fecha o no se puede leer.
String? formatearFechaServicio(dynamic valor) {
  if (valor == null) {
    return null;
  }

  final texto = valor.toString();
  final fecha = DateTime.tryParse(texto)?.toLocal();

  if (fecha == null) {
    return null;
  }

  final dia = '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';

  final traeHora =
      texto.contains('T') && !(fecha.hour == 0 && fecha.minute == 0);

  if (!traeHora) {
    return dia;
  }

  final hora12 = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final minutos = fecha.minute.toString().padLeft(2, '0');
  final sufijo = fecha.hour < 12 ? 'a. m.' : 'p. m.';

  return '$dia, $hora12:$minutos $sufijo';
}