import 'package:flutter/material.dart';
import 'package:my_todo_list/UI/SqlTest.dart';
import 'package:my_todo_list/utils/sqlutil.dart';
import 'package:my_todo_list/Models/Task.dart';

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
            child: Icon(Icons.storage),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SqlTest()),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SqlTest()),
              // (Route<dynamic> route) => false,
            ),
          ),
        ],
      ),
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
                debugPrint('I was tapped, help!, my details are card number ' +
                    (position + 1).toString());
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
            onPressed: () async{
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
}
