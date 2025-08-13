import 'dart:io';

import 'package:flutter/material.dart';
import 'models/task_model.dart';
import 'services/api.service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  //<--------- Getters ------------->

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<Task>?> fetchTasks(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks(userId);
      _error = null;
      if(_tasks.isNotEmpty){
        _isLoading = false;
        notifyListeners();
        return _tasks;
      } else {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } on HttpException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<Task?> createTask(
    String title,
    String description,
    String username,
    int userId,
  ) async {
    try {
      final newTask = await _taskService.createTask(
        title,
        description,
        username,
        userId,
      );
      _tasks.insert(0, newTask);
      notifyListeners();
      return newTask;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Task?> updateTask(Task task, String title, String description, int userId) async {
    try {
      task.title = title;
      task.description = description;
      final updatedTask = await _taskService.updateTask(task, userId);
      notifyListeners();
      return updatedTask;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteTask(int userId, int taskId) async {
    try {
      await _taskService.deleteTask(userId, taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleCompleted(Task task, int userId) async {
    try{
      task.completed = !task.completed;
      await _taskService.updateTask(task, userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
