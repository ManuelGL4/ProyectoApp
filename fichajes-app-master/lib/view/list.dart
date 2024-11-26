import 'package:flutter/material.dart';
import '../model/event.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> _eventsFuture;
  List<Event> _events = [];
  List<Event> _displayedEvents = [];
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  TextEditingController _hourController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    Event event = Event();
    _eventsFuture = event.getAll();
    _eventsFuture.then((events) {
      setState(() {
        _events = events;
        _updateDisplayedEvents();
      });
    }).catchError((error) {
      print("Error fetching events: $error");
    });
  }

  void _updateDisplayedEvents() {
    int start = (_currentPage - 1) * _itemsPerPage;
    int end = (_currentPage * _itemsPerPage).clamp(0, _events.length);
    _displayedEvents = _events.sublist(start, end);
  }

  void _goToNextPage() {
    if (_currentPage * _itemsPerPage < _events.length) {
      setState(() {
        _currentPage++;
        _updateDisplayedEvents();
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _updateDisplayedEvents();
      });
    }
  }

  void _deleteEvent(String tokenR) {
    Event event = Event();
    print("Eliminando evento con token: $tokenR");
    event.delete(tokenR).then((events) {
      if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Evento eliminado correctamente."),
            backgroundColor: Colors.green,
          ),
        );
        _fetchEvents(); // Recargar la lista de eventos después de la eliminación
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar el evento."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((error) {
      print("Error eliminando evento: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al eliminar el evento."),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _showEditEventModal(Event event) {
    // Verificar que el evento tiene un id antes de proceder
    if (event.id == null) {
      print("Error: el evento no tiene un ID válido");
      return;
    }

    // Configurar los controladores con los valores actuales
    _hourController.text = event.dateTimeEvent;  // Asegúrate de que `event.dateTimeEvent` sea un String o DateTime adecuado
    _noteController.text = event.note;
    _idController.text = event.id!; // Asignar el id al controlador

    // Mostrar el modal para editar el evento
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Evento"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("ID del Evento"),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(hintText: "ID del evento"),
                  readOnly: true, // El campo ID no se puede editar
                ),
                SizedBox(height: 8),
                Text("Fecha del Evento"),
                // Selector de fecha
                TextField(
                  controller: _hourController,
                  decoration: InputDecoration(hintText: "Ingrese la fecha y hora"),
                  readOnly: true,
                  onTap: () async {
                    // Mostrar el selector de fecha
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      // Mostrar el selector de hora
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      );
                      if (selectedTime != null) {
                        // Combinar la fecha y la hora seleccionadas
                        final selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        // Convertir la fecha combinada a formato ISO 8601
                        _hourController.text = selectedDateTime.toIso8601String();
                      }
                    }
                  },
                ),
                SizedBox(height: 8),
                Text("Nota del Evento"),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(hintText: "Ingrese la nota"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
            ),
            TextButton(
              child: Text("Guardar"),
              onPressed: () {
                // Guardar los cambios
                String updatedHour = _hourController.text;
                String updatedNote = _noteController.text;

                // Llamar al controlador para actualizar el evento
                event.dateTimeEvent = updatedHour;
                event.note = updatedNote;
                print(updatedHour);
                print(updatedNote);
                print(event.id);

                if (event.id == null) {
                  print("Error: El evento no tiene un id");
                  return;
                }

                // Llamar al método de actualización en el controlador de eventos
                event.update(event.id!, updatedHour, updatedNote).then((updatedEvent) {
                  Navigator.of(context).pop(); // Cerrar el modal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Evento actualizado."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _fetchEvents(); // Recargar la lista de eventos después de la actualización
                }).catchError((error) {
                  print("Error actualizando el evento: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error al actualizar el evento."),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar el diálogo de confirmación
  void _showDeleteConfirmationDialog(String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Eliminación"),
          content: Text("¿Estás seguro de que quieres eliminar este evento?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
            ),
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                _deleteEvent(token); // Llamar al método para eliminar el evento
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Eventos"),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay eventos disponibles."));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _displayedEvents.length,
                    itemBuilder: (context, index) {
                      var event = _displayedEvents[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text("Usuario: ${event.userRef}"),
                          subtitle: Text(
                            "Tipo: ${event.eventType == '2' ? 'Entrada' : 'Salida'}\n"
                            "Fecha: ${event.dateTimeEvent}\n"
                            "Tarea: ${event.taskRef}\n"
                            "Nota: ${event.note}\n"
                            "ID: ${event.id}\n",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditEventModal(event); // Mostrar modal de edición
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(event.token);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _goToPreviousPage,
                    ),
                    Text("Página $_currentPage"),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _goToNextPage,
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
