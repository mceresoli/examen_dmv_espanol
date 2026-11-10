// [05/11/2026] Pregunta del banco. A diferencia de la app argentina, la
// pregunta es inmutable: la respuesta elegida por el usuario se guarda en
// PreguntaExamen (model/examen.dart), no acá. — Claude (IA)

import 'tema.dart';
import 'texto_bilingue.dart';

/// Valor de "estado" para las preguntas que sirven en todos los estados.
const String kEstadoComun = 'COMUN';

/// De qué parte del manual oficial sale la pregunta ("Ver en el manual").
class FuenteManual {
  const FuenteManual({required this.manual, required this.seccion, this.pagina, this.url});

  /// Estado del manual: "CA", "TX", "FL".
  final String manual;
  final String seccion;
  final int? pagina;
  final String? url;

  factory FuenteManual.fromJson(Map<String, dynamic> json) => FuenteManual(
        manual: json['manual'] as String,
        seccion: json['seccion'] as String,
        pagina: json['pagina'] as int?,
        url: json['url'] as String?,
      );
}

class Pregunta {
  const Pregunta({
    required this.id,
    required this.estado,
    required this.tema,
    required this.enunciado,
    required this.opciones,
    required this.correcta,
    this.explicacion,
    this.senial,
    this.imagen,
    this.fuente,
    this.mezclarOpciones = true,
    this.revisada = false,
  });

  /// Único en todo el banco: "COMUN-0001", "CA-0001", "TX-0001"...
  final String id;

  /// kEstadoComun o el código del estado ("CA", "TX", "FL").
  final String estado;

  /// Id de Tema (model/tema.dart).
  final String tema;

  final TextoBilingue enunciado;
  final List<TextoBilingue> opciones;

  /// Índice (desde 0) de la opción correcta dentro de [opciones].
  final int correcta;

  final TextoBilingue? explicacion;

  /// Código MUTCD de la señal que acompaña a la pregunta ("R1-1" = ALTO).
  final String? senial;

  /// Imagen propia (ruta de asset), para preguntas que no son de una señal.
  final String? imagen;

  final FuenteManual? fuente;

  /// false cuando el orden importa ("Todas las anteriores", "A y B").
  final bool mezclarOpciones;

  /// Solo las revisadas a mano se muestran en la versión publicada.
  final bool revisada;

  bool get esComun => estado == kEstadoComun;

  factory Pregunta.fromJson(Map<String, dynamic> json, {required String estado}) => Pregunta(
        id: json['id'] as String,
        estado: estado,
        tema: json['tema'] as String,
        enunciado: TextoBilingue.fromJson(json['enunciado']),
        opciones: (json['opciones'] as List).map(TextoBilingue.fromJson).toList(),
        correcta: json['correcta'] as int,
        explicacion: json['explicacion'] == null ? null : TextoBilingue.fromJson(json['explicacion']),
        senial: json['senial'] as String?,
        imagen: json['imagen'] as String?,
        fuente: json['fuente'] == null ? null : FuenteManual.fromJson(json['fuente'] as Map<String, dynamic>),
        mezclarOpciones: json['mezclarOpciones'] as bool? ?? true,
        revisada: json['revisada'] as bool? ?? false,
      );

  /// Problemas de carga de datos. Lista vacía = pregunta válida.
  List<String> validar() {
    final errores = <String>[];
    if (id.trim().isEmpty) errores.add('id vacío');
    if (!esComun && !id.startsWith('$estado-')) errores.add('el id debería empezar con "$estado-"');
    if (Tema.porId(tema) == null) errores.add('tema desconocido "$tema"');
    if (enunciado.es.trim().isEmpty) errores.add('enunciado vacío');
    if (opciones.length < 2 || opciones.length > 5) errores.add('debe tener entre 2 y 5 opciones');
    if (correcta < 0 || correcta >= opciones.length) errores.add('"correcta" fuera de rango');
    if (opciones.any((o) => o.es.trim().isEmpty)) errores.add('hay una opción vacía');
    if (fuente == null) errores.add('falta la fuente del manual');
    return errores.map((e) => '$id: $e').toList();
  }
}
