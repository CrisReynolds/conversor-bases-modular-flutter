// ===========================================================================
//  tema/tema_app.dart
// ---------------------------------------------------------------------------
//  Los colores institucionales y el tema, en un solo archivo.
//
//  En el monolito había 23 apariciones de `Color(0xFF…)` repartidas por los
//  widgets. Cambiar el verde de los bits encendidos obligaba a buscarlo en
//  cuatro lugares distintos. Acá se cambia una línea.
// ===========================================================================

import 'package:flutter/material.dart';

/// Paleta con nombres que dicen PARA QUÉ sirve cada color, no qué color es.
/// Si mañana el "encendido" pasa a ser azul, el nombre sigue teniendo
/// sentido; `verde` no lo tendría.
class Paleta {
  const Paleta._();

  // Institucionales
  static const Color granate = Color(0xFFA6161C);
  static const Color granateOscuro = Color(0xFF6E0F13);
  static const Color dorado = Color(0xFFE3A21A);

  // Semánticos
  static const Color bitEncendido = Color(0xFF0E7C66);
  static const Color bitApagado = Color(0xFFF2F3F5);
  static const Color bordeApagado = Color(0xFFDCDFE4);

  static const Color sinSigno = Color(0xFF0E7C66);
  static const Color conSignoPositivo = Color(0xFF02569B);
  static const Color conSignoNegativo = Color(0xFFA6161C);

  static const Color operandoA = Color(0xFF02569B);
  static const Color operandoB = Color(0xFF0E7C66);

  static const Color baseActiva = Color(0xFFE4EFF7);
  static const Color notaFondo = Color(0xFFFBEFD3);

  static const Color consolaFondo = Color(0xFF1B2029);
  static const Color consolaTexto = Color(0xFFE8EAED);
  static const Color consolaResto = Color(0xFFAFD1A0);

  static const Color webFondo = Color(0xFFE4EFF7);
  static const Color webBorde = Color(0xFF02569B);
  static const Color movilFondo = Color(0xFFE9F5F1);
  static const Color movilBorde = Color(0xFF0E7C66);
}

/// Estilos de texto reutilizados. El monospace aparecía 14 veces en el
/// monolito; acá una vez.
class Tipografia {
  const Tipografia._();

  static const TextStyle mono = TextStyle(fontFamily: 'monospace');

  static const TextStyle monoGrande = TextStyle(
    fontFamily: 'monospace',
    fontSize: 17,
    letterSpacing: 0.5,
  );

  static const TextStyle monoChico = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
  );

  static const TextStyle titulo = TextStyle(fontWeight: FontWeight.bold);

  static const TextStyle ayuda = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
}

class TemaApp {
  const TemaApp._();

  static ThemeData claro() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Paleta.granate,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: Paleta.granate,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
