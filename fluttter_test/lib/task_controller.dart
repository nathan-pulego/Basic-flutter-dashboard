import 'package:flutter/foundation.dart';
import 'package:fluttter_test/task_model.dart';
import 'package:fluttter_test/task_service.dart';

class TaskController with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Public getters to expose state to the UI
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify UI that we are loading

    try {
      _tasks = await _taskService.getTasks(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is complete (with or without data)
    }
  }

  Future<void> addTask(String title, String description, int userId) async {
    try {
      final newTask = await _taskService.createTask(title, description, userId);
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task, String newTitle, String newDescription) async {
    task.title = newTitle;
    task.description = newDescription;
    try {
      await _taskService.updateTask(task);
      // The list already has the reference, so we just need to notify listeners of the change.
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // You could add logic here to revert the change on failure if desired.
    }
  }

  Future<void> toggleCompleted(Task task) async {
    task.completed = !task.completed;
    notifyListeners(); // Optimistic update for a snappy UI

    try {
      await _taskService.updateTask(task);
    } catch (e) {
      task.completed = !task.completed; // Revert on failure
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(int userId, int taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners(); // Optimistic update

    try {
      await _taskService.deleteTask(userId, taskId);
    } catch (e) {
      _error = e.toString();
      // Here you would re-fetch the list or re-insert the task to revert the change.
      notifyListeners();
    }
  }
}