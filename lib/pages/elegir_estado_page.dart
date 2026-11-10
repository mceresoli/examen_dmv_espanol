// [06/11/2026] Elección del estado — equivalente a "Selección de clases"
// (parametros_examen_page) de la app argentina: mismas tarjetas seleccionables
// en degradé, chip informativo, botón "Iniciar examen" y "Cancelar".
// Acá la selección es única (un estado). — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../widget/comunes.dart';

class ElegirEstadoPage extends StatefulWidget {
  const ElegirEstadoPage({super.key});

  @override
  State<ElegirEstadoPage> createState() => _ElegirEstadoPageState();
}

class _ElegirEstadoPageState extends State<ElegirEstadoPage> {
  String? _seleccionado;

  @override
  void initState() {
    super.initState();
    _seleccionado = context.read<ExamenProvider>().estado?.codigo;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<ExamenProvider>();
    final estados = prov.banco.estados;
    final elegido = estados.where((e) => e.codigo == _seleccionado).firstOrNull;

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado, tarjetas y chip se desplazan juntos: en pantallas
          // chicas (iPhone SE) la lista no queda aplastada por los botones.
          Expanded(
            child: ListView(
              children: [
                Encabezado(
                  titulo: 'Elige tu estado',
                  subtitulo: 'Las preguntas se adaptan a las leyes del estado donde vas a rendir',
                  leading: BotonIcono(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pushReplacementNamed(context, 'initialPage'),
                  ),
                ),
                const SizedBox(height: 18),
                for (final e in estados) ...[
                  _cardEstado(e, e.codigo == _seleccionado),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 4),
                _chipInfo(elegido),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BotonPrincipal(
            icon: Icons.play_arrow_rounded,
            titulo: 'Iniciar examen',
            habilitado: elegido != null,
            onTap: () async {
              await prov.elegirEstado(elegido!.codigo);
              prov.iniciarExamen();
              if (context.mounted) Navigator.pushReplacementNamed(context, 'examen');
            },
          ),
          const SizedBox(height: 8),
          BotonTexto(
            icon: Icons.close_rounded,
            label: 'Cancelar',
            onPressed: () => Navigator.pushReplacementNamed(context, 'initialPage'),
          ),
        ],
      ),
    );
  }

  Widget _cardEstado(EstadoEEUU e, bool sel) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _seleccionado = e.codigo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: sel ? null : Colors.white,
            gradient: sel ? Paleta.gradienteAccent : null,
            borderRadius: BorderRadius.circular(14),
            border: sel ? null : Border.all(color: Paleta.accent.withValues(alpha: 0.15), width: 1.2),
            boxShadow: sel
                ? [BoxShadow(color: Paleta.accent.withValues(alpha: 0.32), blurRadius: 10, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? Colors.white.withValues(alpha: 0.18) : Paleta.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  e.codigo,
                  style: TextStyle(
                    color: sel ? Colors.white : Paleta.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre.es,
                      style: TextStyle(
                        color: sel ? Colors.white : Paleta.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Examen oficial: ${e.cantidadPreguntas} preguntas · ${e.porcentajeAprobacion.round()} % para aprobar',
                      style: TextStyle(
                        color: sel ? Colors.white70 : Paleta.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (sel)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Paleta.accent, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipInfo(EstadoEEUU? e) {
    final hay = e != null;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: hay ? Paleta.accent.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hay ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 16, color: hay ? Paleta.accent : Colors.grey.shade600),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                hay
                    ? 'Simulacro: ${e.preguntasSimulacro} preguntas · necesitas ${e.aciertosPara(e.preguntasSimulacro)} correctas'
                    : 'Selecciona un estado',
                style: TextStyle(
                  color: hay ? Paleta.accent : Colors.grey.shade700,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
