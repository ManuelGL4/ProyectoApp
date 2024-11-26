import 'package:fichajes/controller/task_controller.dart';

class Task {

  int id=0;
  int companyId=0;
  int status=0;
  int projectId=0;
  String projectTitle="";
  String companyName="";
  String description="";
  
  TaskController taskController=TaskController();

  Task.simple(this.id);
  Task();

  Future<List<Task>> getProjectTaskList() async{
    return taskController.getProjectTaskList(this);
  }
  
}