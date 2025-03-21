import 'package:flutter/material.dart';
import 'dart:io';
import 'package:myapp/widgets/image_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _titleController = TextEditingController();
  final _newSubjectController = TextEditingController();
  final _newDetailstController = TextEditingController();
  List<File?> _newImagesSelected = [];
  List<bool> _subjectStatus = [];
  List<String> _subjects = [];
  List<String> _details = [];
  List<List<File?>> _images = []; // to store image

  void _addSubject() {
    setState(() {
      if (_newSubjectController.text.isNotEmpty) {
        _subjects.add(_newSubjectController.text);
        _details.add(_newDetailstController.text); // เพิ่มรายละเอียดกิจกรรม
        _images.add(List<File?>.from(_newImagesSelected));
        _subjectStatus.add(false);
        _newSubjectController.clear();
        _newDetailstController.clear();
        _newImagesSelected = [];
      }
    });
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
      _subjectStatus.removeAt(index);
      _images.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _newImagesSelected.removeAt(index);
    });
  }

  takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600); // ImageSource can choose camera or gallery

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _newImagesSelected.add(File(pickedImage.path));
    });
  }

  Future<void> _saveTaskData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> taskData = {
      'title': _titleController.text,
      'date': _dateController.text,
      'subjects': _subjects,
      'details': _details,
      'status': _subjectStatus.map((status) => status.toString()).toList(),
      'images': _images
          .map((imageList) => imageList.map((file) => file?.path).toList())
          .toList(),
    };
    await prefs.setString('task_data', jsonEncode(taskData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF233F72),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text('เพิ่มกิจกรรม'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'หัวข้อ...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white, fontSize: 24),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รายละเอียด';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'วันที่...',
                  hintStyle: TextStyle(
                    color: Colors.white60,
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่วันที่';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

              // กิจกรรม
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _newSubjectController,
                        decoration: InputDecoration(
                          hintText: 'กิจกรรม...',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _newDetailstController,
                        decoration: InputDecoration(
                          hintText: 'รายละเอียดกิจกรรม...',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      //รูป
                      SizedBox(
                        height: _newImagesSelected.isEmpty ? 0 : 100,
                        child: GridView.builder(
                          itemCount: _newImagesSelected.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Image.file(
                                _newImagesSelected[index]!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              //ตัวแสดงผล
              Expanded(
                child: ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(_subjects[index]),
                        subtitle: Column(
                          children: [
                            Text(_details[index]),
                            //รูป
                            SizedBox(
                              height: _images[index].length == 0 ? 0 : 100,
                              child: GridView.builder(
                                itemCount: _images[index].length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, imgIndex) {
                                  return Image.file(
                                    _images[index][imgIndex]!,
                                    fit: BoxFit.cover,
                                    width: 64,
                                    height: 64,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _subjectStatus[index],
                              onChanged: (value) {
                                setState(() {
                                  _subjectStatus[index] = value!;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeSubject(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _addSubject,
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF233F72),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    'date': _dateController.text,
                    'subject': _subjects,
                    'details': _details,
                    'status': _subjectStatus,
                    'images': _images,
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white), // ไอคอนกล้อง
              onPressed: () {
                takePicture();
              },
            ),
            //ปุ่มเพิ่ม
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _addSubject,
            ),
          ],
        ),
      ),
    );
  }
}
