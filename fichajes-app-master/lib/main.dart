import 'package:fichajes/view/home.dart';
import 'package:fichajes/view/login.dart';
import 'package:flutter/material.dart';

import 'model/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        '/Home': (context) => Home(),
        '/Login': (context) => Login(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {

  User user=User();
  late Future<bool> loged= user.checkToken();

  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
        future: Future.wait([widget.loged]),
        builder: (context, snapshot) {
          if (snapshot.connectionState==ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          if (checkResult(snapshot.data)) {
            
            return Home();
            
          }

          return Login();
          
        }
      );
    
  }
  
  bool checkResult(snapshot){
    List<bool> list=snapshot;

    return list[0]==true;

  }
}


