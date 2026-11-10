// [10/11/2026] Catálogo de señales (assets/preguntas/catalogo_seniales.json):
// tipos (reglamentarias, advertencia...) → grupos → señales. — Claude (IA)

import 'texto_bilingue.dart';

class SenialCatalogo {
  const SenialCatalogo({required this.codigo, required this.significado, this.consejo});

  /// Código MUTCD; también es el nombre de la imagen (`assets/seniales/CODIGO.png`).
  final String codigo;
  final TextoBilingue significado;
  final String? consejo;

  factory SenialCatalogo.fromJson(Map<String, dynamic> j) => SenialCatalogo(
        codigo: j['codigo'] as String,
        significado: TextoBilingue.fromJson(j['significado']),
        consejo: j['consejo'] as String?,
      );
}

class GrupoSeniales {
  const GrupoSeniales({required this.id, required this.nombre, required this.seniales});

  final String id;
  final TextoBilingue nombre;
  final List<SenialCatalogo> seniales;

  factory GrupoSeniales.fromJson(Map<String, dynamic> j) => GrupoSeniales(
        id: j['id'] as String,
        nombre: TextoBilingue.fromJson(j['nombre']),
        seniales: [for (final s in j['seniales'] as List) SenialCatalogo.fromJson(s as Map<String, dynamic>)],
      );
}

class TipoSeniales {
  const TipoSeniales({required this.id, required this.nombre, required this.descripcion, required this.grupos});

  final String id;
  final TextoBilingue nombre;
  final String descripcion;
  final List<GrupoSeniales> grupos;

  factory TipoSeniales.fromJson(Map<String, dynamic> j) => TipoSeniales(
        id: j['id'] as String,
        nombre: TextoBilingue.fromJson(j['nombre']),
        descripcion: j['descripcion'] as String,
        grupos: [for (final g in j['grupos'] as List) GrupoSeniales.fromJson(g as Map<String, dynamic>)],
      );
}
