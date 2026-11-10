// [05/11/2026] Configuración del examen escrito de cada estado. Se lee de
// assets/preguntas/estados.json. "formatoConfirmado" queda en false hasta
// verificar cantidad de preguntas y mínimo para aprobar en el sitio oficial.
// — Claude (IA)

import '../config/appConfig.dart';
import 'texto_bilingue.dart';

class EstadoEEUU {
  const EstadoEEUU({
    required this.codigo,
    required this.nombre,
    required this.cantidadPreguntas,
    required this.aciertosParaAprobar,
    this.formatoConfirmado = false,
    this.urlManualEs,
    this.urlManualEn,
    this.urlFuenteFormato,
    this.notaFormato,
  });

  /// Código de dos letras: "CA", "TX", "FL"...
  final String codigo;
  final TextoBilingue nombre;
  final int cantidadPreguntas;
  final int aciertosParaAprobar;
  final bool formatoConfirmado;
  final String? urlManualEs;
  // [06/11/2026] Manual en inglés: en Texas es la fuente vigente (el de
  // español es de 2017). — Claude (IA)
  final String? urlManualEn;
  final String? urlFuenteFormato;

  /// De dónde sale el formato y qué falta confirmar (solo para desarrollo).
  final String? notaFormato;

  int get erroresPermitidos => cantidadPreguntas - aciertosParaAprobar;

  /// Aciertos necesarios en un examen de [n] preguntas con el mismo porcentaje
  /// que el oficial, redondeado hacia arriba. [06/11/2026] — Claude (IA)
  int aciertosPara(int n) => (n * aciertosParaAprobar + cantidadPreguntas - 1) ~/ cantidadPreguntas;
  double get porcentajeAprobacion => aciertosParaAprobar * 100 / cantidadPreguntas;

  /// [10/11/2026] Cantidad de preguntas de cada simulacro: 15 en todos los
  /// estados, o 5 en modo debug (AppConfig.IS_DEBUG) para probar rápido.
  /// Se aprueba con el mismo % que el examen oficial. La cantidad oficial
  /// queda en [cantidadPreguntas] (estados.json) por si se quiere volver a
  /// usarla: `AppConfig.IS_DEBUG ? 5 : cantidadPreguntas`. — Claude (IA)
  static const int kPreguntasSimulacro = 15;
  static const int kPreguntasSimulacroDebug = 5;
  int get preguntasSimulacro => AppConfig.IS_DEBUG ? kPreguntasSimulacroDebug : kPreguntasSimulacro;

  /// Nombre del archivo con las preguntas propias del estado.
  String get archivoPreguntas => '${codigo.toLowerCase()}.json';

  factory EstadoEEUU.fromJson(Map<String, dynamic> json) => EstadoEEUU(
        codigo: json['codigo'] as String,
        nombre: TextoBilingue.fromJson(json['nombre']),
        cantidadPreguntas: json['cantidadPreguntas'] as int,
        aciertosParaAprobar: json['aciertosParaAprobar'] as int,
        formatoConfirmado: json['formatoConfirmado'] as bool? ?? false,
        urlManualEs: json['manualEs'] as String?,
        urlManualEn: json['manualEn'] as String?,
        urlFuenteFormato: json['fuenteFormato'] as String?,
        notaFormato: json['notaFormato'] as String?,
      );
}
