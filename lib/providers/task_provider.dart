import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/local_db_service.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get completedTasksCount => _tasks.where((t) => t.status == 'Done').length;
  int get totalTasksCount => _tasks.length;
  
  List<TaskModel> get todayDeadlines {
  final now = DateTime.now();

  return _tasks.where((task) {
    if (task.dueDate == null) return false;
    if (task.status == 'Done') return false;

    final due = task.dueDate!;

    return due.year == now.year &&
        due.month == now.month &&
        due.day == now.day;
  }).toList();
}

  void clearData() {
    _tasks = [];
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    if (LocalDbService.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    // Short delay so shimmer skeleton renders at least one frame
    await Future.delayed(const Duration(milliseconds: 600));

    final data = LocalDbService.getData('tasks');
    if (data != null) {
      _tasks = (data as List).map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item), item['id'])).toList();
    } else {
      _tasks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _saveToDisk();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    if (LocalDbService.currentUser == null) return;
    final data = _tasks.map((t) => {
      'id': t.id,
      ...t.toMap()
    }).toList();
    await LocalDbService.saveData('tasks', data);
  }
}
