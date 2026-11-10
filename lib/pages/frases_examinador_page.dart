// [10/11/2026] Frases del examinador: la indicación en inglés (como la vas a
// escuchar) y qué significa. Tocar una tarjeta muestra u oculta el español
// para practicar. — Claude (IA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../services/practico_service.dart';
import '../widget/comunes.dart';
import '../widget/explicacion.dart';

class FrasesExaminadorPage extends StatefulWidget {
  const FrasesExaminadorPage({super.key});

  @override
  State<FrasesExaminadorPage> createState() => _FrasesExaminadorPageState();
}

class _FrasesExaminadorPageState extends State<FrasesExaminadorPage> {
  bool _ocultarEspanol = false;
  final Set<int> _reveladas = {};

  @override
  Widget build(BuildContext context) {
    final idioma = context.watch<ExamenProvider>().idioma;
    final srv = PracticoService.instancia;
    final frases = srv.frases;

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: 'Frases del examinador',
            subtitulo: 'Lo que te van a decir en inglés durante el examen',
            tamanio: 20,
            leading: BotonIcono(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, 'practico'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _ocultarEspanol ? 'Toca una frase para ver qué significa' : 'Oculta el español para practicar',
                  style: const TextStyle(color: Paleta.muted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              Switch.adaptive(
                value: _ocultarEspanol,
                activeTrackColor: Paleta.accent,
                onChanged: (v) => setState(() {
                  _ocultarEspanol = v;
                  _reveladas.clear();
                }),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < frases.length; i++) ...[
                  _tarjeta(i, frases[i]),
                  const SizedBox(height: 8),
                ],
                if (srv.notaFrases != null) ...[
                  const SizedBox(height: 8),
                  Text(srv.notaFrases!.de(idioma),
                      style: const TextStyle(color: Paleta.muted, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35)),
                ],
                if (srv.fuenteFrases != null) LineaFuente(srv.fuenteFrases!),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(int i, FraseExaminador f) {
    final visible = !_ocultarEspanol || _reveladas.contains(i);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _ocultarEspanol
            ? () => setState(() => _reveladas.contains(i) ? _reveladas.remove(i) : _reveladas.add(i))
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Paleta.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: Paleta.sombraSuave,
          ),
          child: Row(
            children: [
              const Icon(Icons.record_voice_over_rounded, color: Color(0xFF00838F), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('"${f.en}"',
                        style: const TextStyle(color: Paleta.primary, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(
                      visible ? f.es : '• • •',
                      style: TextStyle(
                        color: visible ? Paleta.accent2 : Paleta.muted,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
