// [05/11/2026] Texto en español con su versión en inglés (opcional).
// Toda la app muestra el español por defecto; el inglés se usa con el cambio
// de idioma de las preguntas y para mostrar el texto original de las señales.
// — Claude (IA)

enum Idioma { es, en }

class TextoBilingue {
  const TextoBilingue({required this.es, this.en});

  final String es;
  final String? en;

  bool get tieneIngles => en != null && en!.trim().isNotEmpty;

  /// Devuelve el texto en el idioma pedido. Si falta el inglés, cae al español.
  String de(Idioma idioma) => idioma == Idioma.en && tieneIngles ? en! : es;

  /// Acepta tanto `"texto"` (solo español) como `{"es": "...", "en": "..."}`.
  factory TextoBilingue.fromJson(dynamic json) {
    if (json is String) return TextoBilingue(es: json);
    final map = json as Map<String, dynamic>;
    return TextoBilingue(es: map['es'] as String, en: map['en'] as String?);
  }

  Map<String, dynamic> toJson() => {'es': es, if (en != null) 'en': en};

  @override
  String toString() => es;
}
