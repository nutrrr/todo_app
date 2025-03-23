import 'package:flutter/material.dart';
import 'package:myapp/page/add_task_page.dart';

class DetailPage extends StatefulWidget {
  final String title;
  final String date;
  final List<Map<String, dynamic>> tasks;

  const DetailPage({
    required this.title,
    required this.date,
    required this.tasks,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late List<Map<String, dynamic>> updatedTasks;
  late String localTitle;
  late String localDate;

  @override
  void initState() {
    super.initState();
    updatedTasks = List.from(widget.tasks);
    localTitle = widget.title;
    localDate = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF233F72),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text('รายละเอียดกิจกรรม', style: TextStyle(fontSize: 24)),
        titleTextStyle: TextStyle(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localTitle, // Use localTitle here
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'วันที่: $localDate', // Use localDate here
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: updatedTasks.length,
                itemBuilder: (context, index) {
                  final task = updatedTasks[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6.0),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFB0C4DE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        task['subject'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          decoration: task['status']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              task['details'],
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ),
                          SizedBox(
                            height: task['images'].length == 0 ? 0 : 100,
                            child: GridView.builder(
                              itemCount: task['images'].length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemBuilder: (context, imgIndex) {
                                return Image.file(
                                  task['images'][imgIndex]!,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task['status'],
                        activeColor: Color(0xFF51D11A),
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            updatedTasks[index]['status'] = value!;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Color(0xFF1C3551),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.save, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context, {
                  'title': localTitle,
                  'date': localDate,
                  'tasks': updatedTasks,
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white, size: 28),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskPage(
                      title: localTitle,
                      date: localDate,
                      tasks: updatedTasks,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    localTitle = result['title'];
                    localDate = result['date'];
                    updatedTasks = List.generate(
                      result['subject'].length,
                      (i) => {
                        'subject': result['subject'][i],
                        'status': result['status'][i],
                        'details': result['details'][i],
                        'images': result['images'][i],
                      },
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
