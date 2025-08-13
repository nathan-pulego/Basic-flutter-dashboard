import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('$baseUrl/auth/login');

    print('--- Sending Login Request ---');
    print('Request URL: $loginUrl');
    print('Request Body: {"email": "$email", "password": "..."}');
    // Corrected the print statement to match the actual body being sent.

    try {
      final response = await http.patch(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final preference = await SharedPreferences.getInstance();
        final responseData = jsonDecode(response.body);
        await preference.setBool('isLoggedIn', true);
        await preference.remove('username');

        return responseData;
      } else {
        final String responseBody = response.body;
        print(
          'Login failed. Status Code: ${response.statusCode}, Body: $responseBody',
        );
        throw Exception('Login failed. Please check your credentials.');
      }
    } on http.ClientException catch (e) {
      print('A network error occurred: $e');
      throw Exception(
        'Failed to connect to the server. Please check your network.',
      );
    }
  }

  Future<void> logout(String username) async {
    final Uri logoutUrl = Uri.parse('$baseUrl/auth/logout');
    final response = await http.patch(
      logoutUrl,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username}),
    );
    if (response.statusCode == 200) {
      final preference = await SharedPreferences.getInstance();
      await preference.setBool('isLoggedIn', false);
      await preference.remove('username');
    } else {
      throw Exception('Failed to logout.');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final Uri registerUrl = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return jsonDecode(response.body);
      } else {
        print('Registration failure, Status code: ${response.statusCode}');
        throw Exception('Registration failed.: ${response.body}');
      }
    } catch (e) {
      print('A network error occurred: $e');
      throw Exception(
        'Failed to connect to the server. Please check your network.',
      );
    }
  }
}

class TaskService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  /// Fetches all tasks (no filtering by user).
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
    String username,
    int userId,
  ) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard');
    print('Sending post to $_baseUrl/users/$userId/dashboard');
    final response = await http.post(
      uri,
      headers: _headers,
      body: json.encode({
        'title': title,
        'description': description,
        'completed': false,
      }),
    );
    print(response.toString());

    if (response.statusCode == 200 || response.statusCode == 204) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create the task.');
    }
  }

  /// Updates an existing task.
  Future<Task> updateTask(Task task, int userId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard/${task.id}');
    final response = await http.patch(
      uri,
      headers: _headers,
      body: json.encode(task.toJson()),
    );
    print('task:${task.toJson()}');
    print('userid: $userId');
    print('hello ${response.toString()}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update the task. with status code ${response.statusCode} trigger A',
      );
    }
  }

  /// Deletes a task by its ID.
  Future<void> deleteTask(int userId, int taskId) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/dashboard/$taskId');
    final response = await http.delete(uri, headers: _headers);
    print('Delete response status" ${response.statusCode} trigger C');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete the task.');
    } else {
      print('Delete succeses: Trigger B');
      return;
    }
  }
}
