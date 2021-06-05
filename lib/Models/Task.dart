//@dart=2.9

class Task {
  int id;
  String name;
  String description = "";
  String dueDateTime;
  int priority = 3;

  Task(this.name, this.description, this.dueDateTime, this.priority);

  Task.withId(this.id, this.name, this.description, this.dueDateTime,
      this.priority);

  Task.fromMap(Map<String,Object> map)
  {
    this.name = map["name"];
    this.priority = map["priority"];
    this.description = map["description"];
    this.dueDateTime = map["dueDateTime"];
    this.id = map["id"];
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["name"] = name;
    map["description"] = description;
    map["dueDateTime"] = dueDateTime;
    map["priority"] = priority;

    if(id!=null)
    {
      map["id"] = id;
    }

    return map;
  }
}
