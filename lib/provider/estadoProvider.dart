import 'package:flutter/material.dart';

class EstadoProvider with ChangeNotifier {
  // Lleva la cuenta de la cantidad de preguntas.
  int indiceDePreguntas = 0;
  int currentEventId = 0;

  void setCurrentEventId(int id) {
    currentEventId = id;
    notifyListeners();
  }

  void setProximaPregunta() {
    indiceDePreguntas += 1;
    notifyListeners();
  }

  void setAnteriorPregunta() {
    indiceDePreguntas -= 1;
    notifyListeners();
  }
}
