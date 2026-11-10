// [10/11/2026] Explicación de la respuesta + fuente del manual ("Ver en el
// manual"). La usan el repaso del simulacro y el estudio por tema. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';

class ExplicacionYFuente extends StatelessWidget {
  const ExplicacionYFuente({super.key, required this.pregunta, required this.idioma});

  final Pregunta pregunta;
  final Idioma idioma;

  @override
  Widget build(BuildContext context) {
    final prov = context.read<ExamenProvider>();
    final p = pregunta;
    final f = p.fuente;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (p.explicacion != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Paleta.accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFA000), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.explicacion!.de(idioma),
                    style: const TextStyle(color: Paleta.primary, fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (f != null) ...[
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: f.url == null ? null : () => launchUrl(Uri.parse(f.url!), mode: LaunchMode.externalApplication),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: Paleta.muted, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${f.manual == 'MUTCD' ? 'MUTCD (manual federal de señales)' : 'Manual de ${prov.nombreEstado(f.manual)}'} · ${f.seccion}${f.pagina != null ? ' · pág. ${f.pagina}' : ''}',
                      style: TextStyle(
                        color: Paleta.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: f.url != null ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// [10/11/2026] Línea "Manual de Texas · Cap. 7 · pág. 43" que abre el manual
/// oficial. La usan las maniobras del examen práctico. — Claude (IA)
class LineaFuente extends StatelessWidget {
  const LineaFuente(this.fuente, {super.key});

  final FuenteManual fuente;

  @override
  Widget build(BuildContext context) {
    final f = fuente;
    final nombre = context.read<ExamenProvider>().nombreEstado(f.manual);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: f.url == null ? null : () => launchUrl(Uri.parse(f.url!), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        child: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: Paleta.muted, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Manual de $nombre · ${f.seccion}${f.pagina != null ? ' · pág. ${f.pagina}' : ''}',
                style: TextStyle(
                  color: Paleta.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: f.url != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
