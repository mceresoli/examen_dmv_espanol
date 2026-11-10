// [05/11/2026] Carga el banco de preguntas desde assets/preguntas/:
//   estados.json  -> configuración de examen de cada estado
//   comun.json    -> preguntas válidas en todos los estados
//   ca.json, tx.json, fl.json... -> preguntas propias de cada estado
// Para actualizar preguntas solo hay que tocar los JSON, no el código.
// En la versión publicada (release) solo se muestran las preguntas con
// "revisada": true. — Claude (IA)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/model.dart';

class BancoPreguntasService {
  BancoPreguntasService._();
  static final BancoPreguntasService instancia = BancoPreguntasService._();

  static const String carpeta = 'assets/preguntas';

  /// En debug se ven también las preguntas sin revisar, para probarlas.
  bool soloRevisadas = kReleaseMode;

  final List<EstadoEEUU> _estados = [];
  final Map<String, List<Pregunta>> _preguntas = {};
  final List<String> errores = [];
  bool _cargado = false;

  bool get cargado => _cargado;
  List<EstadoEEUU> get estados => List.unmodifiable(_estados);

  Future<void> cargar({AssetBundle? bundle}) async {
    if (_cargado) return;
    final b = bundle ?? rootBundle;
    errores.clear();

    final estadosJson = json.decode(await b.loadString('$carpeta/estados.json')) as Map<String, dynamic>;
    _estados
      ..clear()
      ..addAll((estadosJson['estados'] as List).map((e) => EstadoEEUU.fromJson(e as Map<String, dynamic>)));

    // [10/11/2026] Las preguntas de señales viven en su propio archivo, pero
    // forman parte del banco común (valen para todos los estados). — Claude (IA)
    _preguntas[kEstadoComun] = [
      ...await _cargarArchivo(b, 'comun.json', kEstadoComun),
      ...await _cargarArchivo(b, 'seniales.json', kEstadoComun),
    ];
    for (final e in _estados) {
      _preguntas[e.codigo] = await _cargarArchivo(b, e.archivoPreguntas, e.codigo);
    }

    _validarIdsUnicos();
    _cargado = true;
    if (errores.isNotEmpty) {
      debugPrint('[Banco] ${errores.length} problema(s):\n${errores.join('\n')}');
    }
    debugPrint('[Banco] ${_preguntas.entries.map((e) => '${e.key}: ${e.value.length}').join(', ')}');
  }

  Future<List<Pregunta>> _cargarArchivo(AssetBundle b, String archivo, String estado) async {
    try {
      final data = json.decode(await b.loadString('$carpeta/$archivo')) as Map<String, dynamic>;
      final lista = <Pregunta>[];
      for (final raw in data['preguntas'] as List) {
        try {
          final p = Pregunta.fromJson(raw as Map<String, dynamic>, estado: estado);
          final problemas = p.validar();
          if (problemas.isEmpty) {
            lista.add(p);
          } else {
            errores.addAll(problemas.map((e) => '$archivo -> $e'));
          }
        } catch (e) {
          errores.add('$archivo -> pregunta mal formada (${raw is Map ? raw['id'] : '?'}): $e');
        }
      }
      return lista;
    } catch (e) {
      errores.add('$archivo -> no se pudo leer: $e');
      return [];
    }
  }

  void _validarIdsUnicos() {
    final vistos = <String>{};
    for (final p in _preguntas.values.expand((l) => l)) {
      if (!vistos.add(p.id)) errores.add('id repetido: ${p.id}');
    }
  }

  List<Pregunta> _visibles(List<Pregunta>? l) =>
      (l ?? const <Pregunta>[]).where((p) => !soloRevisadas || p.revisada).toList();

  EstadoEEUU estado(String codigo) => _estados.firstWhere((e) => e.codigo == codigo);

  List<Pregunta> get comunes => _visibles(_preguntas[kEstadoComun]);

  List<Pregunta> delEstado(String codigo) => _visibles(_preguntas[codigo]);

  /// Todo lo que aplica a un estado: comunes + propias.
  List<Pregunta> paraEstado(String codigo) => [...comunes, ...delEstado(codigo)];

  /// Estudio por tema ("Señales", "Alcohol y drogas"...).
  List<Pregunta> porTema(String codigo, String temaId) =>
      paraEstado(codigo).where((p) => p.tema == temaId).toList();

  Pregunta? porId(String id) {
    for (final p in _preguntas.values.expand((l) => l)) {
      if (p.id == id) return p;
    }
    return null;
  }

  Examen generarExamen(String codigoEstado) => Examen.generar(
        estado: estado(codigoEstado),
        delEstado: delEstado(codigoEstado),
        comunes: comunes,
      );
}
