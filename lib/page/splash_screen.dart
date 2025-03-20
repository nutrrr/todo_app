import 'package:flutter/material.dart';
import 'todo_list_page.dart'; // นำเข้าหน้า todolist

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // หน่วงเวลา 3 วินาที แล้วนำทางไปยังหน้า todolist
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // สีพื้นหลังเป็นสีดำ
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.6,
              child: Image.asset(
                "assets/logo.png", // ใช้ assets/logo.png
                width: 300,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Todo List App", // เปลี่ยนข้อความ
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}