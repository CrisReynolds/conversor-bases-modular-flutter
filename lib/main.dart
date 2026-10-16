// ===========================================================================
//  main.dart
//  Conversor de bases y laboratorio de bits · versión modular
//  PDM-307 Programación para Dispositivos Móviles II
//  INTFOSIN – Khana Marka · Ing. Cristian Miguel Reynolds Muriel
//  Flutter 3.41.7 · Dart 3.11
// ---------------------------------------------------------------------------
//  LO QUE ENSEÑA LA APLICACIÓN
//    · Conversión entre binario, octal, decimal y hexadecimal.
//    · El algoritmo de divisiones sucesivas, paso a paso.
//    · Bits, complemento a dos y rangos con y sin signo.
//    · AND, OR, XOR, NOT y desplazamientos.
//    · Una diferencia real entre web y Android: el ancho del int.
//
//  LO QUE ENSEÑA EL PROYECTO
//    Cómo se organiza una app Flutter en capas. Es el mismo programa que
//    `17_conversor_bases.dart` (1035 líneas en un archivo), repartido en
//    22 archivos con una responsabilidad cada uno, más 3 de pruebas.
//
//  MAPA DEL PROYECTO
//
//    lib/
//     ├── main.dart ..................... arranque
//     ├── tema/tema_app.dart ............ paleta y estilos
//     ├── modelos/ ...................... datos puros (sin Flutter)
//     │    ├── base_numerica.dart ....... BIN / OCT / DEC / HEX
//     │    ├── ancho_palabra.dart ....... 8 / 16 / 32 bits
//     │    └── paso_division.dart ....... un renglón de la división
//     ├── logica/ ....................... algoritmos (sin Flutter)
//     │    ├── conversor.dart ........... texto <-> número, formato
//     │    ├── bits.dart ................ ancho de palabra, bits, rangos
//     │    └── operacion_logica.dart .... AND / OR / XOR / NOT / << / >>
//     ├── estado/ ....................... estado de la sesión
//     │    ├── controlador_conversor.dart
//     │    └── proveedor_conversor.dart
//     ├── pantallas/ .................... el armazón y las tres pestañas
//     │    ├── pantalla_principal.dart
//     │    ├── pestana_conversor.dart
//     │    ├── pestana_bits.dart
//     │    └── pestana_operaciones.dart
//     └── widgets/ ...................... piezas reutilizables
//          ├── tarjeta_resultado.dart
//          ├── tabla_pasos.dart
//          ├── rejilla_bits.dart
//          ├── editor_byte.dart
//          ├── fila_operacion.dart
//          ├── caja_valor.dart
//          ├── nota_didactica.dart
//          └── nota_plataforma.dart
//
//  LA REGLA QUE ORDENA TODO
//    Las dependencias apuntan hacia abajo en esa lista y nunca hacia
//    arriba. `logica/` puede importar `modelos/`; jamás `widgets/`.
//    Verificable en una línea:
//        grep -r "package:flutter" lib/logica lib/modelos    -> vacío
//
//  Corre igual en Android, iOS, web, Windows, macOS y Linux: no hay un
//  solo `dart:io` ni un solo plugin en todo el proyecto.
// ===========================================================================

import 'package:flutter/material.dart';

import 'pantallas/pantalla_principal.dart';
import 'tema/tema_app.dart';

void main() {
  runApp(const AppConversor());
}

class AppConversor extends StatelessWidget {
  const AppConversor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDM-307 · Conversor de bases',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro(),
      home: const PantallaPrincipal(),
    );
  }
}
