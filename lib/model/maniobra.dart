// [10/11/2026] Examen práctico: maniobras paso a paso, qué evalúa cada estado y
// frases del examinador en inglés. Datos en assets/practico/practico.json. — Claude (IA)

import 'pregunta.dart';
import 'texto_bilingue.dart';

class PasoManiobra {
  const PasoManiobra({required this.texto, this.imagen});

  final TextoBilingue texto;

  /// Nombre del archivo en assets/practico/ (opcional).
  final String? imagen;

  String? get rutaImagen => imagen == null ? null : 'assets/practico/$imagen';

  factory PasoManiobra.fromJson(Map<String, dynamic> json) => PasoManiobra(
        texto: TextoBilingue.fromJson(json['texto']),
        imagen: json['imagen'] as String?,
      );
}

class Maniobra {
  const Maniobra({
    required this.id,
    required this.icono,
    required this.titulo,
    required this.resumen,
    required this.pasos,
    this.consejos = const [],
    this.errores = const [],
    this.video,
    this.fuentes = const [],
  });

  final String id;
  final String icono;
  final TextoBilingue titulo;
  final TextoBilingue resumen;
  final List<PasoManiobra> pasos;
  final List<TextoBilingue> consejos;
  final List<TextoBilingue> errores;
  final String? video;
  final List<FuenteManual> fuentes;

  /// Primera imagen de los pasos, para la tarjeta del menú.
  String? get miniatura {
    for (final p in pasos) {
      if (p.rutaImagen != null) return p.rutaImagen;
    }
    return null;
  }

  static List<TextoBilingue> _lista(dynamic l) => [for (final x in (l as List? ?? const [])) TextoBilingue.fromJson(x)];

  factory Maniobra.fromJson(Map<String, dynamic> json) => Maniobra(
        id: json['id'] as String,
        icono: json['icono'] as String,
        titulo: TextoBilingue.fromJson(json['titulo']),
        resumen: TextoBilingue.fromJson(json['resumen']),
        pasos: [for (final p in json['pasos'] as List) PasoManiobra.fromJson(p as Map<String, dynamic>)],
        consejos: _lista(json['consejos']),
        errores: _lista(json['errores']),
        video: json['video'] as String?,
        fuentes: [for (final f in (json['fuentes'] as List? ?? const [])) FuenteManual.fromJson(f as Map<String, dynamic>)],
      );
}

/// Qué evalúa el examen práctico de un estado.
class EvaluacionEstado {
  const EvaluacionEstado({required this.resumen, required this.puntos, required this.maniobras, this.fuente});

  final TextoBilingue resumen;
  final List<TextoBilingue> puntos;

  /// Ids de las maniobras que conviene practicar para ese estado, en orden.
  final List<String> maniobras;
  final FuenteManual? fuente;

  factory EvaluacionEstado.fromJson(Map<String, dynamic> json) => EvaluacionEstado(
        resumen: TextoBilingue.fromJson(json['resumen']),
        puntos: [for (final p in json['puntos'] as List) TextoBilingue.fromJson(p)],
        maniobras: [for (final m in json['maniobras'] as List) m as String],
        fuente: json['fuente'] == null ? null : FuenteManual.fromJson(json['fuente'] as Map<String, dynamic>),
      );
}

/// Indicación del examinador: en inglés (como la vas a escuchar) y en español.
class FraseExaminador {
  const FraseExaminador({required this.en, required this.es});

  final String en;
  final String es;

  factory FraseExaminador.fromJson(Map<String, dynamic> json) =>
      FraseExaminador(en: json['en'] as String, es: json['es'] as String);
}
