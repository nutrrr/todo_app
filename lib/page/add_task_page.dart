import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _detailsController = TextEditingController();
  final _newSubjectController = TextEditingController();
  List<bool> _subjectStatus = [];
  List<String> _subjects = [];

  void _addSubject() {
    setState(() {
      _subjects.add(_newSubjectController.text);
      _subjectStatus.add(false);
      _newSubjectController.clear();
    });
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
      _subjectStatus.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF233F72), // สีพื้นหลังตามรูป
      appBar: AppBar(
        backgroundColor: Color(0xFF233F72), // สี AppBar ตามรูป
        elevation: 0, // ไม่มีเงา
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
                controller: _detailsController,
                decoration: InputDecoration(labelText: 'รายละเอียด'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รายละเอียด';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newSubjectController,
                      decoration: InputDecoration(labelText: 'ชื่อกิจกรรม'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addSubject,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_subjects[index]),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      'date': _dateController.text,
                      'details': _detailsController.text,
                      'subject': _subjects,
                      'status': _subjectStatus,
                    });
                  }
                },
                child: Text('เพิ่ม'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar( // แถบด้านล่างตามรูป
        color: Color(0xFF233F72),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white), // ไอคอนรายการ
              onPressed: () {
                Navigator.pop(context); // กลับไปหน้า todo_list
              },
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white), // ไอคอนกล้อง
              onPressed: () {
                // TODO: นำทางไปหน้ากล้อง
              },
            ),
          ],
        ),
      ),
    );
  }
}