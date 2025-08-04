import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      'https://reqres.in/api'; // Using a mock API for demonstration

  Future<Map<String, dynamic>> login(String email, String password) async {
    // --- 1. Print the information before sending the request ---
    print('--- Sending Login Request ---');
    print('${email}, ${password}');
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}
