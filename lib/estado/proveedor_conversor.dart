// ===========================================================================
//  estado/proveedor_conversor.dart
// ---------------------------------------------------------------------------
//  Pone el ControladorConversor al alcance de todo el árbol de widgets.
//  Es el mismo patrón que `ProveedorJuego` del proyecto del Sudoku: una vez
//  entendido, se repite igual en cualquier app.
//
//  InheritedNotifier = InheritedWidget (se encuentra por contexto)
//                    + suscripción al Listenable (reconstruye al notificar)
// ===========================================================================

import 'package:flutter/widgets.dart';

import 'controlador_conversor.dart';

class ProveedorConversor extends InheritedNotifier<ControladorConversor> {
  const ProveedorConversor({
    super.key,
    required ControladorConversor controlador,
    required super.child,
  }) : super(notifier: controlador);

  /// Con suscripción: el widget se reconstruye en cada cambio.
  /// Para widgets que MUESTRAN estado.
  static ControladorConversor de(BuildContext context) {
    final ProveedorConversor? p =
        context.dependOnInheritedWidgetOfExactType<ProveedorConversor>();
    assert(p != null, 'No hay ProveedorConversor en el árbol de widgets.');
    return p!.notifier!;
  }

  /// Sin suscripción: para callbacks que solo ORDENAN cosas.
  /// Un botón que llama a `complementar()` no necesita reconstruirse.
  static ControladorConversor leer(BuildContext context) {
    final ProveedorConversor? p =
        context.getInheritedWidgetOfExactType<ProveedorConversor>();
    assert(p != null, 'No hay ProveedorConversor en el árbol de widgets.');
    return p!.notifier!;
  }
}
