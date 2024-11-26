import 'dart:async';
import 'dart:convert';
import 'package:fichajes/globals.dart';
import 'package:fichajes/model/project.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProjectController {

  Future<List<Project>> getProjectList(Project project) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
  
    String? token=preferences.getString('token');

    List<Project> projectList =[];

    Map<String,String> header={
      'DOLAPIKEY': token ?? '',
      "Content-Type": "application/json"
    };
    
    try {

      String id=project.thirdparty_ids;

      String url = '${apiUrl}projects?thirdparty_ids=$id';

      final response=await http.get(Uri.parse(url),headers: header).timeout(const Duration(seconds: 30));

      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      
      switch (response.statusCode) {
        case 200:
          for (var task in jsonData) {
          
          projectList.add(
            Project.all(int.parse(task['id']), task['title'])
          );
          
        }
        break;
        
      }
      
    } on TimeoutException {
      //print("Limite de tiempo sobrepasado: $e");
    } on Error {
      //print(e);
    }

    return projectList;
  }
}