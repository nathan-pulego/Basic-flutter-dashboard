import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('$baseUrl/auth/login');

    print('--- Sending Login Request ---');
    print('Request URL: $loginUrl');
    // Corrected the print statement to match the actual body being sent.
    print('Request Body: {"email": "$email", "password": "..."}');

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

      if (response.statusCode == 200) {
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
