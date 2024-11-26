import 'package:fichajes/controller/user_controller.dart';

class User {

  int id=0;
  String name="";
  String surname="";
  String login="";
  String password="";
  UserController userController=UserController();

  User.simple(this.id);
  User.all(this.id,this.name,this.surname);
  User();

  Future<bool> checkToken() async {
    return userController.checkToken();
  }

  Future<Map> loginAccess() async {
    return userController.login(this);
  }

  //  Future<void> getUserInfo() async {
  //   userController.getUserInfo();
  //  }

   Future<void> logout() async {
    userController.logout();
   }
  
}