import 'package:flutter/material.dart';
import 'dart:io';

class DetailPage extends StatelessWidget {
  final String title;
  final String date;
  final List<dynamic> tasks;

  DetailPage({
    required this.title,
    required this.date,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF233F72),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text('รายละเอียดกิจกรรม'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'วันที่: $date',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final bool status = task['status'] ?? false;
                  final List<dynamic>? imagesList = task['images'][index];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 3.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        task['subject'],
                        style: TextStyle(
                          fontSize: 20,
                          decoration:
                              status ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['details'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (imagesList != null && imagesList.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: GridView.builder(
                                itemCount: imagesList.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, imgIndex) {
                                  final img = imagesList[imgIndex];
                                  if (img != null) {
                                    return Image.file(
                                      img,
                                      fit: BoxFit.cover,
                                      width: 64,
                                      height: 64,
                                    );
                                  } else {
                                    return Container(); // Empty container for null images
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: status,
                        onChanged: null, // Read-only in detail view
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF233F72),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // TODO: Implement edit functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
