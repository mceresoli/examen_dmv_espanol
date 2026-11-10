// [06/11/2026] Pantalla del simulacro — mismo diseño que examen_page de la app
// argentina: "Pregunta X de N", barra de progreso, tarjeta blanca con pills,
// enunciado, imagen y opciones A/B/C; "Saltar pregunta" al pie y botón rojo
// para abandonar. Nuevo: botón ES/EN para ver la pregunta en inglés. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../ads/interstitial_controller.dart';
import '../services/resena_service.dart';
import '../widget/comunes.dart';

class ExamenPage extends StatelessWidget {
  const ExamenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    if (!prov.hayExamen) return const SinExamen();

    final pe = prov.actual;
    final idioma = prov.idioma;

    void avanzar() {
      if (prov.esUltima) {
        // [10/11/2026] Interstitial al terminar el examen y registro para el
        // pedido de reseña. — Claude (IA)
        ResenaService.instancia.registrarExamen(aprobado: prov.examen!.aprobado);
        kInterstitial.mostrarYNavegar(
            LugarInterstitial.finExamen, () => Navigator.pushReplacementNamed(context, 'resultado'));
      } else {
        prov.siguiente();
      }
    }

    return PantallaBase(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: 'Pregunta ${prov.indice + 1} de ${prov.total}',
            subtitulo: idioma == Idioma.es ? 'Toca la opción que consideres correcta' : 'Tap the correct answer',
            tamanio: 20,
            trailing: [
              BotonIdioma(idioma: idioma, onTap: prov.cambiarIdioma),
              BotonIcono(
                icon: Icons.close_rounded,
                color: Paleta.danger,
                onTap: () => _confirmarAbandono(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IndicadorDeProgreso(indice: prov.indice, total: prov.total),
          const SizedBox(height: 14),
          Expanded(
            child: TarjetaPregunta(
              pe: pe,
              idioma: idioma,
              nombreEstado: prov.examen!.estado.nombre.es,
              opcion: (i) => OpcionRespuesta(
                indice: i,
                texto: pe.opciones[i].de(idioma),
                onTap: () {
                  prov.responder(i);
                  avanzar();
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          BotonTexto(
            icon: Icons.skip_next_rounded,
            label: 'Saltar pregunta',
            onPressed: () {
              prov.saltar();
              avanzar();
            },
          ),
        ],
      ),
    );
  }

  /// En la app argentina la X iba directo a resultados; acá se confirma para
  /// no perder el examen por un toque accidental.
  Future<void> _confirmarAbandono(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Terminar el examen?',
            style: TextStyle(color: Paleta.primary, fontWeight: FontWeight.w800)),
        content: const Text('Las preguntas que no respondiste cuentan como incorrectas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Seguir')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Terminar', style: TextStyle(color: Paleta.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (salir == true && context.mounted) {
      kInterstitial.mostrarYNavegar(
          LugarInterstitial.finExamen, () => Navigator.pushReplacementNamed(context, 'resultado'));
    }
  }
}

/// Tarjeta blanca de la pregunta. La usan el examen y el repaso.
class TarjetaPregunta extends StatelessWidget {
  const TarjetaPregunta({
    super.key,
    required this.pe,
    required this.idioma,
    required this.nombreEstado,
    required this.opcion,
    this.pillsExtra = const [],
    this.pie,
  });

  final PreguntaExamen pe;
  final Idioma idioma;
  final String nombreEstado;
  final Widget Function(int indice) opcion;
  final List<Widget> pillsExtra;

  /// Contenido debajo de las opciones (explicación y fuente en el repaso).
  final Widget? pie;

  @override
  Widget build(BuildContext context) {
    final p = pe.pregunta;
    final tema = Tema.porId(p.tema);
    return Container(
      decoration: BoxDecoration(
        color: Paleta.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ...pillsExtra,
                if (tema != null)
                  Pill(
                    icon: Icons.label_rounded,
                    label: tema.nombre.de(idioma),
                    color: Paleta.accent,
                    bg: Paleta.accent.withValues(alpha: 0.10),
                  ),
                Pill(
                  icon: Icons.location_on_rounded,
                  // [06/11/2026] Siempre el estado del simulacro: las preguntas
                  // comunes también valen para ese estado. — Claude (IA)
                  label: nombreEstado,
                  color: const Color(0xFF1565C0),
                  bg: const Color(0xFFE3F2FD),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              p.enunciado.de(idioma),
              style: const TextStyle(color: Paleta.primary, fontSize: 16, fontWeight: FontWeight.w700, height: 1.35),
            ),
            if (p.senial != null) ...[const SizedBox(height: 14), SenialImagen(p.senial!)],
            if (p.imagen != null) ...[
              const SizedBox(height: 14),
              Center(child: Image.asset(p.imagen!, height: 160, errorBuilder: (_, _, _) => const SizedBox.shrink())),
            ],
            const SizedBox(height: 16),
            for (var i = 0; i < pe.opciones.length; i++)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: opcion(i)),
            ?pie,
          ],
        ),
      ),
    );
  }
}

class SinExamen extends StatelessWidget {
  const SinExamen({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Paleta.muted, size: 56),
            const SizedBox(height: 12),
            const Text('No hay un examen activo.',
                style: TextStyle(color: Paleta.primary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.home_rounded, color: Paleta.accent),
              label: const Text('Volver al inicio', style: TextStyle(color: Paleta.accent, fontWeight: FontWeight.w700)),
              onPressed: () => Navigator.pushReplacementNamed(context, 'initialPage'),
            ),
          ],
        ),
      ),
    );
  }
}
