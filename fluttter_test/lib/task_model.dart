class Task {
  final String id;
  final String title;
  final String description;
  bool completed;
  final String owner;

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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      owner: json['owner'],
    );
  }
}
