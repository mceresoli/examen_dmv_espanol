// [10/11/2026] Pedido de reseña (in_app_review) en el mejor momento: cuando el
// usuario APRUEBA un simulacro, a partir del 2do examen terminado. — Claude (IA)
//
// Por qué ahí: es el momento de mayor satisfacción y no corta ninguna tarea
// (el examen ya terminó y el interstitial, si hubo, ya se cerró). Apple
// recomienda pedirla después de un logro y nunca al abrir la app ni en medio de
// una tarea. Igual iOS decide si muestra el cartel (máximo 3 veces por año),
// así que esto solo evita pedirlo de más:
//  - aprobado y con al menos [minimoExamenes] examenes terminados;
//  - como mucho [maximoPedidos] pedidos en total y [diasEntrePedidos] entre uno
//    y otro;
//  - se pide 1,5 s después de que aparece la pantalla de resultados, para que
//    el usuario vea primero su resultado.
// Nunca se pregunta antes "¿te gusta la app?": Apple no permite filtrar a quién
// se le muestra el pedido.

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResenaService {
  ResenaService._();
  static final ResenaService instancia = ResenaService._();

  static const int minimoExamenes = 2;
  static const int maximoPedidos = 3;
  static const int diasEntrePedidos = 60;

  static const _kExamenes = 'resena.examenesTerminados';
  static const _kPedidos = 'resena.pedidos';
  static const _kUltimo = 'resena.ultimoPedidoMs';

  /// true cuando el examen recién terminado merece el pedido. Lo consume la
  /// pantalla de resultados (una sola vez).
  bool _pendiente = false;
  bool get pendiente => _pendiente;

  Future<void> _registro = Future.value();

  /// Termina cuando se guardó el último examen (la pantalla de resultados
  /// puede abrirse antes).
  Future<void> get registroListo => _registro;

  /// Se llama UNA vez al terminar cada examen (no al volver a ver el resultado).
  Future<void> registrarExamen({required bool aprobado}) => _registro = _registrar(aprobado);

  Future<void> _registrar(bool aprobado) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final examenes = (prefs.getInt(_kExamenes) ?? 0) + 1;
      await prefs.setInt(_kExamenes, examenes);
      _pendiente = aprobado && examenes >= minimoExamenes && _puedePedir(prefs);
    } catch (e) {
      debugPrint('[Reseña] $e');
    }
  }

  bool _puedePedir(SharedPreferences prefs) {
    if ((prefs.getInt(_kPedidos) ?? 0) >= maximoPedidos) return false;
    final ultimo = prefs.getInt(_kUltimo);
    if (ultimo == null) return true;
    final dias = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ultimo)).inDays;
    return dias >= diasEntrePedidos;
  }

  /// Pide la reseña si quedó pendiente. Si el sistema no la soporta no hace
  /// nada (no abre la tienda: eso solo si el usuario lo pide).
  Future<void> pedirSiCorresponde() async {
    if (!_pendiente) return;
    _pendiente = false;
    try {
      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kPedidos, (prefs.getInt(_kPedidos) ?? 0) + 1);
      await prefs.setInt(_kUltimo, DateTime.now().millisecondsSinceEpoch);
      await review.requestReview();
    } catch (e) {
      debugPrint('[Reseña] no disponible: $e');
    }
  }

  @visibleForTesting
  void reiniciarParaTest() => _pendiente = false;
}
