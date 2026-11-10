// [05/11/2026] Un simulacro en curso o terminado. Reemplaza a Examen +
// EstadoExamenProvider de la app argentina: la cantidad de preguntas y el
// mínimo para aprobar salen del estado elegido, no están fijos en 20.
// — Claude (IA)

import 'dart:math';

import 'estado_eeuu.dart';
import 'pregunta.dart';
import 'texto_bilingue.dart';

class PreguntaExamen {
  PreguntaExamen(this.pregunta, this.ordenOpciones);

  final Pregunta pregunta;

  /// Orden en que se muestran las opciones (índices de pregunta.opciones).
  final List<int> ordenOpciones;

  /// Índice elegido por el usuario, en el orden mostrado. null = sin responder.
  int? elegida;

  /// El usuario tocó "Saltar pregunta". [06/11/2026] — Claude (IA)
  bool saltada = false;

  List<TextoBilingue> get opciones => [
    for (final i in ordenOpciones) pregunta.opciones[i],
  ];
  int get indiceCorrecto => ordenOpciones.indexOf(pregunta.correcta);
  bool get respondida => elegida != null;
  bool get esCorrecta =>
      elegida != null && ordenOpciones[elegida!] == pregunta.correcta;

  factory PreguntaExamen.desde(Pregunta p, Random random) {
    final orden = List<int>.generate(p.opciones.length, (i) => i);
    if (p.mezclarOpciones) orden.shuffle(random);
    return PreguntaExamen(p, orden);
  }
}

class Examen {
  Examen({required this.estado, required this.preguntas});

  final EstadoEEUU estado;
  final List<PreguntaExamen> preguntas;

  int get aciertos => preguntas.where((p) => p.esCorrecta).length;
  int get respondidas => preguntas.where((p) => p.respondida).length;
  int get errores => respondidas - aciertos;

  /// Para mostrar en resultados: todo lo que no es acierto (errores + saltadas
  /// + sin responder si abandonó).
  int get incorrectas => preguntas.length - aciertos;
  bool get terminado => respondidas == preguntas.length;

  /// Aciertos necesarios para aprobar ESTE simulacro: el mismo porcentaje que
  /// el examen oficial, redondeado hacia arriba (nunca más fácil que el real).
  /// Con la cantidad oficial: CA 30/36, TX 21/30, FL 40/50. En debug (5): CA 5, TX 4, FL 4.
  int get aciertosNecesarios => estado.aciertosPara(preguntas.length);

  bool get aprobado => aciertos >= aciertosNecesarios;

  List<PreguntaExamen> get conError =>
      preguntas.where((p) => p.respondida && !p.esCorrecta).toList();

  /// Arma un simulacro de [cantidad] preguntas: [proporcionEstado] propias del
  /// estado y el resto del banco común. Si uno no alcanza, completa con el otro.
  static Examen generar({
    required EstadoEEUU estado,
    required List<Pregunta> delEstado,
    required List<Pregunta> comunes,

    double proporcionEstado = 0.5,
    // [10/11/2026] Máximo de preguntas de señales (tema 'senales') dentro del
    // simulacro, para que el banco grande de señales no lo acapare. — Claude (IA)
    double proporcionSeniales = 0.2,
    Random? random,
  }) {

    final rng = random ?? Random();
    final total = estado.preguntasSimulacro;
    final propias = [...delEstado]..shuffle(rng);
    final generales = [...comunes]..shuffle(rng);

    var nEstado = min((total * proporcionEstado).round(), propias.length);
    var nComun = min(total - nEstado, generales.length);
    // Si el banco común no alcanza, se completa con más preguntas del estado.
    nEstado = min(total - nComun, propias.length);

    final senalesComunes = generales.where((p) => p.tema == 'senales').toList();
    final otrasComunes = generales.where((p) => p.tema != 'senales').toList();
    var nSen = min(min((total * proporcionSeniales).round(), senalesComunes.length), nComun);
    final nOtras = min(nComun - nSen, otrasComunes.length);
    // Si no hay suficientes preguntas comunes de otros temas, se completa con señales.
    nSen = min(nComun - nOtras, senalesComunes.length);

    final elegidas = [
      ...propias.take(nEstado),
      ...senalesComunes.take(nSen),
      ...otrasComunes.take(nOtras),
    ]..shuffle(rng);
    return Examen(
      estado: estado,
      preguntas: [for (final p in elegidas) PreguntaExamen.desde(p, rng)],
    );
  }
}
