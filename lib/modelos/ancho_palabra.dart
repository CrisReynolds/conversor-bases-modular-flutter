// ===========================================================================
//  modelos/ancho_palabra.dart
// ---------------------------------------------------------------------------
//  El ancho de palabra con el que se interpreta el número.
//
//  En el monolito esto era una lista suelta: `[8, 16, 32].map(...)`. Un
//  `int` cualquiera podía llegar a donde se esperaba un ancho, y nada
//  impedía pedir 7 bits. Con un enum, el conjunto de valores posibles es
//  parte del tipo: el compilador no deja pasar otro.
// ===========================================================================

enum AnchoPalabra {
  byte(8, 'Byte'),
  mediaPalabra(16, 'Media palabra'),
  palabra(32, 'Palabra');

  const AnchoPalabra(this.bits, this.nombre);

  /// Cantidad de bits.
  final int bits;

  /// Nombre que se usa en arquitectura de computadoras.
  final String nombre;

  /// Texto para los chips de selección.
  String get etiqueta => '$bits bits';

  /// Cuántas filas de ocho bits hace falta dibujar.
  int get filasDeOcho => bits ~/ 8;
}
