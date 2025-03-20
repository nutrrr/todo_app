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
  final _title = TextEditingController();
  final _newSubjectController = TextEditingController();
  final _newDetailstController = TextEditingController();
  List<File?> _newImagesSelected = [];
  List<bool> _subjectStatus = [];
  List<String> _subjects = [];
  List<String> _details = [];
  List<List<File?>> _images = []; // to store your preview image

  void _addSubject() {
    setState(() {
      if (_newSubjectController.text.isNotEmpty &&
          _newDetailstController.text.isNotEmpty) {
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
      'title': _title.text,
      'date': _dateController.text,
      'details': _title.text,
      'subjects': _subjects,
      'status': _subjectStatus.map((status) => status.toString()).toList(),
    };
    await prefs.setString('task_data', jsonEncode(taskData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text('เพิ่มกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'วันที่'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่วันที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: 'รายละเอียด'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รายละเอียด';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _newSubjectController,
                      decoration: InputDecoration(labelText: 'ชื่อกิจกรรม'),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _newDetailstController,
                      decoration:
                          InputDecoration(labelText: 'รายละเอียดกิจกรรม'),
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addSubject,
                    ),

                    //รูป
                    Container(
                        height: _newImagesSelected.length == 0 ? 0 : 100,
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
                        )),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_subjects[index]),
                      subtitle: Column(
                        children: [
                          Text(_details[index]),
                          //รูป
                          Container(
                            height: 100,
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
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveTaskData();
                    Navigator.pop(context);
                  }
                },
                child: Text('เพิ่ม'),
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
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white), // ไอคอนกล้อง
              onPressed: () {
                takePicture();
              },
            ),
          ],
        ),
      ),
    );
  }
}
