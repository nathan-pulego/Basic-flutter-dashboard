class Task {
  final int id;
  String title;
  String description;
  bool completed;
  final int owner;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.owner,
  });

  // A factory constructor for creating a new Task instance from a map.
  // This defines the structure of the data coming from the API
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      owner: json['owner'] as int,
    );
  }

  // A method for converting a Task instance to a map.
  // This will be useful when sending data to your API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'owner': owner,
    };
  }
}
