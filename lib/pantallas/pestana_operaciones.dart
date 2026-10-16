// ===========================================================================
//  pantallas/pestana_operaciones.dart
// ---------------------------------------------------------------------------
//  Pestaña 3: dos operandos de un byte y las seis operaciones aplicadas.
//
//  Comparar este build() con el del monolito es el mejor argumento a favor
//  de modularizar. Allí había que armar la lista de listas, castear tres
//  veces por fila y construir la tarjeta a mano, todo dentro del mismo
//  método. Acá:
//
//      for (final OperacionLogica op in OperacionLogica.values)
//        FilaOperacion(operacion: op, resultado: op.aplicar(a, b, bits), …)
//
//  Dos líneas. Y agregar una operación nueva no toca este archivo: se
//  agrega el caso en el enum y aparece sola.
// ===========================================================================

import 'package:flutter/material.dart';

import '../estado/controlador_conversor.dart';
import '../estado/proveedor_conversor.dart';
import '../logica/operacion_logica.dart';
import '../tema/tema_app.dart';
import '../widgets/editor_byte.dart';
import '../widgets/fila_operacion.dart';
import '../widgets/nota_didactica.dart';

class PestanaOperaciones extends StatelessWidget {
  const PestanaOperaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final ControladorConversor c = ProveedorConversor.de(context);
    final int bits = ControladorConversor.anchoOperaciones.bits;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        EditorByte(
          etiqueta: 'A',
          valor: c.a,
          color: Paleta.operandoA,
          alConmutarBit: c.conmutarBitDeA,
        ),
        const SizedBox(height: 12),
        EditorByte(
          etiqueta: 'B',
          valor: c.b,
          color: Paleta.operandoB,
          alConmutarBit: c.conmutarBitDeB,
        ),
        const SizedBox(height: 18),

        // Todas las operaciones del enum, en el orden en que están
        // declaradas. `OperacionLogica.values` es la única fuente de verdad.
        for (final OperacionLogica op in OperacionLogica.values)
          FilaOperacion(
            operacion: op,
            resultado: op.aplicar(c.a, c.b, bits),
            anchoBits: bits,
          ),

        const SizedBox(height: 4),
        const NotaDidactica(
          titulo: 'Ejercicio',
          texto: 'Pon A = 1111 0000 y B = 0000 1111. Observa que AND da cero '
              'porque no comparten ningún 1, y que OR da 1111 1111. Luego '
              'prueba A XOR A: siempre da cero, y por eso XOR consigo mismo '
              'es la forma clásica de limpiar un registro.',
        ),
      ],
    );
  }
}
