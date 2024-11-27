import 'package:flutter/material.dart';
import 'package:fichajes/controller/dias_permiso_controller.dart'; // Asegúrate de importar el controlador

class SolicitarNuevoDiaScreen extends StatefulWidget {
  @override
  _SolicitarNuevoDiaScreenState createState() => _SolicitarNuevoDiaScreenState();
}

class _SolicitarNuevoDiaScreenState extends State<SolicitarNuevoDiaScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fechaInicioController = TextEditingController();
  TextEditingController _fechaFinController = TextEditingController();
  TextEditingController _descripcionController = TextEditingController();
  String? _selectedValidador;  
  String? _selectedValidadorId;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _usuarios = []; 

  @override
  void initState() {
    super.initState();
    _fetchUsuarios();  
  }

  Future<void> _fetchUsuarios() async {
    DiasPermisoController controller = DiasPermisoController();
    List<Map<String, dynamic>> usuarios = await controller.getUsuarios();

    setState(() {
      _usuarios = usuarios;
    });
  }

  Future<void> _selectFechaHora(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        final DateTime finalDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        controller.text = "${finalDateTime.toLocal()}".split(' ')[0] + " " + "${finalDateTime.hour}:${finalDateTime.minute}";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar Nuevo Día de Permiso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _selectFechaHora(_fechaInicioController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _fechaInicioController,
                    decoration: InputDecoration(
                      labelText: 'Fecha y Hora de Inicio',
                      hintText: 'DD/MM/YYYY HH:MM',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la fecha y hora de inicio';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectFechaHora(_fechaFinController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _fechaFinController,
                    decoration: InputDecoration(
                      labelText: 'Fecha y Hora de Fin',
                      hintText: 'DD/MM/YYYY HH:MM',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la fecha y hora de fin';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              _usuarios.isEmpty
                  ? CircularProgressIndicator() 
                  : DropdownButtonFormField<String>(
                      value: _selectedValidador,
                      decoration: InputDecoration(
                        labelText: 'Administrador Validador',
                        border: OutlineInputBorder(),
                      ),
                      items: _usuarios.map((usuario) {
                        return DropdownMenuItem<String>(
                          value: usuario['nombre'], 
                          child: Text(usuario['nombre']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedValidador = value;
                          _selectedValidadorId = _usuarios
                              .firstWhere((usuario) => usuario['nombre'] == value)['rowid']
                              .toString();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione un validador';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Solicitar Permiso'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

void _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    setState(() {
      _isSubmitting = true;
    });

    // Recoger los datos del formulario
    String fechaInicio = _fechaInicioController.text;
    String fechaFin = _fechaFinController.text;
    String descripcion = _descripcionController.text;
    String validadorId = _selectedValidadorId ?? '';

    // Crear una instancia del controlador
    DiasPermisoController controller = DiasPermisoController();

    try {
      // Llamar al método para guardar el día de permiso
      var response = await controller.solicitarPermiso(fechaInicio, fechaFin, descripcion, validadorId);
      //print("Fecha de inicio"+ fechaInicio + " FINAL " + fechaFin + " DESCRIPCION " + descripcion + " VALIDADOR " + validadorId);
      // Comprobar la respuesta (ajusta esto según la estructura de la respuesta de tu API)
      if (response['success']) {
        setState(() {
          _isSubmitting = false;
        });
        bool diaCreado = true;

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Día de permiso solicitado con éxito')),
        );

        // Cerrar la pantalla después de la solicitud
        Navigator.pop(context, diaCreado);
      } else {
        setState(() {
          _isSubmitting = false;
        });

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al solicitar el permiso')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      // Mostrar mensaje de error si algo sale mal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

}
