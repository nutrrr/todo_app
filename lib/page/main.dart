import 'package:flutter/material.dart';
import 'splash_screen.dart'; // นำเข้าหน้าจอเริ่มต้น
// นำเข้าหน้า todolist

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
