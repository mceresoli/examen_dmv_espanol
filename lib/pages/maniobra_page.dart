// [10/11/2026] Maniobra paso a paso — como las pantallas de la app "DMV Road
// Test" (texto del paso + imagen), con el diseño de esta app: pasos numerados,
// consejos, errores que restan puntos, video y fuentes oficiales. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../services/practico_service.dart';
import '../ads/interstitial_controller.dart';
import '../widget/comunes.dart';
import '../widget/explicacion.dart';

class ManiobraPage extends StatelessWidget {
  const ManiobraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    final idioma = prov.idioma;
    final es = idioma == Idioma.es;
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final m = id == null ? null : PracticoService.instancia.maniobra(id);
    // [10/11/2026] Interstitial al volver al menú (desde la 3ra maniobra), como
    // ManiobrasAdController de la app argentina. — Claude (IA)
    void volver() => kInterstitial.mostrarYNavegar(
        LugarInterstitial.maniobras, () => Navigator.pushReplacementNamed(context, 'practico'));

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: m?.titulo.de(idioma) ?? 'Examen práctico',
            subtitulo: m?.resumen.de(idioma),
            tamanio: 20,
            leading: BotonIcono(icon: Icons.arrow_back_rounded, onTap: volver),
            trailing: [BotonIdioma(idioma: idioma, onTap: prov.cambiarIdioma)],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: m == null
                ? const Center(
                    child: Text('No se encontró la maniobra.',
                        style: TextStyle(color: Paleta.muted, fontWeight: FontWeight.w600)),
                  )
                : ListView(
                    children: [
                      for (var i = 0; i < m.pasos.length; i++) ...[
                        _Paso(numero: i + 1, paso: m.pasos[i], idioma: idioma),
                        const SizedBox(height: 12),
                      ],
                      if (m.consejos.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _Recuadro(
                          icono: Icons.lightbulb_rounded,
                          color: const Color(0xFFFFA000),
                          titulo: es ? 'Consejos' : 'Tips',
                          textos: [for (final c in m.consejos) c.de(idioma)],
                        ),
                      ],
                      if (m.errores.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _Recuadro(
                          icono: Icons.error_rounded,
                          color: Paleta.danger,
                          titulo: es ? 'Errores que te restan puntos' : 'Mistakes that cost points',
                          textos: [for (final e in m.errores) e.de(idioma)],
                        ),
                      ],
                      if (m.video != null) ...[
                        const SizedBox(height: 16),
                        BotonPrincipal(
                          icon: Icons.play_circle_fill_rounded,
                          titulo: es ? 'Ver el video' : 'Watch the video',
                          subtitulo: es ? 'Animación de la maniobra' : 'Maneuver animation',
                          onTap: () => launchUrl(Uri.parse(m.video!), mode: LaunchMode.inAppBrowserView),
                        ),
                      ],
                      if (m.fuentes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        TituloSeccion(es ? 'Fuente oficial' : 'Official source'),
                        const SizedBox(height: 4),
                        for (final f in m.fuentes) LineaFuente(f),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.numero, required this.paso, required this.idioma});

  final int numero;
  final PasoManiobra paso;
  final Idioma idioma;

  @override
  Widget build(BuildContext context) {
    final img = paso.rutaImagen;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Paleta.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Paleta.sombraSuave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(gradient: Paleta.gradienteAccent, shape: BoxShape.circle),
                child: Text('$numero',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  paso.texto.de(idioma),
                  style: const TextStyle(color: Paleta.primary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.35),
                ),
              ),
            ],
          ),
          if (img != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(img, fit: BoxFit.contain),
            ),
          ],
        ],
      ),
    );
  }
}

class _Recuadro extends StatelessWidget {
  const _Recuadro({required this.icono, required this.color, required this.titulo, required this.textos});

  final IconData icono;
  final Color color;
  final String titulo;
  final List<String> textos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(titulo, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          for (final t in textos)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('•  $t',
                  style: const TextStyle(color: Paleta.primary, fontSize: 13, fontWeight: FontWeight.w500, height: 1.35)),
            ),
        ],
      ),
    );
  }
}
