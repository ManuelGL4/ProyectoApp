import 'package:fichajes/utilities.dart';
import 'package:flutter/material.dart';

import '../model/user.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final User _user = User();

  final userField = TextEditingController();
  final passwordField = TextEditingController();

  String user = '';
  String password = '';

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: !isLoading
            ? Center(
                child: loginForm(context, userField, passwordField),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
      ),
    );
  }

  Widget loginForm(BuildContext context, TextEditingController usuario, TextEditingController clave) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // IMAGEN CAMBIAR
        Image.asset(
          'assets/images/deltanet_logo.png',
          height: 100, 
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: TextField(
              controller: usuario,
              autofocus: false,
              style: const TextStyle(fontSize: 18.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Usuario',
                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 6, 90, 158)),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 6, 90, 158)),
                  borderRadius: BorderRadius.circular(25.7),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: TextField(
              obscureText: true,
              controller: clave,
              autofocus: false,
              style: const TextStyle(fontSize: 18.0, color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Contraseña',
                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(25.7),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          height: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor:WidgetStatePropertyAll<Color>(Color.fromARGB(255, 6, 90, 158)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                ),
              ),
            ),
            onPressed: () async {
              user = usuario.text;
              password = clave.text;

              _user.login = user;
              _user.password = password;

              if (user == '' && password == '') {
                return showAlert(
                  context,
                  const Text('Datos incorrectos'),
                  const Text('Debes rellenar los campos de usuario y contraseña'),
                );
              }
              setState(() {
                isLoading = true;
              });
              Map response = await _user.loginAccess();
              setState(() {
                isLoading = false;
              });

              if (!response.containsValue("success")) {
                return showAlert(
                  context,
                  const Text('Error'),
                  Text(response['message']),
                );
              }

              Navigator.of(context).pushNamedAndRemoveUntil('/Home', (Route<dynamic> route) => false);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
