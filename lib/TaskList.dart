import 'package:flutter/material.dart';

class TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: Container(
        child: Center(
            child:Text('All the tasks will be displayed here')
        ),
        width: width,
        height: height,
      ),
    );
  }
}
