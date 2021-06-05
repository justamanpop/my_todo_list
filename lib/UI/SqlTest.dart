import 'package:flutter/material.dart';
import 'package:my_todo_list/Models/Task.dart';
import 'package:my_todo_list/utils/sqlutil.dart';

class SqlTest extends StatefulWidget {
  const SqlTest({Key? key}) : super(key: key);

  @override
  _SqlTestState createState() => _SqlTestState();
}

class _SqlTestState extends State<SqlTest> {
  SqlUtil sqlUtil = SqlUtil();
  int count =0;
  ListView taskListView = ListView();
  List<Task> tasks = [];

  @override
  Widget build(BuildContext context) {
    taskListView = taskListWidget();
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Testing Page'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      onPressed: () {
                        insertData();
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add to Db'),
                    )),
                SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        deleteData(count);
                      },
                      icon: Icon(Icons.delete),
                      label: Text('Delete from Db'),
                    )),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 10,),
            Expanded(child: taskListView),
          ],
        ),
        constraints: BoxConstraints.expand(),
      ),
    );
  }

  ListView taskListWidget() {
    getData();

    return ListView.builder(
        itemCount: count, itemBuilder: (BuildContext context, int position) {
      return Card(
        color: Colors.white,
        elevation: 2.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text(tasks[position].priority.toString()),
          ),
          title: Text(tasks[position].name),
          subtitle: Text(tasks[position].description),
          onTap: () {
            debugPrint('I was tapped, help!, my details are card number ' +
                (position + 1).toString());
          },
        ),
      );
    });
  }

  Future<void> getData() async
  {
    int numRows = await sqlUtil.getCountDb();
    var taskMaps = await sqlUtil.getAllTasksDb();

    setState(() {
      count = numRows;
      tasks =taskMaps.map((m) => Task.fromMap(m)).toList();
    });
  }

  Future<int>insertData() async {
    String taskName = "Task " + (count+1).toString();
    String taskDescription = "Description " + (count+1).toString();
    String dueDateTime = "Tomorrow";
    int priority = 3;
    Task taskToInsert = Task(taskName,taskDescription,dueDateTime,priority);

    int res =await sqlUtil.insertDb(taskToInsert);
    debugPrint("result of insert operation was " + res.toString());
    await getData();

    return res;
  }

  Future<int>deleteData(int idToDelete) async {
    int res =await sqlUtil.deleteFromDb(idToDelete);
    debugPrint("number of rows deleted as a result were " + res.toString());
    await getData();
    debugPrint("before return res in deleteData");
    return res;
  }

}




