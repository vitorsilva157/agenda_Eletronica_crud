import 'package:flutter/material.dart';
import 'package:flutter_agenda/home_scren.dart';




void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.indigo,
      ),
      home: HomeScreen(),
    );
  }
}


