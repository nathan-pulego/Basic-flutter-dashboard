import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'task_model.dart';

class TaskService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// Fetches all tasks for a given user.
  Future<List<Task>> getTasks(int userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> taskJson = json.decode(response.body);
      return taskJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks from the server.');
    }
  }

  /// Creates a new task.
  Future<Task> createTask(
    String title,
    String description,
    int userId,
    String username,
  ) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode({
        'title': title,
        'description': description,
        'completed': false,
        // Do not send username, backend sets it
      }),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create the task.');
    }
  }

  /// Updates an existing task.
  Future<void> updateTask(Task task, int userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard/${task.id}');
    final response = await http.patch(
      uri,
      headers: _headers,
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to update the task.');
    }
  }

  /// Deletes a task by its ID.
  Future<void> deleteTask(int userId, int taskId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard/$taskId');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete the task.');
    }
  }
}
