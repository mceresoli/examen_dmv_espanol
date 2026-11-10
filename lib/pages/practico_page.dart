// [10/11/2026] Examen práctico — menú. Arriba, qué evalúa el estado elegido;
// después las maniobras (primero las de ese estado) y las frases del
// examinador. Mismo diseño de tarjetas que el menú inicial. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../services/practico_service.dart';
import '../widget/comunes.dart';
import '../widget/explicacion.dart';

/// Ícono de cada maniobra (campo "icono" del JSON).
const Map<String, IconData> kIconoManiobra = {
  'checklist': Icons.fact_check_rounded,
  'paralelo': Icons.local_parking_rounded,
  'noventa': Icons.garage_rounded,
  'retroceder': Icons.u_turn_left_rounded,
  'tres_puntos': Icons.turn_sharp_left_rounded,
  'parada': Icons.front_hand_rounded,
  'pendiente': Icons.landscape_rounded,
  'espejos': Icons.visibility_rounded,
};

class PracticoPage extends StatelessWidget {
  const PracticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    final idioma = prov.idioma;
    final estado = prov.estado;
    final srv = PracticoService.instancia;
    final eval = srv.evaluacion(estado?.codigo);
    final delEstado = eval?.maniobras ?? const <String>[];

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: 'Examen práctico',
            subtitulo: 'Las maniobras del examen de manejo, paso a paso',
            leading: BotonIcono(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, 'initialPage'),
            ),
            trailing: [BotonIdioma(idioma: idioma, onTap: prov.cambiarIdioma)],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                if (eval != null)
                  _TarjetaEvaluacion(nombreEstado: estado!.nombre.es, eval: eval, idioma: idioma)
                else
                  _tarjeta(
                    context,
                    icono: Icons.location_on_rounded,
                    color: const Color(0xFF1565C0),
                    fondo: const Color(0xFFE3F2FD),
                    titulo: 'Elige tu estado',
                    subtitulo: 'Para ver qué te evalúan en el examen práctico',
                    onTap: () => Navigator.pushReplacementNamed(context, 'elegirEstado'),
                  ),
                const SizedBox(height: 22),
                const TituloSeccion('Maniobras'),
                const SizedBox(height: 10),
                for (final m in srv.ordenadasPara(estado?.codigo)) ...[
                  _TarjetaManiobra(
                    maniobra: m,
                    idioma: idioma,
                    seEvaluaEn: delEstado.contains(m.id) ? estado!.nombre.es : null,
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
                const TituloSeccion('En inglés'),
                const SizedBox(height: 10),
                _tarjeta(
                  context,
                  icono: Icons.record_voice_over_rounded,
                  color: const Color(0xFF00838F),
                  fondo: const Color(0xFFE0F7FA),
                  titulo: 'Frases del examinador',
                  subtitulo: '${srv.frases.length} indicaciones que vas a escuchar en inglés',
                  onTap: () => Navigator.pushReplacementNamed(context, 'frasesExaminador'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(
    BuildContext context, {
    required IconData icono,
    required Color color,
    required Color fondo,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Paleta.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Paleta.sombraSuave,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(12)),
                child: Icon(icono, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(color: Paleta.primary, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: const TextStyle(color: Paleta.muted, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Paleta.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaEvaluacion extends StatelessWidget {
  const _TarjetaEvaluacion({required this.nombreEstado, required this.eval, required this.idioma});

  final String nombreEstado;
  final EvaluacionEstado eval;
  final Idioma idioma;

  @override
  Widget build(BuildContext context) {
    final es = idioma == Idioma.es;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Paleta.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Paleta.sombraSuave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: Paleta.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  es ? 'Qué te evalúan en $nombreEstado' : 'What is graded in $nombreEstado',
                  style: const TextStyle(color: Paleta.primary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(eval.resumen.de(idioma),
              style: const TextStyle(color: Paleta.primary, fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.35)),
          const SizedBox(height: 8),
          for (final p in eval.puntos)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded, color: Paleta.success, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(p.de(idioma),
                        style: const TextStyle(color: Paleta.primary, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
                  ),
                ],
              ),
            ),
          if (eval.fuente != null) ...[
            const SizedBox(height: 8),
            LineaFuente(eval.fuente!),
          ],
        ],
      ),
    );
  }
}

class _TarjetaManiobra extends StatelessWidget {
  const _TarjetaManiobra({required this.maniobra, required this.idioma, this.seEvaluaEn});

  final Maniobra maniobra;
  final Idioma idioma;
  final String? seEvaluaEn;

  @override
  Widget build(BuildContext context) {
    final m = maniobra;
    final img = m.miniatura;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushReplacementNamed(context, 'maniobra', arguments: m.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Paleta.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Paleta.sombraSuave,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: img != null
                      ? Image.asset(img, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF3E5F5),
                          child: Icon(kIconoManiobra[m.icono] ?? Icons.directions_car_rounded,
                              color: const Color(0xFF6A1B9A), size: 26),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.titulo.de(idioma),
                        style: const TextStyle(color: Paleta.primary, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(m.resumen.de(idioma),
                        style: const TextStyle(color: Paleta.muted, fontSize: 12, fontWeight: FontWeight.w500)),
                    if (seEvaluaEn != null) ...[
                      const SizedBox(height: 6),
                      Pill(
                        icon: Icons.verified_rounded,
                        label: idioma == Idioma.es ? 'Se evalúa en $seEvaluaEn' : 'Graded in $seEvaluaEn',
                        color: Paleta.success,
                        bg: Paleta.success.withValues(alpha: 0.10),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Paleta.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
