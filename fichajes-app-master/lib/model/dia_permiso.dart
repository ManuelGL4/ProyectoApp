import 'package:fichajes/controller/dias_permiso_controller.dart';

class DiasPermiso {
  String rowid = ""; 
  String label = ""; 
  String dateCreation = ""; 
  String fkUserCreat = ""; // int.
  String? fkUserModif; // int, opcional.
  String? lastMainDoc = ""; // varchar, opcional.
  String status = ""; // smallint.
  String fkUserSolicitado = ""; // int.
  String dateSolic = ""; // datetime, se mantiene como String para compatibilidad.
  String dateSolicFin = ""; // datetime, se mantiene como String para compatibilidad.
  String fkUserValidador=""; // int, opcional.
  String motivos = ""; // varchar.
  bool isAdmin = false; 
  String username="";
  
  DiasPermisoController diasPermisoController = DiasPermisoController();

  DiasPermiso.simple(this.rowid);
  DiasPermiso();


  // Método para obtener todos los permisos
  Future<List<DiasPermiso>> getAllDiasPermisos() async {
    return diasPermisoController.getAllDiasPermisos();
  }
  // Método para actualizar un permiso existente
  Future<DiasPermiso> updateDiasPermiso(DiasPermiso permiso) async {
    return diasPermisoController.updateDiasPermiso(permiso);
  }
  Future<Future<bool>> delete(int rowid) async {
    return diasPermisoController.delete(rowid);
  }
}
