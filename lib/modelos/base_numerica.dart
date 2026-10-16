// ===========================================================================
//  modelos/base_numerica.dart
//  PDM-307 · Programación para Dispositivos Móviles II
//  INTFOSIN – Khana Marka
// ---------------------------------------------------------------------------
//  Las cuatro bases que maneja la aplicación, como enum mejorado.
//  Sin esto habría un `switch (base)` repetido para el radix, otro para el
//  nombre, otro para el prefijo y otro para los dígitos permitidos.
// ===========================================================================

enum BaseNumerica {
  binario(2, 'Binario', 'BIN', '0b'),
  octal(8, 'Octal', 'OCT', '0o'),
  decimal(10, 'Decimal', 'DEC', ''),
  hexadecimal(16, 'Hexadecimal', 'HEX', '0x');

  const BaseNumerica(this.radix, this.nombre, this.sigla, this.prefijo);

  /// La base propiamente dicha: 2, 8, 10 o 16.
  final int radix;

  /// Nombre completo, para mostrar.
  final String nombre;

  /// Abreviatura de tres letras.
  final String sigla;

  /// Prefijo convencional en código fuente: 0b1010, 0o17, 0xFF.
  final String prefijo;

  /// Dígitos válidos en esta base.
  ///   binario      -> "01"
  ///   octal        -> "01234567"
  ///   decimal      -> "0123456789"
  ///   hexadecimal  -> "0123456789ABCDEF"
  ///
  /// Una sola línea reemplaza cuatro listas escritas a mano, y es imposible
  /// que queden desincronizadas con el radix.
  String get alfabeto => '0123456789ABCDEF'.substring(0, radix);

  /// ¿Este carácter es un dígito legal en esta base?
  bool aceptaDigito(String caracter) =>
      caracter.length == 1 && alfabeto.contains(caracter.toUpperCase());
}
