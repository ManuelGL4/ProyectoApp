import 'package:fichajes/view/libre.dart';
import 'package:flutter/material.dart';
import 'model/user.dart';
import 'view/list.dart';

AppBar appBarTop(context, key) {
  return AppBar(
      toolbarHeight: 100,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => key.currentState.openDrawer(),
            icon: Icon(Icons.list_rounded),
            color: Colors.purple,
            iconSize: 50,
          ),
        ],
      ));
}

AppBar appBarTopHome(context, key) {
  return AppBar(
      toolbarHeight: 100,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => key.currentState.openDrawer(),
            icon: Icon(Icons.list_rounded),
            color: Colors.purple,
            iconSize: 55,
          ),
        ],
      ));
}

Widget drawer(context) {
  return Drawer(
    backgroundColor: Colors.white,
    child: Center(
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        alignment: WrapAlignment.center,
        children: _drawerElements(context),
      ),
    ),
  );
}

List<Widget> _drawerElements(context) {
  return [
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        separator(),
        GestureDetector(
          onTap: () {
            // Acción para Fichajes
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
            child: Row(
              children: const [
                Icon(
                  Icons.access_time, // Puedes cambiar este icono si lo prefieres
                  size: 25.0,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'FICHAJES',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        // Aquí agregamos la opción de "Edición/Listado de registros" como un elemento simple
        GestureDetector(
  onTap: () {
    // Redirige a la pantalla de Listado/Edición de registros
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventListScreen()), // Redirige a EventListScreen
    );
  },
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
    child: Row(
      children: const [
        Icon(
          Icons.list,
          size: 25.0,
          color: Colors.blue,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Listado/Edición de registros',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    ),
  ),
),

        separator(),
        GestureDetector(
          onTap: () {
            // Acción para Nóminas/Documentos
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
            child: Row(
              children: const [
                Icon(
                  Icons.description,
                  size: 25.0,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'NÓMINAS/DOCUMENTOS',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        separator(),
GestureDetector(
  onTap: () {
    // Redirige a la pantalla de Días Libres
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DiasPermisoList()),
    );
  },
  child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
    child: Row(
      children: const [
        Icon(
          Icons.calendar_today,
          size: 25.0,
          color: Colors.blue,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'DÍAS LIBRES',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ],
    ),
  ),
),

        separator(),
        GestureDetector(
          onTap: () {
            User _user = User();
            _user.logout();
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/Login', (Route<dynamic> route) => false);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
            child: Row(
              children: const [
                Icon(
                  Icons.cancel,
                  size: 25.0,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'CERRAR SESIÓN',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
        ),
        separator(),
      ],
    )
  ];
}

Widget separator() {
  return Container(
    color: Colors.blue,
    height: 2,
  );
}

AppBar appBarSimple(titulo) {
  return AppBar(
    iconTheme: const IconThemeData(
      color: Colors.blue, //change your color here
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          titulo,
          style: const TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    ),
    backgroundColor: Colors.white,
  );
}

AppBar appBarSimpleBack(context, titulo) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.blue),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: Text(
            titulo,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
            softWrap: true,
          ),
        ),
      ],
    ),
    backgroundColor: Colors.white,
  );
}

showAlert(context, titulo, texto) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: titulo,
      content: texto,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Aceptar'),
        )
      ],
    ),
  );
}

cutText(String texto, int max) {
  if (texto.length > max) {
    return texto.substring(0, max) + '...';
  } else {
    return texto;
  }
}
