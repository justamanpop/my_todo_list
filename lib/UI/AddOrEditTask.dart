import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_todo_list/Models/Task.dart';
import 'package:date_field/date_field.dart';
import 'package:my_todo_list/utils/sqlutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class AddOrEditTask extends StatefulWidget {
  final Task task;
  final bool isUpdate;
  AddOrEditTask(this.task,this.isUpdate);

  @override
  _AddOrEditTaskState createState() => _AddOrEditTaskState(task,isUpdate);
}

class _AddOrEditTaskState extends State<AddOrEditTask> {
  Task task;
  bool isUpdate;
  _AddOrEditTaskState(this.task,this.isUpdate);

  var formKey = GlobalKey<FormState>();
  String dateTimeVal = DateTime.now().toIso8601String();
  SqlUtil sqlUtil = SqlUtil();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FlutterLocalNotificationsPlugin? flutterNotification;

  @override
  void initState() {
    super.initState();

    var androidInitialize = AndroidInitializationSettings("todolist");
    var iosInitialize = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: androidInitialize, iOS: iosInitialize);

    flutterNotification = FlutterLocalNotificationsPlugin();
    flutterNotification!.initialize(
        initializationSettings, onSelectNotification: notificationSelected);

    timeZoneInitializationMethod();
  }


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
                  task.dueDateTime = dateTime.toString();
                },
                validator: (DateTime? val){
                  if(val==null)
                    return "Please enter a date";

                  if(val.isBefore(DateTime.now()) || isSameDateHourMinute(val,DateTime.now()) )
                    return "Please enter a time in the future";

                  return null;
                },
                decoration: InputDecoration(
                    labelText: "Due Date and time",
                    labelStyle: Theme.of(context).textTheme.headline6,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                mode: DateTimeFieldPickerMode.dateAndTime,
                initialValue: DateTime.parse(dateTimeVal.toString()).add(Duration(minutes: 1)),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: Task.priorities[task.priority-1],
                        isDense: true,
                        onChanged: (String? newVal) {
                          setState(() {
                            task.priority = _priorityStringToInt(newVal.toString());
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
                          onPressed: () async{
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
                              task.name = titleController.text;
                              task.description = descriptionController.text;
                              task.dueDateTime = dateTimeVal;

                              if(!isUpdate)
                                task.id = await sqlUtil.insertDb(task);
                              else
                                sqlUtil.updateDb(task);

                              await _scheduleNotification(task);

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

  bool isSameDateHourMinute(DateTime d1, DateTime d2)
  {
    //if same date
    if((d1.day == d2.day) && (d1.month == d2.month) && (d1.year == d2.year))
    {
      //same minute of same hour
        if((d1.hour == d2.hour) && (d1.minute == d2.minute))
        {
          return true;
        }
    }

    return false;
  }

  Future _scheduleNotification(Task task) async
  {
    debugPrint("task datetime is " + task.dueDateTime);
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    var androidNotifDetails = AndroidNotificationDetails("1","Task Notification Channel", "channel used for notifying when tasks are due", importance: Importance.high,
        enableLights: true, fullScreenIntent: true);
    var iOSNotifDetails = IOSNotificationDetails();
    var generalNotifDetails = NotificationDetails(android: androidNotifDetails , iOS:iOSNotifDetails);

    if(isUpdate)
    {
      flutterNotification?.cancel(task.id);
    }

    var TZDateTime = tz.TZDateTime.from(DateTime.parse(task.dueDateTime), tz.local);
    flutterNotification?.zonedSchedule(task.id, "${task.name}","${task.description}" , TZDateTime,generalNotifDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime   , androidAllowWhileIdle: true,);

  }

  void timeZoneInitializationMethod() async{
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future notificationSelected(String? payload) async
  {
    debugPrint("I do nothing yet");
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
    return 3;
  }
}
