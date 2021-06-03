import 'package:flutter/material.dart';

class SqlTest extends StatelessWidget {
  const SqlTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Testing Page'),
        backgroundColor: Colors.teal,
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
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        onPressed: () {},
                        icon: Icon(Icons.print),
                        label: Text('Display All'))),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text('Add to Db'),
                )),
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 10,),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(5),
                //constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 1,
                )),
              ),
            )
          ],
        ),
        constraints: BoxConstraints.expand(),
      ),
    );
  }
}
