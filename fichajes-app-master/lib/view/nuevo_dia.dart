import 'package:flutter/material.dart';
import 'package:fichajes/controller/dias_permiso_controller.dart';

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
    // Validar que las fechas sean válidas
    DateTime? fechaInicio = DateTime.tryParse(_fechaInicioController.text);
    DateTime? fechaFin = DateTime.tryParse(_fechaFinController.text);

    if (fechaInicio == null || fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las fechas ingresadas no son válidas')),
      );
      return;
    }

    if (fechaInicio.isAfter(fechaFin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La fecha de inicio debe ser anterior a la fecha de fin')),
      );
      return;
    }

    if (_selectedValidadorId == null || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String fechaInicioStr = _fechaInicioController.text;
    String fechaFinStr = _fechaFinController.text;
    String descripcion = _descripcionController.text;
    String validadorId = _selectedValidadorId ?? '';

    DiasPermisoController controller = DiasPermisoController();

    try {
      var response = await controller.solicitarPermiso(fechaInicioStr, fechaFinStr, descripcion, validadorId);
      if (response['success']) {
        setState(() {
          _isSubmitting = false;
        });
        bool diaCreado = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Día de permiso solicitado con éxito')),
        );

        // Cerrar la pantalla al crear el día de permiso
        Navigator.pop(context, diaCreado);
      } else {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al solicitar el permiso')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
}
