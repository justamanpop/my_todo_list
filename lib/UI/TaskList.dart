import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_todo_list/UI/AddOrEditTask.dart';
import 'package:my_todo_list/UI/SqlTest.dart';
import 'package:my_todo_list/utils/sqlutil.dart';
import 'package:my_todo_list/Models/Task.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  SqlUtil sqlUtil = SqlUtil();
  int count = 0;
  ListView taskListView = ListView();
  List<Task> tasks = [];
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
    taskListView = taskListWidget();
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Container(
        child: taskListView,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'TestingPage',
            child: Icon(Icons.storage),
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SqlTest()),
                ),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            heroTag: 'AddPage',
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      AddOrEditTask(
                          Task('', '', DateTime.now().toIso8601String(), 3),
                          false)));
            },
            // (Route<dynamic> route) => false,
          ),
        ]
        ,
      )
      ,
    );
  }

  ListView taskListWidget() {
    getData();

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Task.colors[(tasks[position].priority) - 1],
                child: Text(Task.priorities[(tasks[position].priority) - 1]),
              ),
              title: Text(tasks[position].name),
              subtitle: Text(tasks[position].description),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  deleteData(tasks[position].id);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      AddOrEditTask(tasks[position], true)),
                );
              },
            ),
          );
        });
  }

  Future<void> getData() async {
    int numRows = await sqlUtil.getCountDb();
    var taskMaps = await sqlUtil.getAllTasksDb();

    setState(() {
      count = numRows;
      tasks = taskMaps.map((m) => Task.fromMap(m)).toList();
    });
  }

  Future<void> deleteData(int idToDelete) async {
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text("Are you sure you want to delete this task?"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () async {
              flutterNotification?.cancel(idToDelete);
              await sqlUtil.deleteFromDb(idToDelete);
              await getData();
              Navigator.of(context).pop();
            },
            child: Text('Continue')),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
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

}
