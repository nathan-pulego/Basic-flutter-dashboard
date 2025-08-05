import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Read the base URL from the .env file.
  // Provide a fallback value in case it's not set.
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri loginUrl = Uri.parse('$baseUrl/auth/login');

    print('--- Sending Login Request ---');
    print('Request URL: $loginUrl');
    // Corrected the print statement to match the actual body being sent.
    print('Request Body: {"email": "$email", "password": "..."}');

    try {
      final response = await http.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // 4. The JSON body must use the 'username' key.
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print('Login successful!');
        return jsonDecode(response.body);
      } else {
        // Provide more detailed error logging for debugging.
        print('Failed to login. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to login');
      }
    } catch (e) {
      // Catch network-level errors (e.g., can't connect).
      print('A network error occurred: $e');
      throw Exception('Failed to connect to the server.');
    }
  }
}
