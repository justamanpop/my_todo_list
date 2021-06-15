import 'package:flutter/material.dart';
import 'package:my_todo_list/Models/Task.dart';
import 'package:date_field/date_field.dart';
import 'package:my_todo_list/utils/sqlutil.dart';

class AddOrEditTask extends StatefulWidget {
  final Task task;

  AddOrEditTask(this.task);

  @override
  _AddOrEditTaskState createState() => _AddOrEditTaskState(task);
}

class _AddOrEditTaskState extends State<AddOrEditTask> {
  Task task;

  _AddOrEditTaskState(this.task);

  var formKey = GlobalKey<FormState>();
  String dropdownValue = "Low";
  String dateTimeVal = DateTime.now().toIso8601String();
  SqlUtil sqlUtil = SqlUtil();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = task.name;
    descriptionController.text = task.description;
    dateTimeVal = task.dueDateTime;
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Task'),
      ),
      body: Container(
          child: Form(
        key: formKey,
        child: Wrap(
          children: [Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: titleController,
                validator: (String? val){
                  if(val.toString().isEmpty)
                    return "Please enter the title";
                  return null;
                },
                autofocus: true,
                maxLength: 255,
                decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: Theme.of(context).textTheme.headline6,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: descriptionController,
                maxLength: 255,
                decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: Theme.of(context).textTheme.headline6,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
              ),
              SizedBox(
                height: 20,
              ),
              DateTimeFormField(
                onDateSelected: (DateTime dateTime){
                  dateTimeVal = dateTime.toString();
                },
                validator: (DateTime? val){
                  if(val==null)
                    return "Please enter a date";
                  return null;
                },
                decoration: InputDecoration(
                    labelText: "Due Date and time",
                    labelStyle: Theme.of(context).textTheme.headline6,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                mode: DateTimeFieldPickerMode.dateAndTime,
                initialValue: DateTime.parse(dateTimeVal.toString()),
              ),
              SizedBox(
                height: 20,
              ),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                        labelStyle: Theme.of(context).textTheme.headline6,
                        errorStyle:
                            TextStyle(color: Colors.redAccent, fontSize: 16.0),
                        labelText: 'Priority',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: dropdownValue == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        isDense: true,
                        onChanged: (String? newVal) {
                          setState(() {
                            dropdownValue = newVal.toString();
                            task.name = titleController.text;
                            task.description = descriptionController.text;
                            task.dueDateTime = dateTimeVal.toString();
                          });
                        },
                        items: Task.priorities.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 240,
              ),
              Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'))),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            bool? res = formKey.currentState?.validate();
                            bool isValid;
                            if(res == null)
                            {
                              isValid = false;
                            }

                            else
                            {
                              isValid = res;
                            }

                            if(isValid){
                              task.priority = _priorityStringToInt(dropdownValue);
                              task.name = titleController.text;
                              task.description = descriptionController.text;
                              task.dueDateTime = dateTimeVal;
                              sqlUtil.insertDb(task);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Submit'))),
                  SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ]),
      )),
    );
  }
  _priorityStringToInt(String val)
  {
    switch(val)
    {
      case "Low":
        return 3;
      case "Med":
        return 2;
      case "High":
        return 1;
    }
  }
}
