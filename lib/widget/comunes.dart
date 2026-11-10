// [06/11/2026] Componentes visuales reutilizables, con el mismo diseño que las
// pantallas de la app argentina (header custom, botón principal en degradé,
// pills, opciones A/B/C, barra de progreso). — Claude (IA)

import 'package:flutter/material.dart';

import '../estilos/paleta.dart';
import '../model/texto_bilingue.dart';

/// Scaffold con el fondo en degradé y SafeArea.
class PantallaBase extends StatelessWidget {
  const PantallaBase({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 16),
    this.bottomNavigationBar,
  });

  final Widget child;
  final EdgeInsets padding;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: Paleta.fondo,
        child: SafeArea(child: Padding(padding: padding, child: child)),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Botón cuadrado redondeado con ícono (volver, cerrar, compartir...).
class BotonIcono extends StatelessWidget {
  const BotonIcono({super.key, required this.icon, required this.onTap, this.color = Paleta.accent});

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

/// Encabezado de pantalla: [leading] opcional, título + subtítulo, [trailing].
class Encabezado extends StatelessWidget {
  const Encabezado({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.leading,
    this.trailing = const [],
    this.tamanio = 22,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? leading;
  final List<Widget> trailing;
  final double tamanio;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 14)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: Paleta.primary,
                  fontSize: tamanio,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitulo != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitulo!,
                  style: const TextStyle(color: Paleta.muted, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                ),
              ],
            ],
          ),
        ),
        for (final w in trailing) ...[const SizedBox(width: 8), w],
      ],
    );
  }
}

/// Botón de acción principal en degradé (el "hero" de la app argentina).
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.icon,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
    this.habilitado = true,
    this.grande = false,
  });

  final IconData icon;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;
  final bool habilitado;

  /// true = versión grande del menú inicial.
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(grande ? 20 : 18);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radio,
        onTap: habilitado ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radio,
            gradient: habilitado ? Paleta.gradienteAccent : null,
            color: habilitado ? null : Colors.grey.shade300,
            boxShadow: habilitado ? Paleta.sombraAccent : null,
          ),
          padding: grande ? const EdgeInsets.all(20) : const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(grande ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: habilitado ? 0.18 : 0.45),
                  borderRadius: BorderRadius.circular(grande ? 14 : 10),
                ),
                child: Icon(icon, color: habilitado ? Colors.white : Colors.grey.shade500, size: grande ? 32 : 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: habilitado ? Colors.white : Colors.grey.shade600,
                        fontSize: grande ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitulo!,
                        style: TextStyle(
                          color: habilitado ? Colors.white70 : Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: habilitado ? Colors.white : Colors.grey.shade500, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de texto discreto (Cancelar, Saltar, Cerrar...).
class BotonTexto extends StatelessWidget {
  const BotonTexto({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        icon: Icon(icon, size: 16, color: Paleta.muted),
        label: Text(label, style: const TextStyle(color: Paleta.muted, fontSize: 13, fontWeight: FontWeight.w600)),
        onPressed: onPressed,
      ),
    );
  }
}

/// Título chico de sección en mayúsculas ("APRENDE", "AJUSTES").
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(color: Paleta.muted, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
      ),
    );
  }
}

/// Etiqueta redondeada ("Señales de tránsito", "Correcta"...).
class Pill extends StatelessWidget {
  const Pill({super.key, this.icon, required this.label, required this.color, required this.bg});

  final IconData? icon;
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, color: color, size: 14), const SizedBox(width: 5)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de progreso "n/total" (mismo diseño que IndicadorDeProgreso de la
/// app argentina, pero sin el 20 fijo).
class IndicadorDeProgreso extends StatelessWidget {
  const IndicadorDeProgreso({super.key, required this.indice, required this.total});

  /// Índice actual, desde 0.
  final int indice;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            '${indice + 1}/$total',
            style: const TextStyle(color: Paleta.primary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              color: Paleta.accent,
              backgroundColor: Paleta.accent.withValues(alpha: 0.18),
              minHeight: 10,
              value: total == 0 ? 0 : (indice + 1) / total,
            ),
          ),
        ),
      ],
    );
  }
}

/// Opción de respuesta con su letra (A, B, C). [estado] define el color:
/// normal, correcta (verde) o elegida incorrecta (rojo).
enum EstadoOpcion { normal, correcta, incorrecta }

class OpcionRespuesta extends StatelessWidget {
  const OpcionRespuesta({
    super.key,
    required this.indice,
    required this.texto,
    this.estado = EstadoOpcion.normal,
    this.onTap,
  });

  final int indice;
  final String texto;
  final EstadoOpcion estado;
  final VoidCallback? onTap;

  static const _letras = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    Color bg = Paleta.opcionBg, borde = Paleta.accent.withValues(alpha: 0.18), txt = Paleta.primary;
    Color badgeBg = Paleta.accent.withValues(alpha: 0.12), badge = Paleta.accent;
    IconData? icono;
    if (estado == EstadoOpcion.correcta) {
      bg = const Color(0xFFE8F5E9);
      borde = Paleta.success.withValues(alpha: 0.45);
      txt = const Color(0xFF1B5E20);
      badgeBg = Paleta.success.withValues(alpha: 0.18);
      badge = Paleta.success;
      icono = Icons.check_circle_rounded;
    } else if (estado == EstadoOpcion.incorrecta) {
      bg = const Color(0xFFFFEBEE);
      borde = Paleta.danger.withValues(alpha: 0.45);
      txt = const Color(0xFFB71C1C);
      badgeBg = Paleta.danger.withValues(alpha: 0.18);
      badge = Paleta.danger;
      icono = Icons.cancel_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borde, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  indice < _letras.length ? _letras[indice] : '',
                  style: TextStyle(color: badge, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(texto, style: TextStyle(color: txt, fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.3)),
              ),
              if (icono != null) ...[const SizedBox(width: 8), Icon(icono, color: badge, size: 20)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagen de una señal por su código MUTCD (assets/seniales/R1-1.png).
/// Si la imagen no existe, no muestra nada.
class SenialImagen extends StatelessWidget {
  const SenialImagen(this.codigo, {super.key, this.tamanio = 140});

  final String codigo;
  final double tamanio;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/seniales/$codigo.png',
        width: tamanio,
        height: tamanio,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}

/// [10/11/2026] Botón EN/ES para cambiar el idioma (antes privado en examen_page). — Claude (IA)
class BotonIdioma extends StatelessWidget {
  const BotonIdioma({super.key, required this.idioma, required this.onTap});
  final Idioma idioma;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Paleta.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            idioma == Idioma.es ? 'EN' : 'ES',
            style: const TextStyle(color: Paleta.accent, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}
