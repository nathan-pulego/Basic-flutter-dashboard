import 'package:flutter/material.dart';
import 'package:fluttter_test/task_model.dart';
import 'package:fluttter_test/task_card.dart';
import 'package:fluttter_test/task_service.dart'; // We'll use the service directly
import 'package:fluttter_test/task_form.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _userName;
  int? _userId;

  // State is now managed directly inside the widget
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true; // Start in loading state
  String? _error;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access the context for ModalRoute.
    // This ensures the widget is fully built before we try to get arguments.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true; // Prevent this from running again
        // Retrieve the map of arguments passed from the login page.
        final arguments =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        setState(() {
          _userName = arguments?['username'] as String?;
          _userId = arguments?['userId'] as int?;
        });

        // Fetch tasks if we have a user ID
        if (_userId != null) {
          _fetchTasks();
        }
      }
    });
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
          onSubmit: (title, description) {
            if (_userId == null) return; // Should not happen

            if (task != null) {
              // We are in edit mode
              _updateTask(task, title, description);
            } else {
              // We are in add mode
              _addTask(title, description);
            }
          },
        );
      },
    );
  }

  // --- CRUD Methods implemented directly in the widget state ---

  Future<void> _fetchTasks() async {
    try {
      final tasks = await _taskService.getTasks(_userId!);
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addTask(String title, String description) async {
    final newTask = await _taskService.createTask(title, description, _userId!, _userName!);
    if (mounted) {
      setState(() => _tasks.insert(0, newTask));
    }
  }

  Future<void> _updateTask(
    Task task,
    String newTitle,
    String newDescription,
  ) async {
    task.title = newTitle;
    task.description = newDescription;
    await _taskService.updateTask(task, _userId!);
    setState(() {}); // Just rebuild the UI to show the change
  }

  Future<void> _deleteTask(int taskId) async {
    await _taskService.deleteTask(_userId!, taskId);
    setState(() => _tasks.removeWhere((task) => task.id == taskId));
  }

  Future<void> _toggleCompleted(Task task) async {
    task.completed = !task.completed;
    await _taskService.updateTask(task, _userId!);
    setState(() {});
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
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskPanel(), // Open the panel in add mode
        backgroundColor: Colors.purple[800], // Match the AppBar color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('An error occurred: $_error'));
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('No tasks yet. Add one!'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return TaskCard(
          task: task,
          onToggleCompleted: (bool? value) => _toggleCompleted(task),
          onUpdate: () => _showTaskPanel(task: task),
          onDelete: () {
            if (_userId != null) {
              _deleteTask(task.id);
            }
          },
        );
      },
    );
  }
}
