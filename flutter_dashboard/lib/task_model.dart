class Task {
  final int id;
  String title;
  String description;
  bool completed;
  final String username; // Changed from int owner to String username

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.username, // Changed
  });

  // A factory constructor for creating a new Task instance from a map.
  // This defines the structure of the data coming from the API
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      username: json['username'], // Changed
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
      'username': username, // Changed
    };
  }
}
