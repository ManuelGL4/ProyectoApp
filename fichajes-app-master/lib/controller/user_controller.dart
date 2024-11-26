import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:fichajes/globals.dart';
import 'package:fichajes/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserController{
  
  Future<Map> login(User user) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map loginResponse={};
    
    Map data={
      "login": user.login,
      "password": user.password,
      "reset":0
    };

    try {

      String body = jsonEncode(data);
      String url = '${apiUrl}login';
  
      final response = await http
          .post(Uri.parse(url), body: body, headers: {"Content-Type": "application/json"},)
          .timeout(const Duration(seconds: 30));

      String bodyResponse = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(bodyResponse);

      switch (response.statusCode) {
        case 200:
          preferences.setString('token', jsonData['success']['token']);
          preferences.setString('userId', jsonData['success']['id']);
          
          loginResponse={
            "status":"success",
            "message":"Acceso concedido"
          };
        break;
        case 403:
          loginResponse={
            "status":"error",
            "message":"Acceso denegado, usuario o contraseña incorrectos"
          };
        break;
        case 500:
          loginResponse={
            "status":"error",
            "message":"Error del sistema"
          };
        break;
        
      }
      
    } on TimeoutException catch (e) {
      print("Limite de tiempo sobrepasado: " + e.toString());
    } on Error catch (e) {
      print(e);
    }

    return loginResponse;
  }

  Future<bool> checkToken() async {
    bool loged = false;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    try {
      String? token = preferences.getString('token');
      
      //Comprobar si el Token está activo
      Map<String,String> header={
        'DOLAPIKEY': token ?? ''
      };
      try {
       
        String url = '${apiUrl}tasks/events';

        final response = await http.get(Uri.parse(url),headers: header).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          
          loged = true;
          
        }
      } on Error catch (e) {
        //print(e);
      }
        } catch (e) {
      return loged;
    }
    return loged;
  }

  Future<void> logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    try {
      final successToken = await preferences.remove('token');
    } catch (e) {
      //print(e);
    }
  }
}