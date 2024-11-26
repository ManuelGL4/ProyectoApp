import 'package:fichajes/controller/event_controller.dart';
import 'package:fichajes/model/user.dart';

class Event {

  String id="";
  String thirdPartyId="";
  String taskId="";
  String projectId="";
  String token="";
  String eventType="";
  String note="";
  String eventLocationRef="";
  String taskLabel="";
  String projectLabel="";
  String thirdPartyLabel="";
  String dateTimeEvent="";
  String userRef="";
  String taskRef="";
  int userId = 0; // Agregar el ID del usuario como propiedad.

  EventController eventController=EventController();

  Event.simple(this.id);
  Event();

  void setUser(User user) {
    userId = user.id; // Establecer el ID del usuario.
  }
  
  // Future<List<Task>> getLastEvent() async{
  //   return taskController.getProjectTaskList(this);
  // }
  Future<Event> getLastEvent() async {
    return eventController.getLastEvent(this);
  }

  Future<Event> startSignTask() async {
    return eventController.startSignTask(this);
  }

  Future<Event> stopSignTask() async {
    return eventController.stopSignTask(this);
  }
  
  Future<List<Event>> getAll() async {
    return eventController.getAll();
  }
  
  Future<List<Event>> delete(String tokenR) async {
    return eventController.delete(tokenR);
  }
  
  Future<Event> update(String id, String fechaInicio, String nota) async {
    return eventController.update(id, fechaInicio, nota);
  }
  
}