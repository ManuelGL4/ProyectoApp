import 'package:flutter/material.dart';
import 'package:fichajes/model/dia_permiso.dart';
import 'package:fichajes/controller/dias_permiso_controller.dart';
import 'package:intl/intl.dart';
import 'package:fichajes/view/nuevo_dia.dart';

class DiasPermisoDetailScreen extends StatefulWidget {
  final DiasPermiso permiso;

  DiasPermisoDetailScreen({required this.permiso});

  @override
  _DiasPermisoDetailScreenState createState() =>
      _DiasPermisoDetailScreenState();
}

class _DiasPermisoDetailScreenState extends State<DiasPermisoDetailScreen> {
  final TextEditingController _motivosController = TextEditingController();
  final TextEditingController _dateSolicController = TextEditingController();
  final TextEditingController _dateSolicFinController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  String? _selectedUsuario;
  String? _selectedEstado;
  bool _showMotivosField = false;  // Nueva variable para controlar la visibilidad de motivos

  @override
  void initState() {
    super.initState();
    _labelController.text = widget.permiso.label ?? '';
    _motivosController.text = widget.permiso.motivos ?? '';
    _selectedUsuario = widget.permiso.fkUserSolicitado;
    _selectedEstado = widget.permiso.status;
    _dateSolicController.text = widget.permiso.dateSolic ?? '';
    _dateSolicFinController.text = widget.permiso.dateSolicFin ?? '';
    _showMotivosField = _selectedEstado == '1' || _selectedEstado == '9'; // Controlar la visibilidad al iniciar
  }
Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      initialDate = DateTime.parse(controller.text);  // Si ya tiene valor, usarlo
    }
    
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
      );
      
      if (pickedTime != null) {
        final DateTime finalDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Formatear la fecha y hora para mostrarla
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDate);
      }
    }
  }
  void _openModalEstados() async {
    String? estadoSeleccionado = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text("Pendiente"),
              onTap: () => Navigator.pop(context, "0"),
            ),
            ListTile(
              title: Text("Aprobada"),
              onTap: () => Navigator.pop(context, "1"),
            ),
            ListTile(
              title: Text("Rechazada"),
              onTap: () => Navigator.pop(context, "9"),
            ),
          ],
        );
      },
    );
    if (estadoSeleccionado != null) {
      setState(() {
        _selectedEstado = estadoSeleccionado;
        // Mostrar el campo de motivos si el estado es "Aprobada" o "Rechazada"
        _showMotivosField = estadoSeleccionado == '1' || estadoSeleccionado == '9';
      });
    }
  }

void _saveChanges() async {
    final DiasPermisoController _controller = DiasPermisoController(); // Initialize the controller

  // Actualizar los datos del permiso
  widget.permiso.label = _labelController.text;
  widget.permiso.motivos = _motivosController.text;
  widget.permiso.fkUserSolicitado = _selectedUsuario!;
  widget.permiso.status = _selectedEstado!;
  widget.permiso.dateSolic = _dateSolicController.text;
  widget.permiso.dateSolicFin = _dateSolicFinController.text;
    print('Guardando cambios con los siguientes valores:');
  print('Row ID: ${widget.permiso.rowid}');  // Imprimir el rowid
  print('Label: ${widget.permiso.label}');
  print('Motivos: ${widget.permiso.motivos}');
  print('Usuario Solicitante: ${widget.permiso.fkUserSolicitado}');
  print('Estado: ${widget.permiso.status}');
  print('Fecha Solicitud: ${widget.permiso.dateSolic}');
  print('Fecha Fin Solicitud: ${widget.permiso.dateSolicFin}');
  

  try {
    // Llamar al controlador para actualizar el permiso
    await _controller.updateDiasPermiso(widget.permiso);
    
    // Mostrar un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cambios guardados exitosamente.')),
    );

    // Regresar a la pantalla anterior
    Navigator.pop(context, widget.permiso);

  } catch (e) {
    // Manejar los errores que puedan surgir al intentar guardar los cambios
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar los cambios. Intenta nuevamente.')),
    );
  }
}


  String getEstadoTexto(String? estado) {
    switch (estado) {
      case "0":
        return "Pendiente";
      case "1":
        return "Aprobada";
      case "9":
        return "Rechazada";
      default:
        return "Seleccionar";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.permiso.isAdmin ?? false;
    print("isAdmin: $isAdmin");

      return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Permiso'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fechas solicitadas", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _dateSolicController,
              decoration: InputDecoration(
                labelText: "Desde",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                await _selectDateTime(_dateSolicController); // Llamar al nuevo selector
              },
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dateSolicFinController,
              decoration: InputDecoration(
                labelText: "Hasta",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                await _selectDateTime(_dateSolicFinController); // Llamar al nuevo selector
              },
            ),
            SizedBox(height: 16),
            Text("Descripción de la solicitud", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _labelController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Escribe la descripción",
              ),
            ),
            SizedBox(height: 16),
            if (isAdmin)
              GestureDetector(
                onTap: _openModalEstados,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Estado", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(getEstadoTexto(_selectedEstado), style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            // Mostrar el campo de motivos si el estado es "Aprobada" o "Rechazada"
            if (_showMotivosField)
              TextField(
                controller: _motivosController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Motivos",
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
      );
  }
}

class DiasPermisoList extends StatefulWidget {
  @override
  _DiasPermisoListState createState() => _DiasPermisoListState();
}

class _DiasPermisoListState extends State<DiasPermisoList> {
  int _currentPage = 1;
  bool _isLoading = false;
  List<DiasPermiso> _diasPermisoList = [];
  final DiasPermisoController _controller = DiasPermisoController();

  @override
  void initState() {
    super.initState();
    _loadPermisos();
  }

  Future<void> _loadPermisos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<DiasPermiso> permisos = await _controller.getAllDiasPermisos(page: _currentPage);
      setState(() {
        _diasPermisoList = permisos;
      });
    } catch (e) {
      print("Error al cargar los permisos: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _loadPermisos();
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
    _loadPermisos();
  }


  String _getStatusText(String status) {
    switch (status) {
      case '0':
        return 'Borrador';
      case '1':
        return 'Aprobado';
      case '9':
        return 'Rechazado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orange; 
      case '1':
        return Colors.green; 
      case '9':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  void _confirmDelete(BuildContext context, int rowid) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmar eliminación"),
        content: Text("¿Estás seguro de que deseas eliminar este permiso?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Eliminar"),
            onPressed: () async {
              Navigator.pop(context); // Cerrar el modal
              await _deletePermiso(rowid ); // Llamar al método de eliminación
            },
          ),
        ],
      );
    },
  );
}

Future<void> _deletePermiso(int rowid) async {
    try {
    setState(() {
      _isLoading = true; // Indicar que la operación está en curso
    });
    
    // Mostrar tipo de rowid
    print(rowid.runtimeType);
    print(rowid);

    // Llamar al método de eliminación
    bool success = await _controller.delete(rowid);

    if (success) {
      // Mostrar notificación de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso eliminado correctamente.')),
      );

      // Recargar la lista de permisos
      await _loadPermisos(); // Método para cargar la lista
    } else {
      // Mostrar notificación de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el permiso.')),
      );
    }
  } catch (e) {
    // Mostrar notificación de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al eliminar el permiso.')),
    );
  } finally {
    setState(() {
      _isLoading = false; // Finalizar la operación
    });
  }
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Lista de Días de Permiso'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _diasPermisoList.length,
                    itemBuilder: (context, index) {
                      DiasPermiso permiso = _diasPermisoList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text('${permiso.username} - ${permiso.label ?? ''}'),
                          subtitle: Text('Desde: ${permiso.dateSolic ?? ''} \nHasta: ${permiso.dateSolicFin ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getStatusText(permiso.status ?? '0'),
                                style: TextStyle(color: _getStatusColor(permiso.status ?? '0')),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _confirmDelete(context, int.parse(permiso.rowid)),
                              ),
                            ],
                          ),
                          onTap: () async {
                            // Navegar al detalle del permiso
                            final updatedPermiso = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiasPermisoDetailScreen(permiso: permiso),
                              ),
                            );
                            if (updatedPermiso != null) {
                              // Actualizar el permiso en la lista si se han hecho cambios
                              setState(() {
                                int index = _diasPermisoList.indexWhere((p) => p.rowid == updatedPermiso.rowid);
                                if (index != -1) {
                                  _diasPermisoList[index] = updatedPermiso;
                                }
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousPage,
              ),
              Text("Página $_currentPage"),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _nextPage,
              ),
            ],
          ),
          SizedBox(height: 16),  // Espacio entre la lista y el botón
          ElevatedButton(
            onPressed: () async {
                // Navegar a la pantalla para solicitar un nuevo permiso
                final nuevoDiaCreado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolicitarNuevoDiaScreen(), // Pantalla para solicitar nuevo día
                  ),
                );

                // Si se creó un nuevo día (recibes true), recargar la lista
                if (nuevoDiaCreado == true) {
                  setState(() {
                    _loadPermisos(); // Método para recargar la lista
                  });
                }
              },
            child: Text('Solicitar Nuevo Día de Permiso'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // Hace el botón más grande
            ),
          ),
        ],
      ),
    ),
  );
}


}
