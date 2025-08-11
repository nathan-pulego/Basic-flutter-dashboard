import 'package:flutter/material.dart';
import 'package:fluttter_test/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(); //<--- updates state
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService loginAuth = AuthService();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    Navigator.pushNamed(context, '/register');
  }

  Future<void> _login() async {
    // First, validate the form. If it's not valid, do nothing.
    if (!_formKey.currentState!.validate()) {
      return; //<== do nothing if form is invalid
    }

    // Then, check if terms are agreed to. if not display a message
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the login method from our AuthService
      final responseData = await loginAuth.login(
        _emailController.text,
        _passwordController.text,
      );

      // The service handles the status code check. If we get here, it was successful.
      if (mounted) {
        //Api response will respond with a username, we will put it here
        final String? username = responseData['username'];
        final int? userId =
            responseData['userId']; // Assuming API returns 'userId' as an int

        // It's crucial to have both username and userId to proceed.
        if (username == null || userId == null) {
          // If the server response is missing critical data, treat it as an error.
          throw Exception('Login failed: Invalid data from server.');
        }

        // Use Map<String, dynamic> to hold values of different types.
        final Map<String, dynamic> userArgs = {
          'username': username,
          'userId': userId,
        };

        Navigator.pushNamed(context, '/dashboard', arguments: userArgs);
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      // The loginAuth function throws an exception on any failure (bad credentials, network error, etc.).
      // We can catch it and show a user-friendly message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Display the specific error message from the AuthService exception.
            // The replaceFirst removes the "Exception: " prefix for a cleaner message.
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // This will run whether the request was successful or not.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/ab_purple.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 300.0,
            height: 450.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16.0),
            // Wrapping the Column with a Form widget
            child: Form(
              // <--- NEW: Form widget
              key: _formKey, // <--- Assign the GlobalKey here
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    // <--- CHANGED from TextField to TextFormField
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      hintText: "Enter email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      // <--- NEW: Validator for email
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    // <--- CHANGED from TextField to TextFormField
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      hintText: "Enter Password",
                    ),
                    obscureText: true,
                    validator: (value) {
                      // <--- NEW: Validator for password
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long.';
                      }
                      return null; // Return null if the input is valid, and so the validitor doesnt raise an issue(its null because it just rendered)
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _agreedToTerms =
                                newValue ??
                                false; // <== typically set _agreedToTerms as the same value as newValue, if unclicked, the default is false.
                          });
                        },
                      ),
                      Expanded(
                        child: const Text(
                          'I agree to the Terms and Conditions',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[800],

                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                  TextButton(
                    onPressed: _register,
                    child: const Text('Register here'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
