import 'dart:async';
import 'dart:convert';
import 'package:fichajes/globals.dart';
import 'package:fichajes/model/task.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskController {

  Future<List<Task>> getProjectTaskList(Task task) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
  
    String? token=preferences.getString('token');

    List<Task> taskList =[];

    Map<String,String> header={
      'DOLAPIKEY': token ?? '',
      'Content-Type': 'application/json'
    };
    
    try {

      String url = '${apiUrl}tasks/events';

      final response=await http.get(Uri.parse(url),headers: header).timeout(const Duration(seconds: 30));

      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      
      switch (response.statusCode) {
        
        case 200:
          for (var task in jsonData) {
          
          Task t=Task();
          t.id=int.parse(task['id']);
          t.projectTitle=task['ProjectTitle'];
          t.companyName=(task['companyName']==null) ? "" : task['companyName'] ;
          t.status=task['status'];
          t.description=task['description'];
          t.projectId=int.parse(task['fk_project']);
          t.companyId=int.parse( (task['companyId']==null) ? "0" : task['companyId'] );

          taskList.add(t);
          
        }
        break;
        
      }
      
        
        
      
    } on TimeoutException {
      //print("Limite de tiempo sobrepasado: $e");
    } on Error catch (e) {
      print(e);
    }

    return taskList;
  }

}