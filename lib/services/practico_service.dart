// [10/11/2026] Carga assets/practico/practico.json (sección "Examen práctico"). — Claude (IA)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/model.dart';

class PracticoService {
  PracticoService._();
  static final PracticoService instancia = PracticoService._();

  final List<Maniobra> _maniobras = [];
  final Map<String, EvaluacionEstado> _evaluacion = {};
  final List<FraseExaminador> _frases = [];
  TextoBilingue? notaFrases;
  FuenteManual? fuenteFrases;

  List<Maniobra> get maniobras => List.unmodifiable(_maniobras);
  List<FraseExaminador> get frases => List.unmodifiable(_frases);

  Future<void> cargar({AssetBundle? bundle}) async {
    if (_maniobras.isNotEmpty) return;
    try {
      final data = json.decode(await (bundle ?? rootBundle).loadString('assets/practico/practico.json'))
          as Map<String, dynamic>;
      _maniobras.addAll([for (final m in data['maniobras'] as List) Maniobra.fromJson(m as Map<String, dynamic>)]);
      (data['evaluacion'] as Map<String, dynamic>).forEach((codigo, e) {
        _evaluacion[codigo] = EvaluacionEstado.fromJson(e as Map<String, dynamic>);
      });
      _frases.addAll([for (final f in data['frases'] as List) FraseExaminador.fromJson(f as Map<String, dynamic>)]);
      notaFrases = data['notaFrases'] == null ? null : TextoBilingue.fromJson(data['notaFrases']);
      fuenteFrases =
          data['fuenteFrases'] == null ? null : FuenteManual.fromJson(data['fuenteFrases'] as Map<String, dynamic>);
      debugPrint('[Práctico] ${_maniobras.length} maniobras, ${_frases.length} frases');
    } catch (e) {
      debugPrint('[Práctico] no se pudo cargar: $e');
    }
  }

  Maniobra? maniobra(String id) {
    for (final m in _maniobras) {
      if (m.id == id) return m;
    }
    return null;
  }

  EvaluacionEstado? evaluacion(String? codigoEstado) => codigoEstado == null ? null : _evaluacion[codigoEstado];

  /// Maniobras ordenadas: primero las que se evalúan en [codigoEstado].
  List<Maniobra> ordenadasPara(String? codigoEstado) {
    final ids = evaluacion(codigoEstado)?.maniobras ?? const <String>[];
    final primero = ids.map(maniobra).whereType<Maniobra>().toList();
    return [...primero, for (final m in _maniobras) if (!ids.contains(m.id)) m];
  }
}
