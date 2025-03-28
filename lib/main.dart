import 'package:flutter/material.dart';
import 'package:myapp/page/splash_screen.dart';

void main() {
  runApp(MyTodoListApp());
}

class MyTodoListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todolist',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // แสดงหน้าจอเริ่มต้น
    );
  }
}
