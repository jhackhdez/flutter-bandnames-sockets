class Band {
  String id;
  String name;
  int votes;

  Band({required this.id, required this.name, required this.votes});

  // Se trabaja acá con mapas porque la respuesta
  // de los sockets serán precisamente mapas

  // factory constructor: regresa nueva instancia de la clase
  // definiendolo como 'fromMap' recibe obj del tipo definido
  // y retorna nueva instancia de la clase
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
      id: obj.containsKey('id') ? obj['id'] : 'no-id',
      name: obj.containsKey('name') ? obj['name'] : 'no-name',
      votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes');
}
