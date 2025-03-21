import 'package:flutter/material.dart';
import 'add_task_page.dart';
import 'detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyTodoListApp());
}

class MyTodoListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todolist',
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final Map<String, List<List<bool>>> tasks = {};

  void addTask(Map<String, dynamic> newTask) {
    setState(() {
      if (tasks.containsKey(newTask['date'])) {
        tasks[newTask['date']]!.add(List<bool>.from(newTask['status']));
      } else {
        tasks[newTask['date']!] = [List<bool>.from(newTask['status'])];
      }
    });
  }

  Widget buildTaskCard(String date, List<List<bool>> taskList) {
    return Dismissible(
      key: Key(date),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          tasks.remove(date);
        });
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          List<Map<String, dynamic>> detailTasks = [];
          if (tasks.containsKey(date)) {
            for (int i = 0; i < tasks[date]![0].length; i++) {
              detailTasks.add({
                'subject': 'กิจกรรม ${i + 1}',
                'status': taskList[0][i],
                'details': 'รายละเอียดของกิจกรรม ${i + 1}...',
              });
            }
          }
          // ดึงข้อมูล subject จาก newTask
          List<String> subjects = [];
          if (tasks.containsKey(date)) {
            for (int i = 0; i < tasks[date]![0].length; i++) {
              subjects.add('กิจกรรม ${i + 1}');
            }
          }
          // สร้าง detailTasks โดยใช้ข้อมูล subject ที่ผู้ใช้กรอก
          detailTasks.clear();
          for (int i = 0; i < subjects.length; i++) {
            detailTasks.add({
              'subject': subjects[i],
              'status': taskList[0][i],
              'details':
                  'รายละเอียดของ ${subjects[i]}...', // แก้ไขรายละเอียดตามต้องการ
            });
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                date: date,
                tasks: detailTasks,
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE9EFF5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date $date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(taskList[0].length, (subIndex) {
                  return Column(
                    children: [
                      Checkbox(
                        value: taskList[0][subIndex],
                        onChanged: (bool? value) {
                          setState(() {
                            taskList[0][subIndex] = value!;
                          });
                        },
                        activeColor: Color(0xFF51D11A),
                        checkColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'กิจกรรม ${subIndex + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF233F72),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text(
          'TODOLIST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: Icon(Icons.add, size: 28, color: Colors.white),
                onPressed: () async {
                  final newTask = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskPage(),
                    ),
                  );
                  if (newTask != null) {
                    addTask(newTask);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tasks.entries
                .map((entry) => buildTaskCard(entry.key, entry.value))
                .toList(),
          ),
        ),
      ),
    );
  }
}
