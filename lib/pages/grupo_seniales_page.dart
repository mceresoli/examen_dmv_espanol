// [10/11/2026] Grilla de señales de un grupo. Al tocar una señal se abre el
// detalle (imagen grande, significado en español e inglés, consejo).
// "Practicar estas señales" abre el estudio solo con las preguntas del grupo.
// Recibe como argumento de la ruta el id del grupo. — Claude (IA)

import 'package:flutter/material.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../services/catalogo_seniales_service.dart';
import '../ads/interstitial_controller.dart';
import '../widget/comunes.dart';
import 'estudio_page.dart';

class GrupoSenialesPage extends StatelessWidget {
  const GrupoSenialesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final g = id == null ? null : CatalogoSenialesService.instancia.grupo(id);
    // [10/11/2026] Interstitial al volver a la lista (desde el 3er grupo). — Claude (IA)
    void volver() => kInterstitial.mostrarYNavegar(
        LugarInterstitial.seniales, () => Navigator.pushReplacementNamed(context, 'seniales'));

    if (g == null) {
      return PantallaBase(child: Center(child: BotonTexto(icon: Icons.arrow_back, label: 'Volver', onPressed: volver)));
    }

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: g.nombre.es,
            subtitulo: '${g.seniales.length} señales · toca una para ver su significado',
            leading: BotonIcono(icon: Icons.arrow_back_rounded, onTap: volver),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: g.seniales.length,
              itemBuilder: (ctx, i) => _cardSenial(ctx, g.seniales[i]),
            ),
          ),
          const SizedBox(height: 10),
          BotonPrincipal(
            icon: Icons.school_rounded,
            titulo: 'Practicar estas señales',
            onTap: () => Navigator.pushReplacementNamed(
              context,
              'estudio',
              arguments: EstudioArgs(
                titulo: g.nombre.es,
                codigosSenial: {for (final s in g.seniales) s.codigo},
                volverA: 'grupoSeniales',
                volverArgs: g.id,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSenial(BuildContext context, SenialCatalogo s) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _detalle(context, s),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Paleta.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: Paleta.sombraSuave,
          ),
          child: Column(
            children: [
              Expanded(child: SenialImagen(s.codigo, tamanio: 110)),
              const SizedBox(height: 8),
              Text(
                s.significado.es,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Paleta.primary, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _detalle(BuildContext context, SenialCatalogo s) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              SenialImagen(s.codigo, tamanio: 170),
              const SizedBox(height: 16),
              Center(
                child: Pill(
                  icon: Icons.tag_rounded,
                  label: 'MUTCD ${s.codigo}',
                  color: Paleta.accent,
                  bg: Paleta.accent.withValues(alpha: 0.10),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                s.significado.es,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Paleta.primary, fontSize: 18, fontWeight: FontWeight.w800, height: 1.3),
              ),
              if (s.significado.tieneIngles) ...[
                const SizedBox(height: 8),
                Text(
                  'En inglés: ${s.significado.en}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Paleta.muted, fontSize: 13.5, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                ),
              ],
              if (s.consejo != null) ...[
                const SizedBox(height: 16),
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
                        child: Text(s.consejo!,
                            style: const TextStyle(color: Paleta.primary, fontSize: 13.5, height: 1.35)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              BotonTexto(icon: Icons.close_rounded, label: 'Cerrar', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }
}
