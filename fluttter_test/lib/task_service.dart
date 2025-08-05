import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttter_test/task_model.dart';

class TaskService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  // Centralized headers for consistency. You can add auth tokens here later.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  /// Fetches all tasks for a given owner.
  Future<List<Task>> getTasks(int userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/tasks');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> taskJson = json.decode(response.body);
      return taskJson.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks from the server.');
    }
  }

  /// Creates a new task.
  Future<Task> createTask(String title, String description, int userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/tasks');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode({
        'title': title,
        'description': description,
        'owner': userId, // The owner field in the body is likely still expected by the API
        'completed': false, // Always false on creation
      }),
    );

    if (response.statusCode == 201) { // HTTP 201 Created is the standard for success
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create the task.');
    }
  }

  /// Updates an existing task.
  Future<Task> updateTask(Task task) async {
    // The owner of the task should be the userId for the endpoint
    final uri = Uri.parse('$_baseUrl/users/${task.owner}/tasks/${task.id}');
    final response = await http.put(uri, headers: _headers, body: json.encode(task.toJson())); // We'll add toJson to the model

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update the task.');
    }
  }

  /// Deletes a task by its ID.
  Future<void> deleteTask(int userId, int taskId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/tasks/$taskId');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode != 204 && response.statusCode != 200) { // HTTP 204 No Content is standard
      throw Exception('Failed to delete the task.');
    }
  }
}