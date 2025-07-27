import 'package:flutter/material.dart';

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
  bool _agreedToTerms = false;

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

  final Map<String, String> loginKeys = {
    'Nathan123@outlook.com': 'Nathan123',
    'Bob123@gmail.com': 'Bob12345',
    'Vini@yahoo.com': 'Vini12345',
  };

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
                    onPressed: () {
                      // Trigger validation when button is pressed
                      if (_formKey.currentState!.validate()) {
                        final emailValue = _emailController.text;
                        final passwordValue = _passwordController.text;

                        if (!_agreedToTerms) {
                          // <== catch clause, always start checking invalid states and deal with them before main logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please agree to the terms and conditions.',
                                style: TextStyle(color: Colors.red),
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        if (loginKeys.containsKey(emailValue) &&
                            loginKeys[emailValue] == passwordValue) {
                          // <== if lookup finds a stored email(key), it performs a second lookup of the assiociated value with the loopup key

                          //append dashboard to navigation pages
                          Navigator.pushNamed(
                            context,
                            '/dashboard',
                            arguments: emailValue,
                          );
                        } else {
                          // If the form is invalid, validators will display error messages
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invalid Login',
                                style: TextStyle(color: Colors.red),
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Login'),
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
