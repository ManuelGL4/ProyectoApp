import 'package:fichajes/controller/project_controller.dart';
import 'package:fichajes/model/task.dart';

class Project {

  int id=0;
  String title="";
  String thirdparty_ids="";
  List<Task> listTask=[];
  ProjectController projectController=ProjectController();

  Project.simple(this.id);
  Project.all(this.id,this.title);
  Project();

   Future<List<Project>> getProjectList(thirdparty_ids){
      this.thirdparty_ids=thirdparty_ids;
      return projectController.getProjectList(this);
   }
  
}