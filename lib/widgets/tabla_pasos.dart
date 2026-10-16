// ===========================================================================
//  widgets/tabla_pasos.dart
// ---------------------------------------------------------------------------
//  La "consola" oscura con las divisiones sucesivas.
//
//  Diferencia con el monolito: allí este widget calculaba la lectura de los
//  restos en su propio build()
//
//      final lectura = pasos.reversed.map((p) => p.resto...).join();
//
//  Esa línea es LÓGICA, no presentación, y por estar dentro de un widget no
//  se podía probar. Ahora vive en `Conversor.leerRestos` y tiene su prueba.
//  Es el caso típico: la lógica se esconde en los widgets de a una línea.
// ===========================================================================

import 'package:flutter/material.dart';

import '../logica/conversor.dart';
import '../modelos/paso_division.dart';
import '../tema/tema_app.dart';

class TablaPasos extends StatelessWidget {
  const TablaPasos({
    super.key,
    required this.pasos,
    required this.radix,
    required this.valor,
  });

  final List<PasoDivision> pasos;
  final int radix;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final String lectura = Conversor.leerRestos(pasos, radix);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Paleta.consolaFondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // `.indexed` (Dart 3) da el índice y el elemento a la vez, sin el
          // `asMap().entries` del monolito, que era el giro que había que
          // hacer antes de que existiera.
          for (final (int i, PasoDivision p) in pasos.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${p.dividendo.toString().padLeft(10)} ÷ $radix '
                      '= ${p.cociente.toString().padLeft(10)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Paleta.consolaTexto,
                      ),
                    ),
                  ),
                  Text(
                    'resto ${p.resto}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      // El ÚLTIMO paso aporta el PRIMER dígito del
                      // resultado: se resalta en dorado para que se vea de
                      // dónde empieza la lectura.
                      color: i == pasos.length - 1
                          ? Paleta.dorado
                          : Paleta.consolaResto,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: Colors.white24, height: 18),
          Text(
            '$valor en base $radix  =  $lectura',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Paleta.dorado,
            ),
          ),
        ],
      ),
    );
  }
}
