//@dart=2.9

class Task {
  int id;
  String name;
  String description = "";
  String dueDateTime;
  int priority = 3;

  Task(this.name, this.description, this.dueDateTime, this.priority);
  Task.withId(this.id, this.name, this.description, this.dueDateTime, this.priority);

  Map toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "dueDateTime": dueDateTime,
      "priority": priority
    };
  }
}
