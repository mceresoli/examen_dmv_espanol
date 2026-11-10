// [06/11/2026] Repaso de respuestas — mismo diseño que resultados_page de la
// app argentina: "Repaso · X de N", botón Finalizar, opciones en verde (la
// correcta) y rojo (la tuya si erraste), pills Correcta/Incorrecta/Saltada y
// flechas para navegar. Nuevo: la explicación y la fuente del manual oficial
// ("Ver en el manual"). [10/11/2026] También "Repasar sólo mis
// errores" (anuncio bonificado), como en la app argentina. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../widget/comunes.dart';
import '../widget/explicacion.dart';
import 'examen_page.dart';

class RepasoPage extends StatelessWidget {
  const RepasoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    if (!prov.hayExamen) return const SinExamen();
    if (prov.totalRepaso == 0) prov.iniciarRepaso(notificar: false);

    final pe = prov.actualRepaso;
    final idioma = prov.idioma;

    return PantallaBase(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: '${prov.soloErrores ? 'Tus errores' : 'Repaso'} · ${prov.posRepaso + 1} de ${prov.totalRepaso}',
            subtitulo: prov.soloErrores ? 'Solo las que erraste o saltaste' : 'Tu respuesta y la correcta resaltadas',
            tamanio: 20,
            trailing: [_botonFinalizar(context)],
          ),
          const SizedBox(height: 10),
          IndicadorDeProgreso(indice: prov.posRepaso, total: prov.totalRepaso),
          const SizedBox(height: 14),
          Expanded(
            child: TarjetaPregunta(
              pe: pe,
              idioma: idioma,
              nombreEstado: prov.examen!.estado.nombre.es,
              pillsExtra: [_pillResultado(pe)],
              opcion: (i) => OpcionRespuesta(
                indice: i,
                texto: pe.opciones[i].de(idioma),
                estado: i == pe.indiceCorrecto
                    ? EstadoOpcion.correcta
                    : (i == pe.elegida ? EstadoOpcion.incorrecta : EstadoOpcion.normal),
              ),
              pie: _explicacionYFuente(pe.pregunta, idioma, prov),
            ),
          ),
          const SizedBox(height: 10),
          _navegacion(prov),
        ],
      ),
    );
  }

  Widget _pillResultado(PreguntaExamen pe) {
    if (pe.esCorrecta) {
      return const Pill(
          icon: Icons.check_circle_rounded, label: 'Correcta', color: Paleta.success, bg: Color(0xFFE8F5E9));
    }
    if (pe.saltada || !pe.respondida) {
      return Pill(
          icon: Icons.skip_next_rounded, label: 'Saltada', color: Colors.grey.shade700, bg: Colors.grey.shade200);
    }
    return const Pill(icon: Icons.cancel_rounded, label: 'Incorrecta', color: Paleta.danger, bg: Color(0xFFFFEBEE));
  }

  // [10/11/2026] Ahora es un widget compartido con el estudio por tema
  // (widget/explicacion.dart). — Claude (IA)
  Widget _explicacionYFuente(Pregunta p, Idioma idioma, ExamenProvider prov) =>
      ExplicacionYFuente(pregunta: p, idioma: idioma);

  Widget _botonFinalizar(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushReplacementNamed(context, 'resultado'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Paleta.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_rounded, color: Paleta.accent, size: 18),
              SizedBox(width: 4),
              Text('Finalizar', style: TextStyle(color: Paleta.accent, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navegacion(ExamenProvider prov) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circButton(Icons.arrow_back_rounded, !prov.esPrimeraRepaso, prov.anteriorRepaso),
        Text('${prov.posRepaso + 1} / ${prov.totalRepaso}',
            style: const TextStyle(color: Paleta.muted, fontSize: 13, fontWeight: FontWeight.w700)),
        _circButton(Icons.arrow_forward_rounded, !prov.esUltimaRepaso, prov.siguienteRepaso),
      ],
    );
  }

  Widget _circButton(IconData icon, bool enabled, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: enabled ? Paleta.accent.withValues(alpha: 0.12) : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: enabled ? Paleta.accent : Colors.grey.shade400, size: 22),
        ),
      ),
    );
  }
}
