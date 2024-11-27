import 'dart:async'; // Necesario para el uso de Timer
import 'package:fichajes/view/single_task.dart';
import 'package:flutter/material.dart';
import '../model/event.dart';
import '../model/task.dart';
import '../utilities.dart';

class Home extends StatefulWidget {
  final Task _task = Task();
  final Event _event = Event();
  late Future<List<Task>> taskList = _task.getProjectTaskList();

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  late Event _lastEvent=Event(); // Usamos un State para el último evento
  bool _isLoading = true; // Variable para controlar el estado de carga

  @override
  void initState() {
    super.initState();
    // Inicia el Timer para actualizar el evento cada 10 segundos (10,000 milisegundos)
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      _fetchLastEvent(); // Llama a la función para obtener el último evento
    });

    // Carga inicial del último evento
    _fetchLastEvent();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancela el Timer cuando el widget se destruye
    super.dispose();
  }

  // Método para obtener el último evento y actualizar el estado
  void _fetchLastEvent() async {
    try {
      Event event = await widget._event.getLastEvent();
      if (mounted) {
        setState(() {
          _lastEvent = event;
          _isLoading = false; // Deja de mostrar el cargando
        });
      }
    } catch (e) {
      // Manejo de error si falla al obtener el evento
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarSimple("HOME"),
        drawer: drawer(context),
        key: _scaffoldkey,
        body: FutureBuilder(
          future: widget.taskList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Container(
                color: Colors.white, // Fondo blanco para el ListView
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    _taskListSection(snapshot.data),
                    // Aquí ya no estamos dependiendo de _lastEvent en el FutureBuilder
                  ],
                ),
              );
            }
          },
        ));
  }

  Widget _taskListSection(data) {
    return Column(
      children: _taskList(data),
    );
  }

  List<Widget> _taskList(snapshot) {
    List<Task> taskList = snapshot;
    List<Widget> list = <Widget>[];
    IconData status;

    for (Task task in taskList) {
      if ((_lastEvent.eventType == "2" || _lastEvent.eventType == "1") &&
          task.id.toString() == _lastEvent.taskId) {
        status = Icons.lock_clock;
      } else {
        status = Icons.note_add;
      }

      list.add(GestureDetector(
          onTap: () {
            if ((_lastEvent.eventType == "2" || _lastEvent.eventType == "1") &&
                task.id.toString() != _lastEvent.taskId) {
              showAlert(
                  context,
                  const Text('AVISO'),
                  const Text(
                      'Ya tienes una tarea iniciada, finaliza la tarea en proceso antes de iniciar una nueva'));
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaskEvent(task, _lastEvent)),
              );
            }
          },
          child: Card(
            shadowColor: Colors.black,
            color: Colors.white,
            elevation: 20.0,
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(status),
                  title: Text(
                    task.projectTitle,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    task.companyName,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Container(
                        width: 350,
                        child: Text(
                          task.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          )));

      list.add(const SizedBox(
        height: 5,
      ));
    }

    return list;
  }
}
