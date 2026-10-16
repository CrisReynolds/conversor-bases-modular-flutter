// ===========================================================================
//  pantallas/pantalla_principal.dart
// ---------------------------------------------------------------------------
//  El armazón: crea el controlador, lo publica en el árbol y arma las tres
//  pestañas. Y nada más: no hay una sola línea de lógica del conversor acá.
//
//  DETALLE QUE VALE COMPARAR CON EL PROYECTO DEL SUDOKU
//
//  Allí la pantalla envolvía todo en un `ListenableBuilder`. Acá no hace
//  falta, y la razón es instructiva: el AppBar y las pestañas de este
//  proyecto son fijos — no muestran nada que cambie. Los únicos widgets que
//  dependen del estado son las tres pestañas, y cada una se suscribe por su
//  cuenta al llamar a `ProveedorConversor.de(context)`.
//
//  InheritedNotifier ya reconstruye a sus dependientes cuando el notifier
//  avisa. El `ListenableBuilder` se usa cuando un widget que NO puede
//  suscribirse por contexto (porque está por encima del proveedor) necesita
//  reaccionar. En el Sudoku ese era el AppBar, que mostraba el nivel y
//  cambiaba el icono de pausa.
// ===========================================================================

import 'package:flutter/material.dart';

import '../estado/controlador_conversor.dart';
import '../estado/proveedor_conversor.dart';

import 'pestana_bits.dart';
import 'pestana_conversor.dart';
import 'pestana_operaciones.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late final ControladorConversor _controlador;

  @override
  void initState() {
    super.initState();
    // En initState, NO en build: build se ejecuta muchas veces y crearíamos
    // un controlador nuevo en cada una, perdiendo lo que el usuario escribió.
    _controlador = ControladorConversor(valorInicial: 2026);
  }

  @override
  void dispose() {
    // Esto desecha también el TextEditingController que vive adentro.
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProveedorConversor(
      controlador: _controlador,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Conversor de bases · PDM-307'),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Color(0xFFE3A21A),
              tabs: <Widget>[
                Tab(icon: Icon(Icons.swap_horiz), text: 'Conversor'),
                Tab(icon: Icon(Icons.grid_on), text: 'Bits'),
                Tab(icon: Icon(Icons.calculate_outlined), text: 'Operaciones'),
              ],
            ),
          ),
          body: Center(
            // Tope de ancho: en una ventana de navegador maximizada, una
            // columna de 760 px se lee mucho mejor que una de 1900. En un
            // celular la restricción no hace nada, porque la pantalla ya
            // es más angosta. Un solo valor sirve para las dos plataformas.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: const TabBarView(
                children: <Widget>[
                  PestanaConversor(),
                  PestanaBits(),
                  PestanaOperaciones(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
