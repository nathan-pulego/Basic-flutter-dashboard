import 'package:flutter/material.dart';
import 'package:fluttter_test/login.dart';
import 'package:fluttter_test/dashboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttter_test/register.dart';

Future<void> main() async {
  // You must ensure that the Flutter bindings are initialized before running async operations.
  WidgetsFlutterBinding.ensureInitialized();
  // Loading the .env file before running the app
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cloud User Dashboard",
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(), // Simplified route
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
