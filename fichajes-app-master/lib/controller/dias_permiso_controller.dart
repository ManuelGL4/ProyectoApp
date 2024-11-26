import 'dart:async';
import 'dart:convert';
import 'package:fichajes/globals.dart';
import 'package:fichajes/model/dia_permiso.dart';
import 'package:fichajes/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiasPermisoController {


  // Método para obtener todos los permisos
  Future<List<DiasPermiso>> getAllDiasPermisos({int page = 1, int limit = 20}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token');
    String userId = preferences.getString('userId') ?? '';

    Map<String, String> header = {
      'DOLAPIKEY': token ?? '',
      'Content-Type': 'application/json',
    };

    List<DiasPermiso> permisos = [];

    try {
      String url = '${apiUrl}recursoshumanosapi/listar?page=$page&limit=$limit&fk_user_id=$userId'; 

      final response = await http.get(Uri.parse(url), headers: header).timeout(const Duration(seconds: 30));

      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      if (response.statusCode == 200 && jsonData is List) {
        for (var permisoData in jsonData) {
          DiasPermiso permiso = DiasPermiso();
          permiso.rowid = permisoData['rowid'];
          permiso.label = permisoData['label'];
          permiso.fkUserSolicitado = permisoData['fk_user_solicitado'];
          permiso.dateSolic = permisoData['date_solic'];
          permiso.dateSolicFin = permisoData['date_solic_fin'];
          permiso.motivos = permisoData['motivos'];
          permiso.status = permisoData['status'];
          permiso.fkUserCreat = permisoData['fk_user_creat'];
          permiso.isAdmin = permisoData['is_admin'];
          permiso.username=permisoData['user_name'];
          permisos.add(permiso);
        }
      } else {
        print("No permisos found or error in response");
      }
    } on TimeoutException {
      print("Timeout reached");
    } on Error catch (e) {
      print("Error: $e");
    }

    return permisos;
  }
// Método para actualizar un permiso existente
Future<DiasPermiso> updateDiasPermiso(DiasPermiso permiso) async {
  // Obtener el token y userId de SharedPreferences
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString('token');
  String userId = preferences.getString('userId') ?? '';

  // Definir los encabezados de la solicitud
  Map<String, String> header = {
    'DOLAPIKEY': token ?? '',
    'Content-Type': 'application/json',
  };

  // URL para la actualización del permiso
  String url = '${apiUrl}recursoshumanosapi/diapermiso';

  // Crear el cuerpo de la solicitud con los valores de `permiso`
  Map<String, dynamic> body = {
    'rowid': permiso.rowid,
    'label': permiso.label,
    'fk_user_solicitado': permiso.fkUserSolicitado,
    'date_solic': permiso.dateSolic,
    'date_solic_fin': permiso.dateSolicFin,
    'motivos': permiso.motivos,
    'status': permiso.status,
    'fk_user_creat': permiso.fkUserCreat,
    'is_admin': permiso.isAdmin,
    'user_id': userId,  // Incluir el ID de usuario si es necesario para la autenticación
  };

  try {
    // Realizar la solicitud POST
    final response = await http.put(Uri.parse(url), headers: header, body: jsonEncode(body)).timeout(const Duration(seconds: 30));

    // Decodificar la respuesta
    String responseBody = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(responseBody);

    if (response.statusCode == 200 && jsonData is Map) {
      // Crear un nuevo objeto `DiasPermiso` con los datos actualizados
      DiasPermiso updatedPermiso = DiasPermiso();
      updatedPermiso.rowid = jsonData['rowid'];
      updatedPermiso.label = jsonData['label'];
      updatedPermiso.fkUserSolicitado = jsonData['fk_user_solicitado'];
      updatedPermiso.dateSolic = jsonData['date_solic'];
      updatedPermiso.dateSolicFin = jsonData['date_solic_fin'];
      updatedPermiso.motivos = jsonData['motivos'];
      updatedPermiso.status = jsonData['status'];
      updatedPermiso.fkUserCreat = jsonData['fk_user_creat'];
      updatedPermiso.isAdmin = jsonData['is_admin'];

      return updatedPermiso;  // Devolver el permiso actualizado
    } else {
      print("No permisos found or error in response");
    }
  } on TimeoutException {
    print("Timeout reached");
  } on Error catch (e) {
    print("Error: $e");
  }

  // Si algo falla, devolvemos un objeto vacío
  return DiasPermiso();
}


Future<bool> delete(int rowid) async {
  // Obtener el token y userId de SharedPreferences
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString('token');
  
  // Definir los encabezados de la solicitud
  Map<String, String> header = {
    'DOLAPIKEY': token ?? '',
    'Content-Type': 'application/json',
  };
  
  // URL para la eliminación del permiso
  String url = '${apiUrl}recursoshumanosapi/diapermiso/$rowid';
  
  try {
    // Realizar la solicitud DELETE
    final response = await http.delete(Uri.parse(url), headers: header).timeout(const Duration(seconds: 30));
    
    // Decodificar la respuesta
    String responseBody = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(responseBody);
    
    if (response.statusCode == 200 && jsonData['message'] == 'Permiso eliminado correctamente') {
      print(jsonData['message']); // Log del mensaje de éxito
      return true; // Indicar que la eliminación fue exitosa
    } else {
      print("Error en la respuesta: ${response.statusCode}");
      return false; // Indicar que hubo un error
    }
  } on TimeoutException {
    print("Timeout alcanzado");
    return false;
  } catch (e) {
    print("Error: $e");
    return false;
  }
}




}