import 'dart:async';
import 'dart:convert';
import 'package:fichajes/globals.dart';
import 'package:fichajes/model/event.dart';
import 'package:fichajes/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventController {

Future<Event> startSignTask(Event event) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString('token');

//Obtener el id del usuario
  String userId = preferences.getString('userId')?? '';

  Map<String, String> header = {
    'DOLAPIKEY': token ?? '',
    'Content-Type': 'application/json',
  };
  User user = User();
  Map data = {
    // 'fk_userid': event.userId,
    'fk_third_party': event.thirdPartyId,
    'fk_project': event.projectId,
    'fk_task': event.taskId,
    'event_location_ref': event.eventLocationRef,
    'note': event.note,
    'event_type': 2,
    'status': 1,
    'fk_userid': userId,
  };

  Event e = Event();

  try {
    String url = '${apiUrl}chronoapi/chrono';
    String json = jsonEncode(data);

    final response = await http.post(Uri.parse(url), headers: header, body: json).timeout(const Duration(seconds: 30));
    String body = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(body);

    print('Response Body: $body'); 

    switch (response.statusCode) {
      case 200:
        e.id = jsonData['id'];
        e.eventType = jsonData['event_type']; 
        e.note = jsonData['note'];
        e.thirdPartyId = jsonData['fk_third_party'];
        e.taskId = jsonData['fk_task'];
        e.projectId = jsonData['fk_project'];
        e.token = jsonData['token'];
        break;
      default:
        print('Error: ${jsonData['message']}');
        break;
    }
  } on TimeoutException {
    // Maneja el timeout
  } on Error catch (e) {
    print('Error: $e');
  }

  return e;
}


  Future<Event> stopSignTask(Event event) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
  
    String? token=preferences.getString('token');
    String userId = preferences.getString('userId')?? '';

    Map<String,String> header={
      'DOLAPIKEY': token ?? '',
      'Content-Type': 'application/json'
    };

    Map data={
    'fk_third_party': event.thirdPartyId,
    'fk_project': event.projectId,
    'fk_task': event.taskId,
    'event_location_ref': event.eventLocationRef,
    'note': event.note,
    'event_type': 3,
    'status': 1,
    'fk_userid': userId,
    };

    Event e=Event();
    
    try {

      String url = '${apiUrl}chronoapi/chrono';

      String json = jsonEncode(data);

      final response=await http.post(Uri.parse(url),headers: header, body: json).timeout(const Duration(seconds: 30));

      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      
      switch (response.statusCode) {
        
        case 200:
            
          e.id=jsonData['id'].toString();
          e.eventType=jsonData['event_type'];
          e.note=jsonData['note'];
          e.thirdPartyId=jsonData['third_party'];
          e.taskId=jsonData['task'];
          e.projectId=jsonData['project'];
          e.token=jsonData['token'];
          
        break;
        
      }
      
    } on TimeoutException {
      //print("Limite de tiempo sobrepasado: $e");
    } on Error {
      //print(e);
    }

    return e;
  }

Future<Event> getLastEvent(Event event) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
  
    String? token=preferences.getString('token');
    String userId = preferences.getString('userId')?? '';

    Map<String,String> header={
      'DOLAPIKEY': token?? '',
      'Content-Type': 'application/json'
    };

    Event e=Event();
    
    try {

      String url = '${apiUrl}chronoapi/obtenerRegistrosActivos/$userId';

      final response=await http.get(Uri.parse(url),headers: header).timeout(const Duration(seconds: 30));

      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      
      switch (response.statusCode) {
        
        case 200:
            
          e.id=jsonData['id'].toString();
          e.eventType=jsonData['event_type'];
          e.thirdPartyId=jsonData['third_party'];
          e.taskId=jsonData['task'];
          e.projectId=jsonData['project'];
          e.token=jsonData['token'];
          
        break;
        case 404:
        
        break;
        
      }
      
    } on TimeoutException {
      //print("Limite de tiempo sobrepasado: $e");
    } on Error {
      //print(e);
    }

    return e;
  }




 Future<List<Event>> getAll({int page = 1, int limit = 20}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  
  String? token = preferences.getString('token');
  String userId = preferences.getString('userId') ?? '';

  Map<String, String> header = {
    'DOLAPIKEY': token ?? '',
    'Content-Type': 'application/json'
  };

  List<Event> events = [];

  try {
    // URL con parámetros de paginación
    String url = '${apiUrl}chronoapi/listar?page=$page&limit=$limit&fk_user_id=$userId';

    final response = await http.get(Uri.parse(url), headers: header).timeout(const Duration(seconds: 30));

    String body = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(body);

    if (response.statusCode == 200 && jsonData is List) {
      for (var eventData in jsonData) {
        Event e = Event();
        e.id = eventData['rowid'].toString();
        e.thirdPartyId = eventData['fk_third_party'].toString();
        e.taskId = eventData['fk_task'].toString();
        e.projectId = eventData['fk_project'].toString();
        e.token = eventData['token'].toString();
        e.eventType = eventData['event_type'].toString();
        e.note = eventData['note'].toString();
        e.eventLocationRef = eventData['event_location_ref'].toString();
        e.taskLabel = eventData['task_label'].toString();
        e.projectLabel = eventData['project_label'].toString();
        e.thirdPartyLabel = eventData['third_party_label'].toString();
        e.dateTimeEvent = eventData['date_time_event'].toString();
        e.userId = eventData['fk_userid'] != null ? int.tryParse(eventData['fk_userid'].toString()) ?? 0 : 0;
        e.userRef = eventData['user_name'].toString();  // Nombre del usuario
        e.taskRef = eventData['task_label'].toString();
        events.add(e);
      }
    } else if (response.statusCode == 404) {
      print("No events found");
    } else {
      print("Error: ${response.statusCode}");
    }
  } on TimeoutException {
    print("Timeout reached");
  } on Error catch (e) {
    print("Error: $e");
  }

  return events;
}

Future<List<Event>> delete(String tokenR) async {
  // Obtener el token de las preferencias
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? token = preferences.getString('token');

  Map<String, String> header = {
    'DOLAPIKEY': token ?? '',
    'Content-Type': 'application/json',
  };

  String url = '${apiUrl}chronoapi/chrono?token=$tokenR'; 

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: header,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      print("Evento eliminado exitosamente.");
      return []; 
    } else {
      throw Exception("Error al eliminar el evento: ${response.body}");
    }
  } catch (error) {
    throw Exception("Error al hacer la solicitud: $error");
  }
}


Future<Event> update(String id, String fechaInicio, String nota) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  
  String? token = preferences.getString('token');
  String userId = preferences.getString('userId') ?? '';

  Map<String, String> header = {
    'DOLAPIKEY': token ?? '',
    'Content-Type': 'application/json'
  };

  String fechaInicioString = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(fechaInicio));
  String notaFinal = nota.isEmpty ? '' : nota;

  print(fechaInicioString);
  Map<String, dynamic> requestBody = {
    'fecha_inicio': fechaInicioString,
    'nota': notaFinal,
    'fk_user': userId,
  };

  try {
    String url = '${apiUrl}chronoapi/chrono/update/$id';

    final response = await http.put(Uri.parse(url), 
      headers: header,
      body: jsonEncode(requestBody), 
    ).timeout(const Duration(seconds: 30));

    String body = utf8.decode(response.bodyBytes);
    final jsonData = jsonDecode(body);

    if (response.statusCode == 200 && jsonData is Map) {
      Event e = Event();
      e.id = jsonData['id'].toString();
      e.thirdPartyId = jsonData['fk_third_party'].toString();
      e.taskId = jsonData['fk_task'].toString();
      e.projectId = jsonData['fk_project'].toString();
      e.token = jsonData['token'].toString();
      e.eventType = jsonData['event_type'].toString();
      e.note = jsonData['note'].toString();
      e.eventLocationRef = jsonData['event_location_ref'].toString();
      e.taskLabel = jsonData['task_label'].toString();
      e.projectLabel = jsonData['project_label'].toString();
      e.thirdPartyLabel = jsonData['third_party_label'].toString();
      e.dateTimeEvent = jsonData['date_time_event'].toString();
      e.userId = jsonData['fk_userid'] != null ? int.tryParse(jsonData['fk_userid'].toString()) ?? 0 : 0;
      e.userRef = jsonData['user_name'].toString();
      e.taskRef = jsonData['task_label'].toString();
      return e;  
    } else {
      throw Exception("Error al actualizar el evento: ${response.statusCode}");
    }
  } catch (e) {
    print("Error en la solicitud de actualización: $e");
    rethrow;  
  }
}


}