// [10/11/2026] Estudio por tema — lista de temas con la cantidad de preguntas
// para el estado elegido. Mismo diseño de tarjetas que el menú inicial.
// — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../widget/comunes.dart';

/// Id especial para practicar todas las preguntas del estado mezcladas.
const String kTodosLosTemas = 'todos';

/// Ícono y colores de cada tema.
const Map<String, (IconData, Color, Color)> kEstiloTema = {
  'senales': (Icons.traffic_rounded, Color(0xFFFFA000), Color(0xFFFFF3E0)),
  'derecho_de_paso': (Icons.alt_route_rounded, Color(0xFF1565C0), Color(0xFFE3F2FD)),
  'velocidad': (Icons.speed_rounded, Color(0xFFD32F2F), Color(0xFFFFEBEE)),
  'carriles_giros': (Icons.turn_right_rounded, Color(0xFF5C6BC0), Color(0xFFE8EAF6)),
  'estacionamiento': (Icons.local_parking_rounded, Color(0xFF00838F), Color(0xFFE0F7FA)),
  'alcohol_drogas': (Icons.no_drinks_rounded, Color(0xFF6A1B9A), Color(0xFFF3E5F5)),
  'seguridad': (Icons.health_and_safety_rounded, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  'peatones_ciclistas': (Icons.directions_walk_rounded, Color(0xFFEF6C00), Color(0xFFFFF3E0)),
  'emergencias': (Icons.local_hospital_rounded, Color(0xFFC62828), Color(0xFFFFEBEE)),
  'licencia_leyes': (Icons.badge_rounded, Color(0xFF37474F), Color(0xFFECEFF1)),
};

class EstudioTemasPage extends StatelessWidget {
  const EstudioTemasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    final estado = prov.estado;

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: 'Estudiar por tema',
            subtitulo: estado == null
                ? 'Primero elige tu estado'
                : 'Practica sin apuro: ves la explicación de cada respuesta',
            leading: BotonIcono(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, 'initialPage'),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: estado == null ? _sinEstado(context) : _lista(context, prov, estado)),
        ],
      ),
    );
  }

  Widget _sinEstado(BuildContext context) {
    return Center(
      child: BotonPrincipal(
        icon: Icons.location_on_rounded,
        titulo: 'Elegir mi estado',
        onTap: () => Navigator.pushReplacementNamed(context, 'elegirEstado'),
      ),
    );
  }

  Widget _lista(BuildContext context, ExamenProvider prov, EstadoEEUU estado) {
    final total = prov.banco.paraEstado(estado.codigo).length;
    final temas = [
      for (final t in Tema.todos)
        if (prov.banco.porTema(estado.codigo, t.id).isNotEmpty) t,
    ];
    return ListView(
      children: [
        BotonPrincipal(
          icon: Icons.shuffle_rounded,
          titulo: 'Todos los temas',
          subtitulo: '$total preguntas de ${estado.nombre.es}, mezcladas',
          onTap: () => Navigator.pushReplacementNamed(context, 'estudio', arguments: kTodosLosTemas),
        ),
        const SizedBox(height: 18),
        const TituloSeccion('Temas'),
        const SizedBox(height: 10),
        for (final t in temas) ...[
          _cardTema(context, t, prov.banco.porTema(estado.codigo, t.id).length),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _cardTema(BuildContext context, Tema t, int cantidad) {
    final (icono, color, fondo) = kEstiloTema[t.id] ?? (Icons.label_rounded, Paleta.accent, const Color(0xFFE8EAF6));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushReplacementNamed(context, 'estudio', arguments: t.id),
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
                    Text(t.nombre.es,
                        style: const TextStyle(color: Paleta.primary, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('$cantidad preguntas',
                        style: const TextStyle(color: Paleta.muted, fontSize: 12, fontWeight: FontWeight.w500)),
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
