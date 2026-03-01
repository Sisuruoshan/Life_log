import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  StreamSubscription? _subscription;
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  void loadTasks(String userId) {
    if (_subscription != null) return; // Prevent multiple subscriptions
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.getTasks(userId).listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _tasks = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _repository.addTask(task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _repository.updateTask(updatedTask);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
