import 'package:flutter/material.dart';
import 'package:flutter_dashboard/task_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dashboard/models/task_model.dart';
import 'package:flutter_dashboard/task_card.dart';
import 'package:flutter_dashboard/services/api.service.dart'; // We'll use the service directly
import 'package:flutter_dashboard/task_form.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userArgs;
  const DashboardPage({super.key, this.userArgs});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _userName;
  int? _userId;

  // State is now managed directly inside the widget
  AuthService service = AuthService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final args = widget.userArgs as Map<String, dynamic>?;

    _checkLoginStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true; // Prevent this from running again
        // Retrieve the map of arguments passed from the login page.
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final prefs = SharedPreferences.getInstance();
       
        setState(() {
          _userName = args?['username'] as String?;
          _userId = args?['userId'] as int?;
        });

        // Fetch tasks if we have a user ID
        if (_userId != null) {
          taskProvider.fetchTasks(_userId!);
        }
      }
    });
  }
  void _logout() {
    context.go('/login');
  }
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn && mounted) {
      context.go('/login');
    }
  }

  // This single method now handles both adding and editing tasks.
  void _showTaskPanel({Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Ensures the sheet is responsive to the keyboard
      builder: (context) {
        return TaskForm(
          task: task, // Pass the existing task if editing, or null if adding.
          onSubmit: (title, description) async {
            if (_userId == null) return;

            final taskProvider = Provider.of<TaskProvider>(
              context,
              listen: false,
            );

            try {
              if (task != null) {
                await taskProvider.updateTask(
                  task,
                  title,
                  description,
                  _userId!,
                );
              } else {
                await taskProvider.createTask(
                  title,
                  description,
                  _userName!,
                  _userId!,
                );
                print('triggered if task is null');
              }
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
        );
      },
    );
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
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                _logout();
                await service.logout(_userName!);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'images/dashboard.png',
            ), // <-- your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskPanel(),
        backgroundColor: Colors.purple[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    final taskProvider = Provider.of<TaskProvider>(context);

    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskProvider.error != null) {
      return Center(child: Text('An error occurred: ${taskProvider.error}'));
    }

    if (taskProvider.tasks.isEmpty) {
      return const Center(
        child: Text(
          'Create new task',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return TaskCard(
          task: task,
          onToggleCompleted: (bool? value) =>
              taskProvider.toggleCompleted(task, _userId!),
          onUpdate: () => _showTaskPanel(task: task),
          onDelete: () {
            if (_userId != null) {
              taskProvider.deleteTask(_userId!, task.id);
            }
          },
        );
      },
    );
  }
}
