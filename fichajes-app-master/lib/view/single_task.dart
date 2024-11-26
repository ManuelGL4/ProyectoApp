import 'package:geolocator/geolocator.dart';
import 'package:fichajes/model/event.dart';
import 'package:flutter/material.dart';
import '../model/task.dart';
import '../utilities.dart';

class TaskEvent extends StatefulWidget {
  //const TaskEvent({Key? key}) : super(key: key);

  Task _task = Task();
  Event _lastEvent = Event();

  TaskEvent(this._task, this._lastEvent, {Key? key}) : super(key: key);

  @override
  State<TaskEvent> createState() => _TaskEventState();
}

class _TaskEventState extends State<TaskEvent> {
  bool isLoading = false;

  final noteField = TextEditingController();

  String note = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarSimpleBack(context, widget._task.description),
      body: Container(
        color: Colors.white, // Fondo blanco
        child: !isLoading
            ? Center(
                child: _signForm(context, noteField),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }

  Widget _signForm(context, noteField) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: TextField(
              controller: noteField,
              autofocus: false,
              maxLines: 4,
              style: const TextStyle(fontSize: 18.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                label: const Text('Nota'),
                contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 1.0),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        _selectButtonType(widget._lastEvent)
      ],
    );
  }

  Widget _selectButtonType(Event lastEvent) {
    if (lastEvent.eventType == "3" || lastEvent.eventType == "") {
      return _buttonStart();
    }

    return _buttonFinish();
  }

  Widget _buttonStart() {
    return Container(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                const WidgetStatePropertyAll<Color>(Color.fromARGB(255, 6, 90, 158)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                    side: const BorderSide(color: Colors.black)))),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Seleccione una opcion'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('¿Esta seguro de que desea iniciar el fichaje?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Si'),
                    onPressed: () async {
                      _startTask(true);
                    },
                  ),
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Iniciar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTask(bool share) async {
    Event newEvent = Event();

    note = noteField.text;

    newEvent.note = note;
    newEvent.projectId = widget._task.projectId.toString();
    newEvent.taskId = widget._task.id.toString();
    newEvent.thirdPartyId = widget._task.companyId.toString();
    newEvent.eventType='2';

    Navigator.pop(context);
    setState(() {
      isLoading = true;
    });

    if (share) {
      try {
        Position position = await _determinePosition();

        newEvent.eventLocationRef = position.toString();
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        return showAlert(
            context,
            const Text('AVISO'),
            const Text(
                'Si desea realizar el fichaje de horas debe aceptar el uso de los servicios GPS'));
      }
    } else {
      newEvent.eventLocationRef = "Ubicación no cedida";
    }

    Event responseEvent = await newEvent.startSignTask();
    
    setState(() {
      isLoading = false;
    });




    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exito'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('El fichaje se ha iniciado con exito'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/Home', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buttonFinish() {
    return Container(
      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22.0),
                    side: const BorderSide(color: Colors.black)))),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Seleccione una opcion'),
                content: const SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('¿Esta seguro de que desea detener el fichaje?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Si'),
                    onPressed: () async {
                      _stopTask(true);
                    },
                  ),
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Finalizar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _stopTask(bool share) async {
    Event newEvent = Event();

    note = noteField.text;

    newEvent.note = note;
    newEvent.projectId = widget._task.projectId.toString();
    newEvent.taskId = widget._task.id.toString();
    newEvent.thirdPartyId = widget._task.companyId.toString();
    newEvent.eventType='2';



    Navigator.pop(context);
    setState(() {
      isLoading = true;
    });

    if (share) {
      try {
        Position position = await _determinePosition();

        newEvent.eventLocationRef = position.toString();
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        return showAlert(
            context,
            const Text('AVISO'),
            const Text(
                'Si desea realizar el fichaje de horas debe aceptar el uso de los servicios GPS'));
      }
    } else {
      newEvent.eventLocationRef = "Ubicación no cedida";
    }

    newEvent = await newEvent.stopSignTask();

    setState(() {
      isLoading = false;
    });

    // if (newEvent.eventType != "3") {
    //   return showAlert(context, const Text('Error'),
    //       const Text('No se ha podido finalizar el fichaje correctamente'));
    // }

    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exito'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('El fichaje se ha finalizado con exito'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/Home', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
