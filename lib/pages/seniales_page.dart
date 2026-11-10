// [10/11/2026] Catálogo de señales — tipos y grupos. Mismo diseño de tarjetas
// que el menú inicial; cada grupo muestra una señal de ejemplo. — Claude (IA)

import 'package:flutter/material.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../services/catalogo_seniales_service.dart';
import '../widget/comunes.dart';

class SenialesPage extends StatelessWidget {
  const SenialesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cat = CatalogoSenialesService.instancia;
    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: 'Señales de tránsito',
            subtitulo: '${cat.total} señales de EE. UU. con su significado en español',
            leading: BotonIcono(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, 'initialPage'),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                for (final t in cat.tipos) ...[
                  const SizedBox(height: 8),
                  TituloSeccion(t.nombre.es),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                    child: Text(t.descripcion,
                        style: const TextStyle(color: Paleta.muted, fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                  for (final g in t.grupos) ...[
                    _cardGrupo(context, g),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardGrupo(BuildContext context, GrupoSeniales g) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushReplacementNamed(context, 'grupoSeniales', arguments: g.id),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Paleta.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: Paleta.sombraSuave,
          ),
          child: Row(
            children: [
              SizedBox(width: 48, height: 48, child: SenialImagen(g.seniales.first.codigo, tamanio: 48)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.nombre.es,
                        style: const TextStyle(color: Paleta.primary, fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${g.seniales.length} señales',
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
