// [10/11/2026] Carga el catálogo de señales para la sección "Señales de
// tránsito". — Claude (IA)

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/model.dart';

class CatalogoSenialesService {
  CatalogoSenialesService._();
  static final CatalogoSenialesService instancia = CatalogoSenialesService._();

  final List<TipoSeniales> _tipos = [];
  List<TipoSeniales> get tipos => List.unmodifiable(_tipos);

  Future<void> cargar({AssetBundle? bundle}) async {
    if (_tipos.isNotEmpty) return;
    try {
      final data = json.decode(await (bundle ?? rootBundle).loadString('assets/preguntas/catalogo_seniales.json'))
          as Map<String, dynamic>;
      _tipos.addAll([for (final t in data['tipos'] as List) TipoSeniales.fromJson(t as Map<String, dynamic>)]);
    } catch (e) {
      debugPrint('[Señales] no se pudo cargar el catálogo: $e');
    }
  }

  GrupoSeniales? grupo(String id) {
    for (final t in _tipos) {
      for (final g in t.grupos) {
        if (g.id == id) return g;
      }
    }
    return null;
  }

  int get total => _tipos.fold(0, (n, t) => n + t.grupos.fold(0, (m, g) => m + g.seniales.length));
}
