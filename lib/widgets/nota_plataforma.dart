// ===========================================================================
//  widgets/nota_plataforma.dart
// ---------------------------------------------------------------------------
//  El único widget de todo el proyecto que pregunta en qué plataforma corre.
//  Y lo hace para EXPLICAR la diferencia al estudiante, no para cambiar el
//  comportamiento de la app.
//
//  `kIsWeb` es una **constante de compilación**. El compilador conoce su
//  valor antes de ejecutar nada, así que en la compilación para Android la
//  rama de web desaparece por completo del binario, y al revés. No es un
//  `if` que se evalúe en ejecución.
//
//  Comparar con `defaultTargetPlatform`, que es la trampa clásica: en web
//  devuelve el sistema operativo del ANFITRIÓN (android, iOS, macOS…),
//  nunca "web". Para saber si estamos en navegador, `kIsWeb` y nada más.
// ===========================================================================

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

class NotaPlataforma extends StatelessWidget {
  const NotaPlataforma({super.key});

  @override
  Widget build(BuildContext context) {
    final Color fondo = kIsWeb ? Paleta.webFondo : Paleta.movilFondo;
    final Color borde = kIsWeb ? Paleta.webBorde : Paleta.movilBorde;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondo,
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                kIsWeb ? Icons.language : Icons.phone_android,
                size: 18,
                color: borde,
              ),
              const SizedBox(width: 8),
              Text(
                kIsWeb ? 'Corriendo en el navegador' : 'Corriendo en Android',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            kIsWeb
                ? 'Aquí un int de Dart se apoya en el tipo numérico de '
                    'JavaScript, y los operadores bit a bit truncan a 32 '
                    'bits. Por eso toda la maquinaria de ancho de palabra '
                    'de lib/logica/bits.dart está escrita con aritmética '
                    '(multiplicar, módulo, restar) y no con << ni ~: así el '
                    'resultado es idéntico al de Android por construcción.'
                : 'Aquí un int de Dart es de 64 bits con signo, así que se '
                    'podría trabajar con palabras más anchas y con los '
                    'operadores bit a bit sin cuidado. La app se limita a 32 '
                    'bits y usa aritmética en lib/logica/bits.dart para que '
                    'el resultado coincida exactamente con la versión web.',
            style: TextStyle(fontSize: 11.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}
