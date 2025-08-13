import 'package:flutter/material.dart';
import 'package:flutter_dashboard/login.dart';
import 'package:flutter_dashboard/dashboard.dart';
import 'package:flutter_dashboard/task_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dashboard/register.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ) 
  );
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
        '/dashboard': (context) => const DashboardPage(), 
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
