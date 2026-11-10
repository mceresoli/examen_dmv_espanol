// [05/11/2026] Temas del banco de preguntas. El "id" es el que se usa en los
// JSON (campo "tema"); si se agrega un tema nuevo, hay que sumarlo acá.
// — Claude (IA)

import 'texto_bilingue.dart';

class Tema {
  const Tema(this.id, this.nombre);

  final String id;
  final TextoBilingue nombre;

  static const senales = Tema('senales', TextoBilingue(es: 'Señales de tránsito', en: 'Road signs'));
  static const derechoDePaso = Tema('derecho_de_paso', TextoBilingue(es: 'Derecho de paso', en: 'Right of way'));
  static const velocidad = Tema('velocidad', TextoBilingue(es: 'Límites de velocidad', en: 'Speed limits'));
  static const carrilesGiros = Tema('carriles_giros', TextoBilingue(es: 'Carriles, giros y rebases', en: 'Lanes, turns and passing'));
  static const estacionamiento = Tema('estacionamiento', TextoBilingue(es: 'Estacionamiento', en: 'Parking'));
  static const alcoholDrogas = Tema('alcohol_drogas', TextoBilingue(es: 'Alcohol y drogas', en: 'Alcohol and drugs'));
  static const seguridad = Tema('seguridad', TextoBilingue(es: 'Manejo seguro', en: 'Safe driving'));
  static const peatonesCiclistas = Tema('peatones_ciclistas', TextoBilingue(es: 'Peatones, ciclistas y motos', en: 'Pedestrians, cyclists and motorcycles'));
  static const emergencias = Tema('emergencias', TextoBilingue(es: 'Clima y emergencias', en: 'Weather and emergencies'));
  static const licenciaLeyes = Tema('licencia_leyes', TextoBilingue(es: 'Licencia, seguro y leyes', en: 'License, insurance and laws'));

  static const List<Tema> todos = [
    senales,
    derechoDePaso,
    velocidad,
    carrilesGiros,
    estacionamiento,
    alcoholDrogas,
    seguridad,
    peatonesCiclistas,
    emergencias,
    licenciaLeyes,
  ];

  static Tema? porId(String id) {
    for (final t in todos) {
      if (t.id == id) return t;
    }
    return null;
  }
}
