import 'package:flutter/material.dart';
import 'add_task_page.dart';
import 'detail_page.dart';
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
  final Map<String, Map<String, dynamic>> listTasks = {};
  int _currentPage = 0;
  final int _tasksPerPage = 3;

  void addTask(Map<String, dynamic> newTask) {
    setState(() {
      listTasks[newTask['title']!] = {
        'date': newTask['date'],
        'subject': List<String>.from(newTask['subject']),
        'details': List<String>.from(newTask['details']),
        'status': List<bool>.from(newTask['status']),
        'images': List<List<File?>>.from(newTask['images']),
      };
    });
  }

  Widget buildTaskCard(String title, Map<String, dynamic> taskList) {
    int totalTasks = taskList['subject'].length;
    int _currentPage = taskList['currentPage'] ?? 0; // ใช้ค่าของแต่ละ task list

    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          listTasks.remove(title);
        });
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                title: title,
                date: taskList['date'],
                tasks: List.generate(
                  taskList['subject'].length,
                  (i) => {
                    'subject': taskList['subject'][i],
                    'status': taskList['status'][i],
                    'details': taskList['details'][i],
                    'images': taskList['images'][i],
                  },
                ),
              ),
            ),
          );

          if (result != null) {
            setState(() {
              // Handle the complete updated task information
              String updatedTitle = result['title'];
              String updatedDate = result['date'];
              List<Map<String, dynamic>> updatedTasks = result['tasks'];

              // If the title has changed, we need to remove the old entry and add a new one
              if (updatedTitle != title) {
                listTasks.remove(title);

                // Create a new entry with the updated title
                listTasks[updatedTitle] = {
                  'date': updatedDate,
                  'subject': List.generate(
                      updatedTasks.length, (i) => updatedTasks[i]['subject']),
                  'details': List.generate(
                      updatedTasks.length, (i) => updatedTasks[i]['details']),
                  'status': List.generate(
                      updatedTasks.length, (i) => updatedTasks[i]['status']),
                  'images': List.generate(
                      updatedTasks.length, (i) => updatedTasks[i]['images']),
                  'currentPage':
                      taskList['currentPage'] ?? 0, // Preserve pagination state
                };
              } else {
                // Just update the existing entry
                listTasks[title]!['date'] = updatedDate;
                listTasks[title]!['subject'] = List.generate(
                    updatedTasks.length, (i) => updatedTasks[i]['subject']);
                listTasks[title]!['details'] = List.generate(
                    updatedTasks.length, (i) => updatedTasks[i]['details']);
                listTasks[title]!['status'] = List.generate(
                    updatedTasks.length, (i) => updatedTasks[i]['status']);
                listTasks[title]!['images'] = List.generate(
                    updatedTasks.length, (i) => updatedTasks[i]['images']);
              }
            });
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color.fromRGBO(233, 239, 245, 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
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
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (totalTasks > 3)
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          size: 18,
                          color: _currentPage > 0
                              ? Colors.black54
                              : const Color.fromRGBO(0, 0, 0, 0)),
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                taskList['currentPage'] = _currentPage - 1;
                              });
                            }
                          : null,
                    ),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        (_tasksPerPage < totalTasks - _currentPage)
                            ? _tasksPerPage
                            : totalTasks - _currentPage,
                        (subIndex) {
                          int realIndex = _currentPage + subIndex;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Checkbox(
                                  value: taskList['status'][realIndex],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      taskList['status'][realIndex] = value!;
                                    });
                                  },
                                  activeColor: Color(0xFF51D11A),
                                  checkColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  taskList['subject'][realIndex].length > 10
                                      ? '${taskList['subject'][realIndex].substring(0, 10)}...'
                                      : taskList['subject'][realIndex],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (totalTasks > 3)
                    IconButton(
                      icon: Icon(Icons.arrow_forward,
                          size: 18,
                          color: _currentPage + _tasksPerPage < totalTasks
                              ? Colors.black54
                              : const Color.fromRGBO(0, 0, 0, 0)),
                      onPressed: _currentPage + _tasksPerPage < totalTasks
                          ? () {
                              setState(() {
                                taskList['currentPage'] = _currentPage + 1;
                              });
                            }
                          : null,
                    ),
                ],
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
      backgroundColor: Color.fromRGBO(35, 63, 114, 1),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text(
          'TODOLIST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: IconButton(
                icon: Icon(Icons.add, size: 22, color: Colors.white),
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
      body: ListView(
        children: listTasks.entries
            .map((entry) => buildTaskCard(entry.key, entry.value))
            .toList(),
      ),
    );
  }
}
