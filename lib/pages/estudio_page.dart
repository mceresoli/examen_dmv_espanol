// [10/11/2026] Estudio por tema — práctica pregunta por pregunta. Al responder
// se marca la correcta (verde) y la elegida si es incorrecta (rojo) y se
// muestra la explicación con la fuente del manual. Al final, un resumen con
// "Practicar de nuevo" y "Repasar mis errores". Mismo diseño que el examen.
// Recibe como argumento de la ruta el id del tema (o kTodosLosTemas).
// — Claude (IA)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estilos/paleta.dart';
import '../model/model.dart';
import '../provider/examen_provider.dart';
import '../ads/interstitial_controller.dart';
import '../widget/comunes.dart';
import '../widget/explicacion.dart';
import 'estudio_temas_page.dart';
import 'examen_page.dart';

/// [10/11/2026] Argumentos para estudiar solo las preguntas de un grupo de
/// señales (desde el catálogo). Si la ruta recibe un String, es un id de tema.
/// — Claude (IA)
class EstudioArgs {
  const EstudioArgs({required this.titulo, required this.codigosSenial, required this.volverA, this.volverArgs});

  final String titulo;
  final Set<String> codigosSenial;

  /// Ruta (y argumentos) a la que vuelve el botón atrás.
  final String volverA;
  final Object? volverArgs;
}

class EstudioPage extends StatefulWidget {
  const EstudioPage({super.key});

  @override
  State<EstudioPage> createState() => _EstudioPageState();
}

class _EstudioPageState extends State<EstudioPage> {
  String? _temaId;
  EstudioArgs? _args;
  List<PreguntaExamen> _preguntas = [];
  int _indice = 0;
  bool _terminado = false;
  final _keyPie = GlobalKey();

  /// Solo para pruebas (test/estudio_test.dart).
  @visibleForTesting
  List<PreguntaExamen> get preguntasParaTest => _preguntas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_temaId != null) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is EstudioArgs) {
      _args = arg;
      _temaId = 'senales';
    } else {
      _temaId = arg as String? ?? kTodosLosTemas;
    }
    _armar(_todas());
  }

  List<Pregunta> _todas() {
    final prov = context.read<ExamenProvider>();
    final codigo = prov.estado?.codigo;
    final args = _args;
    if (args != null) {
      final base = codigo == null ? prov.banco.comunes : prov.banco.paraEstado(codigo);
      return base.where((p) => p.tema == 'senales' && args.codigosSenial.contains(p.senial)).toList();
    }
    if (codigo == null) return [];
    return _temaId == kTodosLosTemas ? prov.banco.paraEstado(codigo) : prov.banco.porTema(codigo, _temaId!);
  }

  void _armar(List<Pregunta> lista) {
    final rng = Random();
    final mezcladas = [...lista]..shuffle(rng);
    _preguntas = [for (final p in mezcladas) PreguntaExamen.desde(p, rng)];
    _indice = 0;
    _terminado = false;
  }

  String get _titulo => _args?.titulo ?? _tituloTema;

  String get _tituloTema =>
      _temaId == kTodosLosTemas ? 'Todos los temas' : (Tema.porId(_temaId!)?.nombre.es ?? 'Estudio');

  int get _aciertos => _preguntas.where((p) => p.esCorrecta).length;
  int get _respondidas => _preguntas.where((p) => p.respondida || p.saltada).length;

  void _responder(int i) {
    setState(() => _preguntas[_indice].elegida = i);
    _mostrarPie();
  }

  void _verRespuesta() {
    setState(() => _preguntas[_indice].saltada = true);
    _mostrarPie();
  }

  /// Desplaza la tarjeta hasta la explicación (en pantallas chicas queda abajo).
  void _mostrarPie() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _keyPie.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.1);
    });
  }

  void _siguiente() {
    setState(() {
      if (_indice < _preguntas.length - 1) {
        _indice++;
      } else {
        _terminado = true;
      }
    });
  }

  void _irAtras() => _args == null
      ? Navigator.pushReplacementNamed(context, 'estudioTemas')
      : Navigator.pushReplacementNamed(context, _args!.volverA, arguments: _args!.volverArgs);

  // [10/11/2026] Interstitial al salir, solo si practicó al menos 5 preguntas
  // (salir enseguida no muestra anuncio). — Claude (IA)
  void _volver() => _respondidas >= 5 ? kInterstitial.mostrarYNavegar(LugarInterstitial.estudio, _irAtras) : _irAtras();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ExamenProvider>(context);
    if (_preguntas.isEmpty) return const SinExamen();
    return _terminado ? _resumen() : _pregunta(prov.idioma, prov);
  }

  Widget _pregunta(Idioma idioma, ExamenProvider prov) {
    final pe = _preguntas[_indice];
    final revelada = pe.respondida || pe.saltada;

    return PantallaBase(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: _titulo,
            subtitulo: 'Pregunta ${_indice + 1} de ${_preguntas.length} · $_aciertos correctas',
            tamanio: 20,
            leading: BotonIcono(icon: Icons.arrow_back_rounded, onTap: _volver),
            trailing: [
              BotonIcono(
                icon: Icons.translate_rounded,
                onTap: prov.cambiarIdioma,
              ),
            ],
          ),
          const SizedBox(height: 10),
          IndicadorDeProgreso(indice: _indice, total: _preguntas.length),
          const SizedBox(height: 14),
          Expanded(
            child: TarjetaPregunta(
              key: ValueKey(pe.pregunta.id),
              pe: pe,
              idioma: idioma,
              nombreEstado: prov.estado?.nombre.es ?? '',
              opcion: (i) => OpcionRespuesta(
                indice: i,
                texto: pe.opciones[i].de(idioma),
                estado: !revelada
                    ? EstadoOpcion.normal
                    : (i == pe.indiceCorrecto
                        ? EstadoOpcion.correcta
                        : (i == pe.elegida ? EstadoOpcion.incorrecta : EstadoOpcion.normal)),
                onTap: revelada ? null : () => _responder(i),
              ),
              pie: revelada
                  ? Column(
                      key: _keyPie,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _resultado(pe, idioma),
                        ExplicacionYFuente(pregunta: pe.pregunta, idioma: idioma),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          if (revelada)
            BotonPrincipal(
              icon: _indice < _preguntas.length - 1 ? Icons.arrow_forward_rounded : Icons.flag_rounded,
              titulo: _indice < _preguntas.length - 1 ? 'Siguiente pregunta' : 'Ver resumen',
              onTap: _siguiente,
            )
          else
            BotonTexto(icon: Icons.visibility_rounded, label: 'Ver la respuesta', onPressed: _verRespuesta),
        ],
      ),
    );
  }

  Widget _resultado(PreguntaExamen pe, Idioma idioma) {
    final ok = pe.esCorrecta;
    final saltada = !pe.respondida;
    final color = saltada ? Colors.grey.shade700 : (ok ? Paleta.success : Paleta.danger);
    final texto = saltada
        ? (idioma == Idioma.es ? 'Esta es la respuesta correcta' : 'This is the correct answer')
        : ok
            ? (idioma == Idioma.es ? '¡Correcto!' : 'Correct!')
            : (idioma == Idioma.es ? 'Incorrecto' : 'Incorrect');
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Row(
        children: [
          Icon(saltada ? Icons.info_rounded : (ok ? Icons.check_circle_rounded : Icons.cancel_rounded),
              color: color, size: 20),
          const SizedBox(width: 6),
          Flexible(child: Text(texto, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _resumen() {
    final total = _preguntas.length;
    final errores = _preguntas.where((p) => !p.esCorrecta).map((p) => p.pregunta).toList();
    final porcentaje = total == 0 ? 0 : (100 * _aciertos / total).round();

    return PantallaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Encabezado(
            titulo: _titulo,
            subtitulo: 'Terminaste el tema',
            leading: BotonIcono(icon: Icons.arrow_back_rounded, onTap: _volver),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  gradient: errores.isEmpty ? Paleta.gradienteAprobado : Paleta.gradienteAccent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Icon(errores.isEmpty ? Icons.emoji_events_rounded : Icons.menu_book_rounded,
                        color: Colors.white, size: 44),
                    const SizedBox(height: 10),
                    Text(
                      errores.isEmpty ? '¡Sin errores!' : '$_aciertos de $total correctas',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$porcentaje % de aciertos · $_respondidas preguntas vistas',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (errores.isNotEmpty) ...[
            BotonPrincipal(
              icon: Icons.replay_rounded,
              titulo: 'Repasar mis errores',
              subtitulo: '${errores.length} preguntas',
              onTap: () => setState(() => _armar(errores)),
            ),
            const SizedBox(height: 8),
          ],
          BotonTexto(
            icon: Icons.shuffle_rounded,
            label: _args == null ? 'Practicar el tema de nuevo' : 'Practicar estas señales de nuevo',
            onPressed: () => setState(() => _armar(_todas())),
          ),
          BotonTexto(
              icon: Icons.list_rounded,
              label: _args == null ? 'Volver a los temas' : 'Volver a las señales',
              onPressed: _volver),
        ],
      ),
    );
  }
}
