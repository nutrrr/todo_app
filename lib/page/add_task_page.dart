import 'package:flutter/material.dart';
import 'dart:io';
import 'package:myapp/widgets/image_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AddTaskPage extends StatefulWidget {
  String? title;
  String? date;
  List<Map<String, dynamic>>? tasks;

  AddTaskPage({
    this.title,
    this.date,
    this.tasks,
  });
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _newSubjectController = TextEditingController();
  final _newDetailstController = TextEditingController();
  List<File?> _newImagesSelected = [];
  final List<String> _subjects = [];
  final List<bool> _subjectStatus = [];
  final List<String> _details = [];
  final List<List<File?>> _images = []; // to store image

  void init() {
    if (widget.title != null) {
      _titleController.text = widget.title!;
      widget.title = null;
    }

    if (widget.date != null) {
      _dateController.text = widget.date!;
      widget.date = null;
    }

    if (widget.tasks != null) {
      for (var i = 0; i < widget.tasks!.length; i++) {
        _subjects.add(widget.tasks?[i]['subject']);
        _subjectStatus.add(widget.tasks?[i]['status']);
        _details.add(widget.tasks?[i]['details']);
        _images.add(widget.tasks?[i]['images']);
      }
      widget.tasks = null;
    }
  }

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

  // ฟังก์ชันแก้ไขกิจกรรมย่อย
  void _editSubject(int index) {
    TextEditingController editSubjectController =
        TextEditingController(text: _subjects[index]);
    TextEditingController editDetailController =
        TextEditingController(text: _details[index]);

    // คัดลอกรูปภาพสำหรับแก้ไข
    List<File?> tempImages = List.from(_images[index]);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void removeImageInDialog(int imgIndex) {
              setStateDialog(() {
                tempImages.removeAt(imgIndex);
              });
            }

            Future<void> pickImageInDialog() async {
              final imagePicker = ImagePicker();
              final pickedImage =
                  await imagePicker.pickImage(source: ImageSource.gallery);
              if (pickedImage == null) return;
              setStateDialog(() {
                tempImages.add(File(pickedImage.path));
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 380, // กำหนดความกว้าง 380px
                height: 600, // กำหนดความสูง 600px
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "แก้ไขกิจกรรม",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: editSubjectController,
                        decoration: InputDecoration(labelText: 'กิจกรรม'),
                      ),
                      TextField(
                        controller: editDetailController,
                        decoration: InputDecoration(labelText: 'รายละเอียด'),
                      ),
                      SizedBox(height: 10),

                      // แสดงรูปภาพใน GridView
                      Container(
                        height: 150, // จำกัดความสูง
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: tempImages.length,
                          itemBuilder: (context, imgIndex) {
                            return GestureDetector(
                              onTap: () => removeImageInDialog(imgIndex),
                              child: Image.file(tempImages[imgIndex]!,
                                  fit: BoxFit.cover),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: pickImageInDialog,
                        icon: Icon(Icons.add_a_photo),
                        label: Text('เพิ่มรูป'),
                      ),
                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('ยกเลิก'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _subjects[index] = editSubjectController.text;
                                _details[index] = editDetailController.text;
                                _images[index] = List.from(tempImages);
                              });
                              Navigator.pop(context);
                            },
                            child: Text('บันทึก'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      backgroundColor: Color.fromRGBO(35, 63, 114, 1),
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72),
        elevation: 0,
        title: Text(''),
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
                  color: Color(0xFFB0C4DE),
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
                        color: Color(0xFFB0C4DE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(_subjects[index]),
                        subtitle: Column(
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _details[index],
                                )),
                            //รูป
                            SizedBox(
                              height: _images[index].isEmpty
                                  ? 0
                                  : 80, // Increase height
                              child: GridView.builder(
                                itemCount: _images[index].length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8, // Increase spacing
                                  mainAxisSpacing: 8, // Increase spacing
                                ),
                                itemBuilder: (context, imgIndex) {
                                  return Image.file(
                                    _images[index][imgIndex]!,
                                    fit: BoxFit.cover, // or BoxFit.contain
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
                              icon: Icon(Icons.edit), // ปุ่มแก้ไข
                              onPressed: () => _editSubject(index),
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
              icon: Icon(Icons.save, color: Colors.white),
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
