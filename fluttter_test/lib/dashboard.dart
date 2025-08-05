import 'package:flutter/material.dart';
import 'package:fluttter_test/task_model.dart';
import 'package:fluttter_test/task_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _userName; // A String variable to store the received username
  List<Task> _tasks = []; // A list to hold the user's tasks

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access the context for ModalRoute.
    // This ensures the widget is fully built before we try to get arguments.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Retrieve arguments passed from the login page.
      final String? receivedUsername =
          ModalRoute.of(context)?.settings.arguments as String?;

      if (receivedUsername != null) {
        setState(() {
          _userName = receivedUsername;

          _tasks = [
            Task(
                id: '1',
                title: 'Complete Flutter UI',
                description: 'Finish the dashboard and task card widgets.',
                completed: true,
                owner: _userName!),
            Task(
                id: '2',
                title: 'Set up Dashboard Service',
                description:
                    'Create the service file to fetch tasks from the API.',
                completed: false,
                owner: _userName!),
            Task(
                id: '3',
                title: 'Test API Connection',
                description: '',
                completed: false,
                owner: _userName!),
          ];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 138, 16, 168), 
        foregroundColor: Colors.white,
        toolbarHeight: 80,
        centerTitle: true, 
        title: Text(
          'Welcome, ${_userName ?? 'User'}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, 
            color: Colors.white,)
        ),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskCard(
            task: task,
            onToggleCompleted: (bool? value) {
              setState(() {
                task.completed = value ?? false;
              });
            },
            // These are placeholders for when I will implement the API service.
            onUpdate: () {},
            onDelete: () {},
          );
        },
      ),
    );
  }
}
