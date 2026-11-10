// [06/11/2026] Menú inicial — mismo diseño que initial_page de la app argentina
// (header con ícono, botón principal "Iniciar nuevo examen", tarjeta "Ver mi
// último examen", tarjetas de opción). Textos en español neutro con tuteo.
// Pendiente: BannerAd al pie (como en la app argentina). — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../ads/banner_inferior.dart';
import '../widget/comunes.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    final estado = prov.estado;

    return PantallaBase(
      // [10/11/2026] Banner al pie, como en la app argentina. — Claude (IA)
      bottomNavigationBar: const SafeArea(top: false, child: Center(heightFactor: 1, child: BannerInferior())),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 22),
            BotonPrincipal(
              grande: true,
              icon: Icons.play_arrow_rounded,
              titulo: 'Iniciar nuevo examen',
              subtitulo: estado == null
                  ? 'Primero elige tu estado'
                  : '${estado.preguntasSimulacro} preguntas · apruebas con ${estado.aciertosPara(estado.preguntasSimulacro)} en ${estado.nombre.es}',
              onTap: () {
                if (estado == null) {
                  Navigator.pushReplacementNamed(context, 'elegirEstado');
                } else {
                  prov.iniciarExamen();
                  Navigator.pushReplacementNamed(context, 'examen');
                }
              },
            ),
            if (prov.hayExamen) ...[
              const SizedBox(height: 12),
              _cardSecundaria(
                icon: Icons.history_rounded,
                titulo: 'Ver mi último examen',
                onTap: () => Navigator.pushReplacementNamed(context, 'resultado'),
              ),
            ],
            const SizedBox(height: 22),
            const TituloSeccion('Tu examen'),
            const SizedBox(height: 10),
            _cardOpcion(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF1565C0),
              iconBg: const Color(0xFFE3F2FD),
              titulo: estado == null ? 'Elige tu estado' : 'Estado: ${estado.nombre.es}',
              subtitulo: estado == null
                  ? 'California, Texas o Florida'
                  : 'Examen oficial: ${estado.cantidadPreguntas} preguntas · toca para cambiar',
              onTap: () => Navigator.pushReplacementNamed(context, 'elegirEstado'),
            ),
            const SizedBox(height: 10),
            _cardOpcion(
              icon: Icons.translate_rounded,
              iconColor: const Color(0xFF2E7D32),
              iconBg: const Color(0xFFE8F5E9),
              titulo: prov.idioma == Idioma.es ? 'Preguntas en español' : 'Questions in English',
              subtitulo: prov.idioma == Idioma.es
                  ? 'Toca para practicar en inglés'
                  : 'Toca para volver al español',
              onTap: prov.cambiarIdioma,
              trailing: Icons.swap_horiz_rounded,
            ),
            // [10/11/2026] Sección de estudio — Claude (IA)
            const SizedBox(height: 22),
            const TituloSeccion('Aprende'),
            const SizedBox(height: 10),
            _cardOpcion(
              icon: Icons.school_rounded,
              iconColor: const Color(0xFFFFA000),
              iconBg: const Color(0xFFFFF3E0),
              titulo: 'Estudiar por tema',
              subtitulo: 'Señales, velocidad, alcohol y más, con explicaciones',
              onTap: () => Navigator.pushReplacementNamed(
                  context, estado == null ? 'elegirEstado' : 'estudioTemas'),
            ),
            const SizedBox(height: 10),
            _cardOpcion(
              icon: Icons.traffic_rounded,
              iconColor: const Color(0xFFD32F2F),
              iconBg: const Color(0xFFFFEBEE),
              titulo: 'Señales de tránsito',
              subtitulo: 'Todas las señales de EE. UU. con su texto en inglés',
              onTap: () => Navigator.pushReplacementNamed(context, 'seniales'),
            ),
            // [10/11/2026] Examen práctico — Claude (IA)
            const SizedBox(height: 10),
            _cardOpcion(
              icon: Icons.local_parking_rounded,
              iconColor: const Color(0xFF6A1B9A),
              iconBg: const Color(0xFFF3E5F5),
              titulo: 'Examen práctico',
              subtitulo: 'Maniobras paso a paso y frases del examinador',
              onTap: () => Navigator.pushReplacementNamed(context, 'practico'),
            ),
            const SizedBox(height: 28),
            const Center(
              child: Text(
                'App independiente. No está afiliada a ningún DMV\nni a otra agencia del gobierno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Paleta.muted, fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.4),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Paleta.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car_filled_rounded, color: Paleta.accent, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Examen de Manejo DMV',
                style: TextStyle(color: Paleta.primary, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Simulador del examen escrito en español',
            style: TextStyle(color: Paleta.muted, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _cardSecundaria({required IconData icon, required String titulo, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Paleta.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Paleta.accent.withValues(alpha: 0.25), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Paleta.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Paleta.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(titulo, style: const TextStyle(color: Paleta.primary, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              Icon(Icons.arrow_forward_rounded, color: Paleta.accent.withValues(alpha: 0.7), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardOpcion({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
    IconData trailing = Icons.chevron_right_rounded,
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
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22),
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
              Icon(trailing, color: Paleta.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
