import 'package:flutter/material.dart';

class SqlTest extends StatelessWidget {
  const SqlTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Testing Page'),
      ),
      body: Container(
        child: Center(child: Text('Sample text')),
        constraints: BoxConstraints.expand(),
      ),
    );
  }
}
