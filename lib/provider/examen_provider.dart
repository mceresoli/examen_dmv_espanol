// [06/11/2026] Estado del simulacro: estado de EE. UU. elegido, idioma de las
// preguntas, examen en curso y pregunta actual. El estado y el idioma se
// guardan en el teléfono (shared_preferences). — Claude (IA)

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/model.dart';
import '../services/banco_preguntas_service.dart';

class ExamenProvider with ChangeNotifier {
  static const _kEstado = 'estado_eeuu';
  static const _kIdioma = 'idioma_preguntas';

  final BancoPreguntasService banco = BancoPreguntasService.instancia;

  String? _codigoEstado;
  Idioma _idioma = Idioma.es;
  Examen? _examen;
  int _indice = 0;

  Future<void> cargarPreferencias() async {
    final p = await SharedPreferences.getInstance();
    _codigoEstado = p.getString(_kEstado);
    _idioma = p.getString(_kIdioma) == 'en' ? Idioma.en : Idioma.es;
    notifyListeners();
  }

  // ── Estado de EE. UU. ──
  EstadoEEUU? get estado =>
      _codigoEstado == null ? null : banco.estados.where((e) => e.codigo == _codigoEstado).firstOrNull;

  Future<void> elegirEstado(String codigo) async {
    _codigoEstado = codigo;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kEstado, codigo);
  }

  /// Nombre del estado para un código de manual ("CA" -> "California").
  String nombreEstado(String codigo) =>
      banco.estados.where((e) => e.codigo == codigo).firstOrNull?.nombre.es ?? codigo;

  // ── Idioma de las preguntas ──
  Idioma get idioma => _idioma;

  Future<void> cambiarIdioma() async {
    _idioma = _idioma == Idioma.es ? Idioma.en : Idioma.es;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kIdioma, _idioma.name);
  }

  // ── Simulacro ──
  Examen? get examen => _examen;
  bool get hayExamen => _examen != null && _examen!.preguntas.isNotEmpty;
  int get indice => _indice;
  int get total => _examen?.preguntas.length ?? 0;
  PreguntaExamen get actual => _examen!.preguntas[_indice];
  bool get esPrimera => _indice == 0;
  bool get esUltima => _indice >= total - 1;

  /// Genera un simulacro nuevo para el estado elegido.
  void iniciarExamen() {
    final codigo = _codigoEstado;
    if (codigo == null) return;
    _examen = banco.generarExamen(codigo);
    _indice = 0;
    _repaso = const [];
    notifyListeners();
  }

  void responder(int opcion) {
    actual
      ..elegida = opcion
      ..saltada = false;
  }

  void saltar() => actual.saltada = true;

  void siguiente() {
    if (!esUltima) {
      _indice++;
      notifyListeners();
    }
  }

  void anterior() {
    if (_indice > 0) {
      _indice--;
      notifyListeners();
    }
  }

  /// Vuelve a la primera pregunta (para el repaso).
  void irAlPrincipio() {
    _indice = 0;
    notifyListeners();
  }

  // ── Repaso ──
  // [10/11/2026] El repaso recorre una lista de posiciones del examen: todas
  // o solo los errores (incorrectas y saltadas), para "Repasar sólo mis
  // errores" con anuncio bonificado. — Claude (IA)
  List<int> _repaso = const [];
  int _posRepaso = 0;
  bool _soloErrores = false;

  bool get soloErrores => _soloErrores;
  int get posRepaso => _posRepaso;
  int get totalRepaso => _repaso.length;
  PreguntaExamen get actualRepaso => _examen!.preguntas[_repaso[_posRepaso]];
  bool get esPrimeraRepaso => _posRepaso == 0;
  bool get esUltimaRepaso => _posRepaso >= _repaso.length - 1;

  void iniciarRepaso({bool soloErrores = false, bool notificar = true}) {
    final preguntas = _examen?.preguntas ?? const <PreguntaExamen>[];
    final errores = [for (var i = 0; i < preguntas.length; i++) if (!preguntas[i].esCorrecta) i];
    _soloErrores = soloErrores && errores.isNotEmpty;
    _repaso = _soloErrores ? errores : [for (var i = 0; i < preguntas.length; i++) i];
    _posRepaso = 0;
    if (notificar) notifyListeners();
  }

  void siguienteRepaso() {
    if (!esUltimaRepaso) {
      _posRepaso++;
      notifyListeners();
    }
  }

  void anteriorRepaso() {
    if (_posRepaso > 0) {
      _posRepaso--;
      notifyListeners();
    }
  }
}
