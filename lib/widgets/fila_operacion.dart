// ===========================================================================
//  widgets/fila_operacion.dart
// ---------------------------------------------------------------------------
//  La tarjeta de una operación lógica: símbolo, resultado en binario,
//  en decimal, en hexadecimal, y para qué sirve.
//
//  Compará la firma de este widget con el monolito:
//
//      // antes:  op[0] as String, op[1] as int, op[2] as String
//      // ahora:  required this.operacion, required this.resultado
//
//  Recibe la operación entera, así que la explicación y el símbolo salen
//  del enum y no hay forma de que queden despareados del resultado.
// ===========================================================================

import 'package:flutter/material.dart';

import '../logica/conversor.dart';
import '../logica/operacion_logica.dart';
import '../modelos/base_numerica.dart';

class FilaOperacion extends StatelessWidget {
  const FilaOperacion({
    super.key,
    required this.operacion,
    required this.resultado,
    required this.anchoBits,
  });

  final OperacionLogica operacion;
  final int resultado;
  final int anchoBits;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 78,
                  child: Text(
                    operacion.simbolo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    Conversor.binarioLegible(resultado, anchoBits),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '$resultado',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '0x${Conversor.enTexto(resultado, BaseNumerica.hexadecimal).padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              operacion.explicacion,
              style: const TextStyle(fontSize: 11.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
