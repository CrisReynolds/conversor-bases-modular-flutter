// ===========================================================================
//  modelos/paso_division.dart
// ---------------------------------------------------------------------------
//  Un renglón del algoritmo de divisiones sucesivas, el que se enseña en el
//  pizarrón:
//
//      13 ÷ 2 = 6   resto 1
//       6 ÷ 2 = 3   resto 0
//       3 ÷ 2 = 1   resto 1
//       1 ÷ 2 = 0   resto 1     <- los restos se leen de abajo hacia arriba
//
//  Es inmutable: un paso ya calculado no cambia nunca. Al contrario de la
//  `Celda` del Sudoku, que sí era mutable porque el jugador la editaba.
//  La inmutabilidad no es una regla universal: se elige según el uso.
// ===========================================================================

class PasoDivision {
  const PasoDivision({
    required this.dividendo,
    required this.cociente,
    required this.resto,
  });

  final int dividendo;
  final int cociente;
  final int resto;

  @override
  String toString() => '$dividendo ÷ ? = $cociente resto $resto';
}
