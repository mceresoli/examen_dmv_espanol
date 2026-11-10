// [06/11/2026] Resultados — mismo diseño que estadisticas_page de la app
// argentina: tarjeta en degradé (verde si aprobó) con el porcentaje en un
// círculo, tres mini tarjetas Correctas/Incorrectas/Total, botón "Ver
// respuestas" y "Cerrar y volver al inicio". El aprobado usa el porcentaje
// oficial del estado (antes era 80 % fijo).
// Pendiente, como en la app argentina: interstitial al salir, compartir
// resultado y pedir calificación si aprobó. — Claude (IA)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ads/rewarded_controller.dart';
import '../estilos/paleta.dart';
import '../provider/examen_provider.dart';
import '../services/resena_service.dart';
import '../widget/comunes.dart';
import 'examen_page.dart';

class ResultadoPage extends StatelessWidget {
  const ResultadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    if (!prov.hayExamen) return const SinExamen();

    final ex = prov.examen!;
    final total = ex.preguntas.length;
    final porcentaje = total == 0 ? 0 : (100 * ex.aciertos / total).round();

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PedidoDeResena(),
          Encabezado(
            titulo: 'Resultados',
            subtitulo: 'Simulacro de ${ex.estado.nombre.es}',
            tamanio: 24,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cardResultado(ex.aprobado, porcentaje, ex.aciertosNecesarios, total, ex.estado.nombre.es),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(Icons.check_circle_rounded, 'Correctas', ex.aciertos, Paleta.success,
                            const Color(0xFFE8F5E9)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(Icons.cancel_rounded, 'Incorrectas', ex.incorrectas, Paleta.danger,
                            const Color(0xFFFFEBEE)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(Icons.quiz_rounded, 'Total', total, Paleta.accent,
                            Paleta.accent.withValues(alpha: 0.10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          BotonPrincipal(
            icon: Icons.visibility_rounded,
            titulo: 'Ver respuestas',
            onTap: () {
              prov.iniciarRepaso();
              Navigator.pushReplacementNamed(context, 'repaso');
            },
          ),
          const SizedBox(height: 8),
          // [10/11/2026] Opcional y avisado: el ícono de video indica que hay
          // un anuncio bonificado antes del repaso de errores. — Claude (IA)
          if (ex.incorrectas > 0)
            BotonTexto(
              icon: Icons.ondemand_video_rounded,
              label: 'Repasar sólo mis errores (${ex.incorrectas})',
              onPressed: () => _repasarErrores(context, prov, ex.incorrectas),
            ),
          BotonTexto(
            icon: Icons.home_rounded,
            label: 'Cerrar y volver al inicio',
            onPressed: () => Navigator.pushReplacementNamed(context, 'initialPage'),
          ),
        ],
      ),
    );
  }

  Future<void> _repasarErrores(BuildContext context, ExamenProvider prov, int errores) async {
    void ir() {
      prov.iniciarRepaso(soloErrores: true);
      Navigator.pushReplacementNamed(context, 'repaso');
    }

    // Sin anuncio listo, el repaso se regala.
    if (!kBonificado.listo) return ir();

    final ver = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Repasar sólo tus errores'),
        content: Text(errores == 1
            ? 'Mira un anuncio corto y repasa la pregunta que erraste o saltaste, con su explicación.'
            : 'Mira un anuncio corto y repasa las $errores preguntas que erraste o saltaste, con su explicación.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Ahora no')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ver anuncio')),
        ],
      ),
    );
    if (ver != true || !context.mounted) return;

    final r = await kBonificado.mostrar();
    if (!context.mounted) return;
    if (r == ResultadoBonificado.cancelado) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Para repasar sólo tus errores tienes que ver el anuncio completo.'),
      ));
      return;
    }
    ir();
  }

  Widget _cardResultado(bool aprobado, int porcentaje, int necesarios, int total, String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: aprobado ? Paleta.gradienteAprobado : Paleta.gradienteAccent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (aprobado ? Paleta.success : Paleta.accent).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(aprobado ? Icons.emoji_events_rounded : Icons.menu_book_rounded, color: Colors.white, size: 44),
          const SizedBox(height: 10),
          Text(
            aprobado ? '¡Felicidades!' : '¡Sigue practicando!',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            aprobado ? 'Aprobaste el simulacro de $estado' : 'Repasa tus errores y vuelve a intentarlo',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Container(
            width: 130,
            height: 130,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$porcentaje%',
                  style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
                Text(
                  'aciertos',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Para aprobar necesitabas $necesarios de $total',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, int valor, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text('$valor', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Paleta.muted, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


/// [10/11/2026] Invisible: si el examen recién aprobado lo merece, pide la
/// reseña 1,5 s después de mostrar el resultado. — Claude (IA)
class _PedidoDeResena extends StatefulWidget {
  const _PedidoDeResena();

  @override
  State<_PedidoDeResena> createState() => _PedidoDeResenaState();
}

class _PedidoDeResenaState extends State<_PedidoDeResena> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _esperar();
  }

  Future<void> _esperar() async {
    final srv = ResenaService.instancia;
    await srv.registroListo;
    if (!mounted || !srv.pendiente) return;
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) srv.pedirSiCorresponde();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
