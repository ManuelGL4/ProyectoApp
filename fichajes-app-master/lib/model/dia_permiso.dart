import 'package:fichajes/controller/dias_permiso_controller.dart';

class DiasPermiso {
  String rowid = ""; 
  String label = ""; 
  String dateCreation = ""; 
  String fkUserCreat = ""; 
  String? fkUserModif;
  String? lastMainDoc = ""; 
  String status = ""; 
  String fkUserSolicitado = ""; 
  String dateSolic = ""; 
  String dateSolicFin = ""; 
  String fkUserValidador=""; 
  String motivos = ""; 
  bool isAdmin = false; 
  String username="";
  
  DiasPermisoController diasPermisoController = DiasPermisoController();

  DiasPermiso.simple(this.rowid);
  DiasPermiso();


  Future<List<DiasPermiso>> getAllDiasPermisos() async {
    return diasPermisoController.getAllDiasPermisos();
  }

  Future<DiasPermiso> updateDiasPermiso(DiasPermiso permiso) async {
    return diasPermisoController.updateDiasPermiso(permiso);
  }
  Future<Future<bool>> delete(int rowid) async {
    return diasPermisoController.delete(rowid);
  }
}
