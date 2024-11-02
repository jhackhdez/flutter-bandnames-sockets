import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    // Se crea instancia de Provider definido en el MultiProvider
    // del main.dart
    final socketService = Provider.of<SocketService>(context, listen: false);

    // para escuchar el evento 'active-bands' desde el server
    socketService.socket.on(
        'active-bands',
        (payload) => {
              // Se castea 'payload' como una lista para poder acceder al método 'map'
              bands =
                  (payload as List).map((band) => Band.fromMap(band)).toList(),
              // se establece 'setState() para que redibuje widget completo cuando se reciva un 'active-bands'
              setState(() {}),
            });

    super.initState();
  }

// para dejar de escuchar el evento o destruir la pantalla
  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTitle(bands[i])),
      floatingActionButton: FloatingActionButton(
          elevation: 1, onPressed: addNewBand, child: const Icon(Icons.add)),
    );
  }

  Widget _bandTitle(Band band) {
    // Dismissible: Esto permite la acción de eliminar la banda moviendo a la derecha
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      // Para reaccionar cuando culmine la animación de la eliminación
      onDismissed: (direction) {
        print('direction: $direction');
        print('direction: ${band.id}');
        // TODO: Llamar el borrado en el server
      },
      background: Container(
          padding: const EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white)),
          )),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          // Obtener 2 primeros caracteres del nombre de la banda
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    // Condición para mostrar dialogo en Android o iOS
    // Se comenta porque lanza exception en web
    // if (Platform.isIOS) {
    // Código para que se muestre diálogo con diseño iOS
    return showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
    // }
    // Para un 'StatefulWidget' el context está de manera global. Es accesible desde todo el código
    // Código para que se muestre diálogo con diseño android
    /*return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New band name:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Add'))
          ],
        );
      },
    );*/
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    // Para cerra el dialogo
    Navigator.pop(context);
  }
}
