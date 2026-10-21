import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/contacto.dart';
import '../theme/app_theme.dart';

// Cuadro con el correo de soporte y botón para copiarlo
Future<void> mostrarContactoSoporte(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Contactar soporte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Escríbenos y te ayudaremos lo antes posible:'),
          const SizedBox(height: 12),
          SelectableText(
            correoSoporte,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OfixColors.primary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await Clipboard.setData(const ClipboardData(text: correoSoporte));

            if (ctx.mounted) {
              Navigator.pop(ctx);
            }

            messenger.showSnackBar(
              const SnackBar(content: Text('Correo copiado')),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copiar correo'),
        ),
      ],
    ),
  );
}

// Tarjeta azul clara "¿Necesitas ayuda?"
class SoporteCard extends StatelessWidget {
  const SoporteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OfixColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: OfixColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: 30,
              color: OfixColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: OfixColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Nuestro equipo está listo para ayudarte.',
                  style: TextStyle(
                    fontSize: 13,
                    color: OfixColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => mostrarContactoSoporte(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('Contactar soporte'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}