// [05/11/2026] Valida los JSON del banco de preguntas sin abrir la app.
// Correr con:  flutter test test/banco_preguntas_test.dart
// Conviene correrlo cada vez que se cargan preguntas nuevas. — Claude (IA)

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:examen_manejo_dmv_espanol/config/appConfig.dart';
import 'package:examen_manejo_dmv_espanol/model/model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _leer(String archivo) =>
    json.decode(File('assets/preguntas/$archivo').readAsStringSync()) as Map<String, dynamic>;

void main() {
  final estados = (_leer('estados.json')['estados'] as List)
      .map((e) => EstadoEEUU.fromJson(e as Map<String, dynamic>))
      .toList();

  // [10/11/2026] seniales.json también es parte del banco común. — Claude (IA)
  final archivos = <(String, String)>[
    (kEstadoComun, 'comun.json'),
    (kEstadoComun, 'seniales.json'),
    for (final e in estados) (e.codigo, e.archivoPreguntas),
  ];

  test('estados.json es coherente', () {
    expect(estados, isNotEmpty);
    for (final e in estados) {
      expect(e.aciertosParaAprobar, lessThanOrEqualTo(e.cantidadPreguntas), reason: e.codigo);
    }
  });

  test('todas las preguntas son válidas y los ids no se repiten', () {
    final errores = <String>[];
    final ids = <String>{};
    for (final (estado, archivo) in archivos) {
      final data = _leer(archivo);
      expect(data['estado'], estado, reason: '$archivo: el campo "estado" no coincide');
      for (final raw in data['preguntas'] as List) {
        final p = Pregunta.fromJson(raw as Map<String, dynamic>, estado: estado);
        errores.addAll(p.validar().map((e) => '$archivo -> $e'));
        if (!ids.add(p.id)) errores.add('$archivo -> id repetido: ${p.id}');
      }
    }
    expect(errores, isEmpty, reason: errores.join('\n'));
  });

  test('el simulacro respeta la cantidad del estado y mezcla bien las opciones', () {
    Pregunta fake(String id, String estado) => Pregunta(
          id: id,
          estado: estado,
          tema: 'senales',
          enunciado: TextoBilingue(es: id),
          opciones: const [TextoBilingue(es: 'a'), TextoBilingue(es: 'b'), TextoBilingue(es: 'c')],
          correcta: 1,
        );
    final ca = estados.firstWhere((e) => e.codigo == 'CA');
    Examen generar() => Examen.generar(
          estado: ca,
          delEstado: [for (var i = 0; i < 100; i++) fake('CA-$i', 'CA')],
          comunes: [for (var i = 0; i < 100; i++) fake('COMUN-$i', kEstadoComun)],
          random: Random(1),
        );
    final debugOriginal = AppConfig.IS_DEBUG;
    addTearDown(() => AppConfig.IS_DEBUG = debugOriginal);

    // [10/11/2026] Producción: 15 preguntas en todos los estados (CA aprueba
    // con 13: 30 de 36 es el 83 %). — Claude (IA)
    AppConfig.IS_DEBUG = false;
    final examen = generar();
    expect(examen.preguntas.length, 15);
    expect(examen.preguntas.map((p) => p.pregunta.id).toSet().length, 15);
    expect(examen.aciertosNecesarios, 13);
    expect({for (final e in estados) e.codigo: e.aciertosPara(e.preguntasSimulacro)}, {'CA': 13, 'TX': 11, 'FL': 12});
    for (final p in examen.preguntas) {
      p.elegida = p.indiceCorrecto;
      expect(p.opciones[p.indiceCorrecto].es, 'b');
    }
    expect(examen.aprobado, isTrue);

    // Debug: siempre 5 preguntas.
    AppConfig.IS_DEBUG = true;
    expect(generar().preguntas.length, 5);
  });

  test('aciertos necesarios con la cantidad oficial', () {
    final esperado = {'CA': 30, 'TX': 21, 'FL': 40};
    for (final e in estados) {
      final ex = Examen(estado: e, preguntas: List.generate(
        e.cantidadPreguntas,
        (i) => PreguntaExamen(
          Pregunta(id: '${e.codigo}-$i', estado: e.codigo, tema: 'senales',
            enunciado: const TextoBilingue(es: 'x'),
            opciones: const [TextoBilingue(es: 'a'), TextoBilingue(es: 'b')], correcta: 0),
          [0, 1]),
      ));
      expect(ex.aciertosNecesarios, esperado[e.codigo], reason: e.codigo);
    }
  });

  test('las señales no pasan del 20 % del simulacro', () {
    Pregunta fake(String id, String tema) => Pregunta(
          id: id, estado: kEstadoComun, tema: tema,
          enunciado: TextoBilingue(es: id),
          opciones: const [TextoBilingue(es: 'a'), TextoBilingue(es: 'b')], correcta: 0);
    final fl = estados.firstWhere((e) => e.codigo == 'FL');
    final ex = Examen.generar(
      estado: fl,
      delEstado: const [],
      comunes: [
        for (var i = 0; i < 300; i++) fake('SEN-$i', 'senales'),
        for (var i = 0; i < 300; i++) fake('C-$i', 'seguridad'),
      ],
      random: Random(3),
    );
    final n = ex.preguntas.length;
    final sen = ex.preguntas.where((p) => p.pregunta.tema == 'senales').length;
    expect(sen, (n * 0.2).round());
  });
}
