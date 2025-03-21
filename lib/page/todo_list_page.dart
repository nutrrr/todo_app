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
  //        ชื่อ          ชื่อข้อ    ข้อมูล
  final Map<String, Map<String, dynamic>> tasks = {};

  void addTask(Map<String, dynamic> newTask) {
    setState(() {
      Map<String, dynamic> tempTask = {};
      tempTask['date'] = newTask['date'];
      tempTask['subject'] = List<String>.from(newTask['subject']);
      tempTask['details'] = List<String>.from(newTask['details']);
      tempTask['status'] = List<bool>.from(newTask['status']);
      tempTask['images'] = List<List<File?>>.from(newTask['images']);

      tasks[newTask['title']!] = tempTask;
    });
  }

  Widget buildTaskCard(String title, Map<String, dynamic> taskList) {
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          tasks.remove(title);
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
          if (tasks.containsKey(title)) {
            for (int i = 0; i < tasks[title]!['subject'].length; i++) {
              detailTasks.add({
                'subject': tasks[title]!['subject'][i],
                'details': tasks[title]!['details'],
                'status': tasks[title]!['status'][i],
              });
            }
          }
          // ดึงข้อมูล subject จาก newTask
          List<String> subjects = [];
          if (tasks.containsKey(title)) {
            for (int i = 0; i < tasks[title]!['subject'].length; i++) {
              subjects.add(tasks[title]!['subject'][i]);
            }
          }
          // สร้าง detailTasks โดยใช้ข้อมูล subject ที่ผู้ใช้กรอก
          detailTasks.clear();
          for (int i = 0; i < subjects.length; i++) {
            detailTasks.add({
              'subject': subjects[i],
              'status': taskList['status'][i],
              'details': taskList['details'][i],
              'images': taskList['images']
            });
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                date: title,
                tasks: detailTasks,
              ),
            ),
          );
        },
        //กล่องtodo
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
                '$title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(taskList['subject'].length, (subIndex) {
                  return Column(
                    children: [
                      Checkbox(
                        value: taskList['status'][subIndex],
                        onChanged: (bool? value) {
                          setState(() {
                            taskList['status'][subIndex] = value!;
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
                        '${taskList['subject'][subIndex]}',
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
