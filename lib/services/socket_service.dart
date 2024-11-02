import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// enum para manejar estados del Server
enum ServerStatus { Online, Offline, Connecting }

// "ChangeNotifier" ayuda a comunicar a provider cuando refrescar UI o
// interfaz de usuario o redibujar algún widget si hay algún cambio.

class SocketService with ChangeNotifier {
  // El guión delante de la variable la define como propiedad privada
  ServerStatus _serverStatus = ServerStatus.Connecting;

  late IO.Socket _socket;
  Function get emit => _socket.emit;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket = IO.io(
        'http://localhost:3000/',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // enable auto-connection.
            .build());

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      // Después de cambiar el "_serverStatus" se llama al
      // notifyListeners y este redibuja todo el que este escuchando
      // ese cambio ya que "ChangeNotifier" es un estado global
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }
}
