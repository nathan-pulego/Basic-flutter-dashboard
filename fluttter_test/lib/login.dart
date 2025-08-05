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

  Future<void> _login() async {
    // First, validate the form. If it's not valid, do nothing.
    if (!_formKey.currentState!.validate()) {
      return; //<== do nothing if form is invalid
    } 

    // Then, check if terms are agreed to.
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
        // Based on your API response, the username is at the top level.
        // We extract it here and provide a default value if it's not found.
        final String username = responseData['username'] ?? 'User';
        Navigator.pushNamed(
          context,
          '/dashboard',
          arguments: username,
        );
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
            image: AssetImage(
              'images/bg_login.png',
            ), // Ensure this path is correct in pubspec.yaml
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
            // Wrap the Column with a Form widget
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
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.purple,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text('Login'),
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
